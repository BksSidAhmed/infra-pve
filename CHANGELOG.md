# Historique des modifications

Format : date — quoi — pourquoi — comment revenir en arrière. Le plus récent en haut.

## 2026-10-07
- Demandes Seerr bloquées : ajout de `/usr/local/bin/films-introuvables` sur l'hôte (cron quotidien à 18 h,
  `/etc/cron.d/films-introuvables`, sujet ntfy dans `/etc/films-introuvables.conf`). Il explique pourquoi un film ou une série
  n'arrive pas, relance la recherche et prévient sur ntfy. Seerr : notifications du navigateur (Web Push) activées et
  `applicationUrl` = https://cine.bks-home.com (sauvegarde `settings.json.bak-webpush`). Profil qualité Radarr inchangé
  (accepte déjà 720p à 4K). Pourquoi : aucun retour quand une demande « tournait » sans fin.
  Retour arrière : supprimer `/etc/cron.d/films-introuvables`, le script et sa conf ; dans Seerr, désactiver Web Push
  (Paramètres → Notifications) ou restaurer `settings.json.bak-webpush` (Seerr arrêté).
- CT 100 (Plex) : accès à distance en port manuel 32400 (`ManualPortMappingMode=1`, `ManualPortMappingPort=32400`).
  Livebox (par Boukais) : règle NAT TCP 32400 → plex, sortie du CGN cochée, box redémarrée.
  Pourquoi : plex.tv voyait le serveur « Not Reachable » (UPnP accepté par la box mais rien n'arrivait).
  Toujours injoignable depuis Internet en fin de journée → IPv4 partagée Orange, appel au 3900 à faire.
  Retour arrière : restaurer `Preferences.xml.bak-20261007` (Plex arrêté), supprimer la règle NAT.
- CT 101 : connexion « Plex Media Server » ajoutée dans Radarr et Sonarr par Boukais (192.168.1.100:32400, Update Library).
  Retour arrière : la supprimer dans Settings → Connect.
- CT 100 (Plex) : analyse automatique des bibliothèques activée (scan partiel) + analyse périodique toutes les 6 h.
  Pourquoi : les nouveaux films/épisodes n'apparaissaient qu'après une actualisation manuelle (réglages désactivés,
  aucune connexion Plex dans Radarr/Sonarr). Retour arrière : restaurer `Preferences.xml.bak-scan-auto` (Plex arrêté).
- CT 105 : disque agrandi de 4 à 8 Go (`pct resize 105 rootfs 8G`), l'image Uptime Kuma (2,5 Go) le remplissait à 98 %. Pas de retour arrière possible (un disque LXC ne se réduit pas), sans conséquence.
- CT 105 « surveillance » créé (192.168.1.105, Debian 13, 1 vCPU, 512 Mo, 4 Go) : Uptime Kuma 2 sous Docker,
  13 sondes (Plex, Seerr local + public, *arr, qBittorrent, AdGuard web + DNS, Paperless, Homepage, Proxmox),
  alertes sur le téléphone via ntfy.sh. Pourquoi : être prévenu quand un service tombe.
  Retour arrière : `pct stop 105 && pct destroy 105`. Sauvegarde de la base avant ajout des sondes : `data/kuma.db.bak-sondes`.
- Homepage (CT 104) : tuile Uptime Kuma dans le groupe « Maison » (sauvegarde `services.yaml.bak-uptime-kuma`).
- Hôte : ajout de la commande `/usr/local/bin/supprimer-film` (Radarr + qBittorrent + fichiers). Retour arrière : supprimer le fichier.
- Disque1 : film corrompu (Harry Potter 5, 2160p) supprimé et re-téléchargé via Radarr, `zpool clear` puis `zpool scrub` lancé.
- Ajout de docs/schemas.md : 4 schémas Mermaid (réseau, chaîne multimédia, stockage, sauvegardes). Documentation seulement, rien de changé sur le serveur.
- Création de ce dépôt à partir de la doc HTML du 06/10 et d'un relevé en lecture seule du serveur.
- Constaté : 17 erreurs CKSUM et 1 fichier corrompu sur le pool `Disque1` (voir docs/recommandations.md).
- Homepage (CT 104) : ajout des chiffres en direct pour Plex, Seerr, Bazarr, Radarr, Sonarr, Prowlarr et Proxmox
  (jeton API `root@pam!homepage`, rôle PVEAuditor).

## 2026-10-06
- CT 104 « accueil » créé : Homepage (Docker), réécriture DNS `accueil.home` dans AdGuard
  (sauvegarde `AdGuardHome.yaml.bak-accueil`).
- CT 101 : ajout de `cloudflared` au compose (sauvegarde `docker-compose.yml.bak-cloudflared`),
  publication de https://cine.bks-home.com → Seerr, protégée par Cloudflare Access « Famille ».
- CT 103 « paperless » créé : Paperless-ngx sur le pool `Disque2` (2e disque USB), export nocturne vers `Disque1/paperless-export`, partages Samba.
- Relevé complet de l'infra (doc HTML `Documentation-Proxmox-pve.html`).

## 2026-10-02 à 2026-10-05
- Installation de Proxmox VE, création des CT 100 (plex), 101 (arr), 102 (adguard), pool `Disque1`,
  tâche de sauvegarde vzdump quotidienne (automatique depuis le 05/10).
