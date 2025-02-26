# Importation du module Active Directory
Import-Module ActiveDirectory

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

# Boucle pour cr�er des OU
while ($true) {
    # Nom de la nouvelle OU
    $ouName = "Test"

    # Demande le chemin de l'OU parente (optionnel)
    $parentOUPath = Read-Host "Entrez le chemin de l'OU parente (laissez vide pour la racine du domaine)"

    if (-not [string]::IsNullOrEmpty($parentOUPath)) {
        # V�rifie si l'OU parente existe
        if (-not (Test-OUExistence -OUPath $parentOUPath)) {
            Write-Host "L'OU parente sp�cifi�e n'existe pas. Veuillez v�rifier le chemin." -ForegroundColor Red
            continue
        }
    } else {
        # Utilise la racine du domaine comme chemin par d�faut
        $parentOUPath = (Get-ADDomain).DistinguishedName
    }

    try {
        # Cr�e la nouvelle OU nomm�e "Test"
        New-ADOrganizationalUnit -Name $ouName -Path $parentOUPath -ProtectedFromAccidentalDeletion $false
        Write-Host "L'OU 'Test' a �t� cr��e avec succ�s sous '$parentOUPath'." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la cr�ation de l'OU 'Test'." -ForegroundColor Red
    }

    # V�rification de la cr�ation de l'OU
    if (Test-OUExistence -OUPath "OU=$ouName,$parentOUPath") {
        Write-Host "La cr�ation de l'OU 'Test' a �t� v�rifi�e avec succ�s." -ForegroundColor Green
    } else {
        Write-Host "La v�rification de la cr�ation de l'OU 'Test' a �chou�." -ForegroundColor Red
    }

    # Demande � l'utilisateur s'il souhaite continuer
    $continue = Read-Host "Souhaitez-vous cr�er une autre OU nomm�e 'Test'? (O/N)"
    if ($continue -ne "O") {
        break
    }
}
