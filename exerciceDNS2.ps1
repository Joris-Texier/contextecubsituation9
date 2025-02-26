# Demande à l'utilisateur combien d'hôtes il souhaite enregistrer
$nombreHotes = [int](Read-Host "Combien d'hôtes souhaitez-vous enregistrer?")

for ($i = 1; $i -le $nombreHotes; $i++) {
    # Demande le type d'enregistrement
    $typeEnregistrement = Read-Host "Souhaitez-vous un enregistrement de type 'A' ou 'CNAME' pour l'hôte $i?"

    if ($typeEnregistrement -eq "A") {
        # Demande le nom de l'hôte
        $nomHote = Read-Host "Entrez le nom de l'hôte $i"

        # Demande l'adresse réseau de l'hôte
        $adresseReseau = Read-Host "Entrez l'adresse réseau de l'hôte $i"

        try {
            # Simule l'enregistrement de l'hôte de type "A"
            Write-Output "Enregistrement de l'hôte $nomHote avec l'adresse $adresseReseau (Type A)..."
            Write-Host "L'hôte $nomHote a été enregistré avec succès." -ForegroundColor Green
        } catch {
            Write-Host "Erreur lors de l'enregistrement de l'hôte $nomHote (Type A)." -ForegroundColor Red
        }
    } elseif ($typeEnregistrement -eq "CNAME") {
        # Demande le nom de l'hôte
        $nomHote = Read-Host "Entrez le nom de l'hôte $i"

        # Demande le nom canonique
        $nomCanonique = Read-Host "Entrez le nom canonique pour l'hôte $i"

        try {
            # Simule l'enregistrement de l'hôte de type "CNAME"
            Write-Output "Enregistrement de l'hôte $nomHote avec le nom canonique $nomCanonique (Type CNAME)..."
            Write-Host "L'hôte $nomHote a été enregistré avec succès." -ForegroundColor Green
        } catch {
            Write-Host "Erreur lors de l'enregistrement de l'hôte $nomHote (Type CNAME)." -ForegroundColor Red
        }
    } else {
        Write-Host "Type d'enregistrement non valide. Veuillez entrer 'A' ou 'CNAME'." -ForegroundColor Yellow
    }
}
