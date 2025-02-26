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

# Boucle pour créer des comptes utilisateur
while ($true) {
    # Demande les informations nécessaires pour créer un compte utilisateur
    $firstName = Read-Host "Entrez le prénom de l'utilisateur"
    $lastName = Read-Host "Entrez le nom de l'utilisateur"
    $samAccountName = Read-Host "Entrez le nom de connexion (SamAccountName)"
    $password = Read-Host "Entrez le mot de passe" -AsSecureString

    try {
        # Crée le compte utilisateur
        New-ADUser -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName -AccountPassword $password -Enabled $true
        Write-Host "Le compte utilisateur '$samAccountName' a été créé avec succès." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la création du compte utilisateur '$samAccountName'." -ForegroundColor Red
    }

    # Vérification de la création du compte utilisateur
    if (Test-UserExistence -UserSamAccountName $samAccountName) {
        Write-Host "La création du compte utilisateur '$samAccountName' a été vérifiée avec succès." -ForegroundColor Green
    } else {
        Write-Host "La vérification de la création du compte utilisateur '$samAccountName' a échoué." -ForegroundColor Red
    }

    # Demande à l'utilisateur s'il souhaite continuer
    $continue = Read-Host "Souhaitez-vous créer un autre compte utilisateur? (O/N)"
    if ($continue -ne "O") {
        break
    }
}
