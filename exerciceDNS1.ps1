# Demande à l'utilisateur combien d'hôtes de type "A" il souhaite enregistrer
$nombreHotes = [int](Read-Host "Combien d'hôtes de type 'A' souhaitez-vous enregistrer?")

for ($i = 1; $i -le $nombreHotes; $i++) {
    # Demande le nom de l'hôte
    $nomHote = Read-Host "Entrez le nom de l'hôte $i"

    # Demande l'adresse réseau de l'hôte
    $adresseReseau = Read-Host "Entrez l'adresse réseau de l'hôte $i"

    try {
        # Enregistrement réel de l'hôte de type "A"
        # Remplacez 'votrezone.com' par le nom de votre zone DNS
        Add-DnsServerResourceRecord -ZoneName "local.anvers.cub.sioplc.fr" -A -Name $nomHote -IPv4Address $adresseReseau

        # Message de succès
        Write-Host "L'hôte $nomHote a été enregistré avec succès." -ForegroundColor Green
    } catch {
        # Message d'erreur
        Write-Host "Erreur lors de l'enregistrement de l'hôte $nomHote." -ForegroundColor Red
    }
}
