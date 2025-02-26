# Demande � l'utilisateur combien d'h�tes de type "A" il souhaite enregistrer
$nombreHotes = [int](Read-Host "Combien d'h�tes de type 'A' souhaitez-vous enregistrer?")

for ($i = 1; $i -le $nombreHotes; $i++) {
    # Demande le nom de l'h�te
    $nomHote = Read-Host "Entrez le nom de l'h�te $i"

    # Demande l'adresse r�seau de l'h�te
    $adresseReseau = Read-Host "Entrez l'adresse r�seau de l'h�te $i"

    try {
        # Simule l'enregistrement de l'h�te (remplacez cette partie par le code r�el d'enregistrement)
        Write-Output "Enregistrement de l'h�te $nomHote avec l'adresse $adresseReseau..."

        # Si l'enregistrement r�ussit
        Write-Host "L'h�te $nomHote a �t� enregistr� avec succ�s." -ForegroundColor Green
    } catch {
        # Si une erreur survient pendant l'enregistrement
        Write-Host "Erreur lors de l'enregistrement de l'h�te $nomHote." -ForegroundColor Red
    }
}
