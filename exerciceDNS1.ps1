# Demande à l'utilisateur combien d'hôtes de type "A" il souhaite enregistrer
$nombreHotes = [int](Read-Host "Combien d'hôtes de type 'A' souhaitez-vous enregistrer?")

for ($i = 1; $i -le $nombreHotes; $i++) {
    # Demande le nom de l'hôte
    $nomHote = Read-Host "Entrez le nom de l'hôte $i"

    # Demande l'adresse réseau de l'hôte
    $adresseReseau = Read-Host "Entrez l'adresse réseau de l'hôte $i"

    try {
        # Simule l'enregistrement de l'hôte (remplacez cette partie par le code réel d'enregistrement)
        Write-Output "Enregistrement de l'hôte $nomHote avec l'adresse $adresseReseau..."

        # Si l'enregistrement réussit
        Write-Host "L'hôte $nomHote a été enregistré avec succès." -ForegroundColor Green
    } catch {
        # Si une erreur survient pendant l'enregistrement
        Write-Host "Erreur lors de l'enregistrement de l'hôte $nomHote." -ForegroundColor Red
    }
}
