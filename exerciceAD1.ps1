# Importation du module Active Directory
Import-Module ActiveDirectory

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

# Boucle pour créer des OU
while ($true) {
    # Nom de la nouvelle OU
    $ouName = "Test"

    # Demande le chemin de l'OU parente (optionnel)
    $parentOUPath = Read-Host "Entrez le chemin de l'OU parente (laissez vide pour la racine du domaine)"

    if (-not [string]::IsNullOrEmpty($parentOUPath)) {
        # Vérifie si l'OU parente existe
        if (-not (Test-OUExistence -OUPath $parentOUPath)) {
            Write-Host "L'OU parente spécifiée n'existe pas. Veuillez vérifier le chemin." -ForegroundColor Red
            continue
        }
    } else {
        # Utilise la racine du domaine comme chemin par défaut
        $parentOUPath = (Get-ADDomain).DistinguishedName
    }

    try {
        # Crée la nouvelle OU nommée "Test"
        New-ADOrganizationalUnit -Name $ouName -Path $parentOUPath -ProtectedFromAccidentalDeletion $false
        Write-Host "L'OU 'Test' a été créée avec succès sous '$parentOUPath'." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la création de l'OU 'Test'." -ForegroundColor Red
    }

    # Vérification de la création de l'OU
    if (Test-OUExistence -OUPath "OU=$ouName,$parentOUPath") {
        Write-Host "La création de l'OU 'Test' a été vérifiée avec succès." -ForegroundColor Green
    } else {
        Write-Host "La vérification de la création de l'OU 'Test' a échoué." -ForegroundColor Red
    }

    # Demande à l'utilisateur s'il souhaite continuer
    $continue = Read-Host "Souhaitez-vous créer une autre OU nommée 'Test'? (O/N)"
    if ($continue -ne "O") {
        break
    }
}
