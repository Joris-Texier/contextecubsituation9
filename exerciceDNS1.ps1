# Demande � l'utilisateur combien d'h�tes de type "A" il souhaite enregistrer
$nombreHotes = [int](Read-Host "Combien d'h�tes de type 'A' souhaitez-vous enregistrer?")

for ($i = 1; $i -le $nombreHotes; $i++) {
    # Demande le nom de l'h�te
    $nomHote = Read-Host "Entrez le nom de l'h�te $i"

    # Demande l'adresse r�seau de l'h�te
    $adresseReseau = Read-Host "Entrez l'adresse r�seau de l'h�te $i"

    try {
        # Enregistrement r�el de l'h�te de type "A"
        # Remplacez 'votrezone.com' par le nom de votre zone DNS
        Add-DnsServerResourceRecord -ZoneName "local.anvers.cub.sioplc.fr" -A -Name $nomHote -IPv4Address $adresseReseau

        # Message de succ�s
        Write-Host "L'h�te $nomHote a �t� enregistr� avec succ�s." -ForegroundColor Green
    } catch {
        # Message d'erreur
        Write-Host "Erreur lors de l'enregistrement de l'h�te $nomHote." -ForegroundColor Red
    }
}
