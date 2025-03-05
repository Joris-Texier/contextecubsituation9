Import-Module ActiveDirectory

# D�finir le chemin du domaine
$domainDN = "DC=local,DC=anvers,DC=cub,DC=sioplc,DC=fr"

# Fonction pour créer un utilisateur
function Create-ADUser {
    param (
        [string]$FirstName,
        [string]$LastName,
        [string]$OU
    )

    $fullName = "$FirstName $LastName"
    $username = "$($FirstName.ToLower()).$($LastName.ToLower())"
    $ouPath = "OU=$OU,OU=Utilisateurs,$domainDN"

    try {
        New-ADUser -Name $fullName `
                   -GivenName $FirstName `
                   -Surname $LastName `
                   -SamAccountName $username `
                   -UserPrincipalName "$username@local.anvers.cub.sioplc.fr" `
                   -Path $ouPath `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -AccountPassword (ConvertTo-SecureString "ChangeMe123!" -AsPlainText -Force)

        Write-Host "Compte crée avec succés pour $fullName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Erreur lors de la création du compte pour $fullName : $_" -ForegroundColor Red
        return $false
    }
}

# V�rifier si le fichier CSV existe
$csvPath = "C:\Users\Administrateur\Desktop\contextecubsituation9\import.csv"
if (-not (Test-Path $csvPath)) {
    Write-Host "Le fichier import.csv n'a pas ete, veuillez changer le chemin du fichier." -ForegroundColor Red
    exit
}

# Lire le fichier CSV et créer les utilisateurs
$users = Import-Csv -Path $csvPath -Delimiter ";"
$failedUsers = @()

foreach ($user in $users) {
    $success = Create-ADUser -FirstName $user.firstName -LastName $user.lastName -OU $user.OU
    if (-not $success) {
        $failedUsers += "$($user.firstName) $($user.lastName)"
    }
}

# Afficher un r�sum�
Write-Host "`nResume de la création des comptes :" -ForegroundColor Cyan
Write-Host "Nombre total de comptes traités : $($users.Count)"
Write-Host "Nombre de comptes créés avec succés : $($users.Count - $failedUsers.Count)"
if ($failedUsers.Count -gt 0) {
    Write-Host "Utilisateurs non crees :" -ForegroundColor Yellow
    $failedUsers | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}