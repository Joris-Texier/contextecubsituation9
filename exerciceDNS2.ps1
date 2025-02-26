# Demande � l'utilisateur combien d'h�tes il souhaite enregistrer
$nombreHotes = [int](Read-Host "Combien d'h�tes souhaitez-vous enregistrer?")

for ($i = 1; $i -le $nombreHotes; $i++) {
    # Demande le type d'enregistrement
    $typeEnregistrement = Read-Host "Souhaitez-vous un enregistrement de type 'A' ou 'CNAME' pour l'h�te $i?"

    if ($typeEnregistrement -eq "A") {
        # Demande le nom de l'h�te
        $nomHote = Read-Host "Entrez le nom de l'h�te $i"

        # Demande l'adresse r�seau de l'h�te
        $adresseReseau = Read-Host "Entrez l'adresse r�seau de l'h�te $i"

        try {
            # Simule l'enregistrement de l'h�te de type "A"
            Write-Output "Enregistrement de l'h�te $nomHote avec l'adresse $adresseReseau (Type A)..."
            Write-Host "L'h�te $nomHote a �t� enregistr� avec succ�s." -ForegroundColor Green
        } catch {
            Write-Host "Erreur lors de l'enregistrement de l'h�te $nomHote (Type A)." -ForegroundColor Red
        }
    } elseif ($typeEnregistrement -eq "CNAME") {
        # Demande le nom de l'h�te
        $nomHote = Read-Host "Entrez le nom de l'h�te $i"

        # Demande le nom canonique
        $nomCanonique = Read-Host "Entrez le nom canonique pour l'h�te $i"

        try {
            # Simule l'enregistrement de l'h�te de type "CNAME"
            Write-Output "Enregistrement de l'h�te $nomHote avec le nom canonique $nomCanonique (Type CNAME)..."
            Write-Host "L'h�te $nomHote a �t� enregistr� avec succ�s." -ForegroundColor Green
        } catch {
            Write-Host "Erreur lors de l'enregistrement de l'h�te $nomHote (Type CNAME)." -ForegroundColor Red
        }
    } else {
        Write-Host "Type d'enregistrement non valide. Veuillez entrer 'A' ou 'CNAME'." -ForegroundColor Yellow
    }
}
