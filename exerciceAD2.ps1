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

# Boucle pour cr�er des comptes utilisateur
while ($true) {
    # Demande les informations n�cessaires pour cr�er un compte utilisateur
    $firstName = Read-Host "Entrez le pr�nom de l'utilisateur"
    $lastName = Read-Host "Entrez le nom de l'utilisateur"
    $samAccountName = Read-Host "Entrez le nom de connexion (SamAccountName)"
    $password = Read-Host "Entrez le mot de passe" -AsSecureString

    try {
        # Cr�e le compte utilisateur
        New-ADUser -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName -AccountPassword $password -Enabled $true
        Write-Host "Le compte utilisateur '$samAccountName' a �t� cr�� avec succ�s." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la cr�ation du compte utilisateur '$samAccountName'." -ForegroundColor Red
    }

    # V�rification de la cr�ation du compte utilisateur
    if (Test-UserExistence -UserSamAccountName $samAccountName) {
        Write-Host "La cr�ation du compte utilisateur '$samAccountName' a �t� v�rifi�e avec succ�s." -ForegroundColor Green
    } else {
        Write-Host "La v�rification de la cr�ation du compte utilisateur '$samAccountName' a �chou�." -ForegroundColor Red
    }

    # Demande � l'utilisateur s'il souhaite continuer
    $continue = Read-Host "Souhaitez-vous cr�er un autre compte utilisateur? (O/N)"
    if ($continue -ne "O") {
        break
    }
}
