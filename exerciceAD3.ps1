# Importation du module Active Directory
Import-Module ActiveDirectory

# Fonction pour vérifier l'existence d'un utilisateur
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

# Fonction pour vérifier l'existence d'une OU
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

# Fonction pour vérifier si un UPN existe déjà
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
    
    # Le domaine spécifié
    $domainDN = "DC=local,DC=anvers,DC=cub,DC=sioplc,DC=fr"
    
    # Si le chemin est vide, retourner juste le domaine
    if ([string]::IsNullOrEmpty($SimpleOUPath)) {
        return $domainDN
    }
    
    # Si le chemin contient déjà DC=, on suppose qu'il est complet
    if ($SimpleOUPath -like "*DC=*") {
        return $SimpleOUPath
    }
    
    # Si le chemin commence déjà par OU=, ajouter juste le domaine
    if ($SimpleOUPath -like "OU=*") {
        return "$SimpleOUPath,$domainDN"
    }
    
    # Sinon, ajouter OU= et le domaine
    return "OU=$SimpleOUPath,$domainDN"
}

# Boucle pour créer des comptes utilisateur
while ($true) {
    # Demande les informations nécessaires pour créer un compte utilisateur
    Write-Host "`n--- Création d'un nouveau compte utilisateur ---" -ForegroundColor Cyan
    $firstName = Read-Host "Entrez le prénom de l'utilisateur"
    $lastName = Read-Host "Entrez le nom de l'utilisateur"
    $samAccountName = Read-Host "Entrez le nom de connexion (SamAccountName)"
    
    # Vérification si le SamAccountName existe déjà
    if (Test-UserExistence -UserSamAccountName $samAccountName) {
        Write-Host "ATTENTION: Un utilisateur avec le SamAccountName '$samAccountName' existe déjà." -ForegroundColor Yellow
        $retry = Read-Host "Voulez-vous utiliser un autre SamAccountName? (O/N)"
        if ($retry -eq "O") {
            continue
        }
    }
    
    # Demande du mot de passe
    $password = Read-Host "Entrez le mot de passe" -AsSecureString
    
    # Demande l'OU où créer l'utilisateur
    $createInOU = $true
    $ouPath = ""
    
    while ($createInOU) {
        $ouInput = Read-Host "Entrez le nom ou le chemin de l'OU où créer l'utilisateur (ex: Utilisateurs) ou laissez vide pour la racine du domaine"
        
        # Convertir l'entrée en chemin complet d'OU
        $ouPath = Convert-ToFullOUPath -SimpleOUPath $ouInput
        
        Write-Host "Chemin complet de l'OU: $ouPath" -ForegroundColor Yellow
        
        # Vérifie si l'OU existe
        if (Test-OUExistence -OUPath $ouPath) {
            $createInOU = $false
        } else {
            Write-Host "L'OU spécifiée n'existe pas. Veuillez vérifier le chemin." -ForegroundColor Red
            $retry = Read-Host "Voulez-vous réessayer? (O/N)"
            if ($retry -ne "O") {
                # Utilise la racine du domaine si l'utilisateur ne veut pas réessayer
                $ouPath = "DC=local,DC=anvers,DC=cub,DC=sioplc,DC=fr"
                Write-Host "Utilisation de la racine du domaine: $ouPath" -ForegroundColor Yellow
                $createInOU = $false
            }
        }
    }
    
    # Création du UPN
    $domainDNS = "local.anvers.cub.sioplc.fr"
    $baseUPN = "$samAccountName@$domainDNS"
    $userPrincipalName = $baseUPN
    $counter = 1
    
    while (Test-UPNExistence -UPN $userPrincipalName) {
        $userPrincipalName = "$samAccountName$counter@$domainDNS"
        $counter++
        Write-Host "Le UPN '$baseUPN' existe déjà. Tentative avec '$userPrincipalName'" -ForegroundColor Yellow
    }
    
    $displayName = "$firstName $lastName"
    
    try {
        # Crée le compte utilisateur dans l'OU spécifiée
        New-ADUser -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName -DisplayName $displayName -Name $displayName `
            -AccountPassword $password -Enabled $true -Path $ouPath
            
        Write-Host "Le compte utilisateur '$samAccountName' a été créé avec succès dans '$ouPath'." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la création du compte utilisateur '$samAccountName':" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        continue
    }
    
    # Vérification de la création du compte utilisateur
    if (Test-UserExistence -UserSamAccountName $samAccountName) {
        Write-Host "La création du compte utilisateur '$samAccountName' a été vérifiée avec succès." -ForegroundColor Green
        
        # Affiche les informations du compte créé
        Write-Host "`nInformations du compte créé:" -ForegroundColor Cyan
        $user = Get-ADUser -Identity $samAccountName -Properties *
        Write-Host "Nom complet: $($user.DisplayName)" -ForegroundColor White
        Write-Host "SamAccountName: $($user.SamAccountName)" -ForegroundColor White
        Write-Host "UserPrincipalName: $($user.UserPrincipalName)" -ForegroundColor White
        Write-Host "Emplacement: $($user.DistinguishedName)" -ForegroundColor White
    } else {
        Write-Host "La vérification de la création du compte utilisateur '$samAccountName' a échoué." -ForegroundColor Red
    }
    
    # Demande à l'utilisateur s'il souhaite continuer
    $continue = Read-Host "`nSouhaitez-vous créer un autre compte utilisateur? (O/N)"
    if ($continue -ne "O") {
        break
    }
}

Write-Host "`nFin du script de création de comptes utilisateurs." -ForegroundColor Cyan