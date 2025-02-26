# Importation du module Active Directory
Import-Module ActiveDirectory

# Fonction pour v�rifier l'existence d'un utilisateur
function Test-UserExistence {
    param (
        [string]$UserSamAccountName
    )
    try {
        Get-ADUser -Identity $UserSamAccountName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour v�rifier l'existence d'une OU
function Test-OUExistence {
    param (
        [string]$OUPath
    )
    try {
        Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Fonction pour v�rifier si un UPN existe d�j�
function Test-UPNExistence {
    param (
        [string]$UPN
    )
    try {
        $existingUser = Get-ADUser -Filter {UserPrincipalName -eq $UPN}
        return ($null -ne $existingUser)
    } catch {
        return $false
    }
}

# Fonction pour convertir un nom d'OU simple en chemin complet
function Convert-ToFullOUPath {
    param (
        [string]$SimpleOUPath
    )
    
    # Le domaine sp�cifi�
    $domainDN = "DC=local,DC=anvers,DC=cub,DC=sioplc,DC=fr"
    
    # Si le chemin est vide, retourner juste le domaine
    if ([string]::IsNullOrEmpty($SimpleOUPath)) {
        return $domainDN
    }
    
    # Si le chemin contient d�j� DC=, on suppose qu'il est complet
    if ($SimpleOUPath -like "*DC=*") {
        return $SimpleOUPath
    }
    
    # Si le chemin commence d�j� par OU=, ajouter juste le domaine
    if ($SimpleOUPath -like "OU=*") {
        return "$SimpleOUPath,$domainDN"
    }
    
    # Sinon, ajouter OU= et le domaine
    return "OU=$SimpleOUPath,$domainDN"
}

# Boucle pour cr�er des comptes utilisateur
while ($true) {
    # Demande les informations n�cessaires pour cr�er un compte utilisateur
    Write-Host "`n--- Cr�ation d'un nouveau compte utilisateur ---" -ForegroundColor Cyan
    $firstName = Read-Host "Entrez le pr�nom de l'utilisateur"
    $lastName = Read-Host "Entrez le nom de l'utilisateur"
    $samAccountName = Read-Host "Entrez le nom de connexion (SamAccountName)"
    
    # V�rification si le SamAccountName existe d�j�
    if (Test-UserExistence -UserSamAccountName $samAccountName) {
        Write-Host "ATTENTION: Un utilisateur avec le SamAccountName '$samAccountName' existe d�j�." -ForegroundColor Yellow
        $retry = Read-Host "Voulez-vous utiliser un autre SamAccountName? (O/N)"
        if ($retry -eq "O") {
            continue
        }
    }
    
    # Demande du mot de passe
    $password = Read-Host "Entrez le mot de passe" -AsSecureString
    
    # Demande l'OU o� cr�er l'utilisateur
    $createInOU = $true
    $ouPath = ""
    
    while ($createInOU) {
        $ouInput = Read-Host "Entrez le nom ou le chemin de l'OU o� cr�er l'utilisateur (ex: Utilisateurs) ou laissez vide pour la racine du domaine"
        
        # Convertir l'entr�e en chemin complet d'OU
        $ouPath = Convert-ToFullOUPath -SimpleOUPath $ouInput
        
        Write-Host "Chemin complet de l'OU: $ouPath" -ForegroundColor Yellow
        
        # V�rifie si l'OU existe
        if (Test-OUExistence -OUPath $ouPath) {
            $createInOU = $false
        } else {
            Write-Host "L'OU sp�cifi�e n'existe pas. Veuillez v�rifier le chemin." -ForegroundColor Red
            $retry = Read-Host "Voulez-vous r�essayer? (O/N)"
            if ($retry -ne "O") {
                # Utilise la racine du domaine si l'utilisateur ne veut pas r�essayer
                $ouPath = "DC=local,DC=anvers,DC=cub,DC=sioplc,DC=fr"
                Write-Host "Utilisation de la racine du domaine: $ouPath" -ForegroundColor Yellow
                $createInOU = $false
            }
        }
    }
    
    # Cr�ation du UPN
    $domainDNS = "local.anvers.cub.sioplc.fr"
    $baseUPN = "$samAccountName@$domainDNS"
    $userPrincipalName = $baseUPN
    $counter = 1
    
    while (Test-UPNExistence -UPN $userPrincipalName) {
        $userPrincipalName = "$samAccountName$counter@$domainDNS"
        $counter++
        Write-Host "Le UPN '$baseUPN' existe d�j�. Tentative avec '$userPrincipalName'" -ForegroundColor Yellow
    }
    
    $displayName = "$firstName $lastName"
    
    try {
        # Cr�e le compte utilisateur dans l'OU sp�cifi�e
        New-ADUser -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName -DisplayName $displayName -Name $displayName `
            -AccountPassword $password -Enabled $true -Path $ouPath
            
        Write-Host "Le compte utilisateur '$samAccountName' a �t� cr�� avec succ�s dans '$ouPath'." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la cr�ation du compte utilisateur '$samAccountName':" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        continue
    }
    
    # V�rification de la cr�ation du compte utilisateur
    if (Test-UserExistence -UserSamAccountName $samAccountName) {
        Write-Host "La cr�ation du compte utilisateur '$samAccountName' a �t� v�rifi�e avec succ�s." -ForegroundColor Green
        
        # Affiche les informations du compte cr��
        Write-Host "`nInformations du compte cr��:" -ForegroundColor Cyan
        $user = Get-ADUser -Identity $samAccountName -Properties *
        Write-Host "Nom complet: $($user.DisplayName)" -ForegroundColor White
        Write-Host "SamAccountName: $($user.SamAccountName)" -ForegroundColor White
        Write-Host "UserPrincipalName: $($user.UserPrincipalName)" -ForegroundColor White
        Write-Host "Emplacement: $($user.DistinguishedName)" -ForegroundColor White
    } else {
        Write-Host "La v�rification de la cr�ation du compte utilisateur '$samAccountName' a �chou�." -ForegroundColor Red
    }
    
    # Demande � l'utilisateur s'il souhaite continuer
    $continue = Read-Host "`nSouhaitez-vous cr�er un autre compte utilisateur? (O/N)"
    if ($continue -ne "O") {
        break
    }
}

Write-Host "`nFin du script de cr�ation de comptes utilisateurs." -ForegroundColor Cyan