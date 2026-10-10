# Historique des modifications

Format : date — quoi — pourquoi — comment revenir en arrière. Le plus récent en haut.

## 2026-10-10
- Accès à Seerr pour un nouvel invité : email ajouté à la politique Cloudflare Access « Famille », compte local Seerr
  (utilisateur 2) créé par Boukais, permissions passées de « Demander » (32) à « Demander + Approbation automatique »
  (160) via l'API, puis + « Demandes avancées » (8352) pour qu'il choisisse la qualité. Pas de compte Plex : profil géré Plex Home (lecture à distance limitée par le relais, CGN Orange).
  Retour arrière : retirer l'email de « Famille » ; dans Seerr, supprimer l'utilisateur ou décocher Approbation automatique.
- Cloudflare Access : la connexion à « cine » ne proposait plus que « Cloudflare » (compte Cloudflare, redirection
  automatique), les invités tombaient sur « Sign in to Cloudflare ». Ajout du fournisseur **One-time PIN** et activation
  dans l'application « cine ». Retour arrière : décocher One-time PIN dans l'application (bloque les invités).

## 2026-10-09
- **Nouveau CT 106 `claude`** (192.168.1.106, Debian 13, 2 vCPU, 1 Go RAM, 8 Go) : Claude Code en Remote Control pour
  gérer films et séries depuis le portable sans PC allumé. Accès **uniquement** par API (Radarr, Sonarr, Prowlarr,
  qBittorrent, Seerr, Plex ; clés copiées dans `/home/claude/.config/plex-api.env`, compte qBittorrent repris du
  client de téléchargement de Radarr) ; aucune clé SSH ni jeton Proxmox. Service `claude-rc` (tmux), règles dans
  `/home/claude/plex/CLAUDE.md` (copie : config/ct106-claude/). Voir conteneurs/106-claude.md.
  Pourquoi : demande de Boukais (version « Plex seulement », plus sûre qu'un accès admin permanent).
  Retour arrière : `pct destroy 106`, puis régénérer les clés API des applis si besoin.
- Plex (CT 100) : Détective Conan (bibliothèque Anime) était associé au téléfilm « Un défi pour Shinichi Kudo »
  (tvdb 249009). Corrigé par « Corriger la correspondance » vers l'animé de 1996 (plex://show/5d9c0847705e7a001e6d7c86,
  tvdb 72454). Plex range les 214 épisodes dans une seule saison 1, numéros absolus, titres vérifiés.
  Retour arrière : refaire « Corriger la correspondance » dans Plex.
- Sonarr : Détective Conan, saisons françaises 2 à 5 ajoutées à la main (packs Amen, VF 1080p, la 5 en 576p, ~47 Go)
  + épisodes 29 à 42 pris dans le pack Amen « S01 » (seuls ces 14 fichiers téléchargés). Résultat : épisodes 1 à 214
  dans Plex (57 Go). Les packs français ne suivent pas le découpage TVDB (S02 FR = épisodes 43 à 85, etc.) et Sonarr
  ne les importe pas tout seul : import manuel via l'API (`manualimport` sans `seriesId`, puis commande `ManualImport`
  en mode copie, donc liens physiques). Entrées « import bloqué » retirées de la file Sonarr sans toucher aux torrents.
  Retour arrière : supprimer les fichiers dans `/data/media/anime/Detective Conan` et les torrents dans qBittorrent.
- Sonarr : Détective Conan (demandé dans Seerr le 08/10, saison 1) ne se téléchargeait pas. Cause : la numérotation
  « scène » (TheXEM) de la série met les 1 216 épisodes dans une seule saison 1, donc Sonarr refuse tous les packs
  « S01 » français (« trop petit », « pas tous diffusés ») et les recherches épisode par épisode ne trouvent rien.
  Correction : pack `Detective.Conan.S01.REMASTERED.MULTI.VFF.1080p.WEB…-T3KASHi` (9,6 Go, 28 épisodes) ajouté à la main
  dans qBittorrent (catégorie `tv-sonarr`), les 28 épisodes rangés par Sonarr. L'entrée restée « import bloqué » dans la
  file d'attente Sonarr (1 216 lignes) a été retirée sans toucher au torrent (il continue de partager). Aucun réglage modifié.
  Retour arrière : supprimer le torrent et les fichiers dans `/data/media/anime/Detective Conan`.
- Médiathèque : Les Simpson saison 9, 15 fichiers renommés (aucun supprimé). Le pack STEGNER (WEB-DL) suit un
  autre ordre que la diffusion : le fichier « E03 » contenait l'épisode 17 (« La malédiction des Simpson ») et les
  fichiers E04 à E17 contenaient les épisodes 3 à 16. Correction : ancien E03 → E17, ancien E04…E17 → E03…E16.
  Sonarr (RescanSeries) et Plex (scan du dossier) relancés, vérifié par les sous-titres incrustés.
  Les 784 fichiers des 37 saisons ont été contrôlés (sous-titres forcés, et .srt pour la saison 35) : seule la saison 9
  était décalée. S02E07 et S04E07 ont juste les sous-titres forcés d'un autre épisode (image et son corrects), laissés tels quels.
  Pourquoi : dans Plex, titre, résumé et vignette ne correspondaient pas à l'épisode joué.
  Retour arrière : dans `Season 9`, faire l'inverse (E17 → E03, E03…E16 → E04…E17) en passant par des noms temporaires,
  puis relancer Sonarr et Plex. Pas de liste conservée sur le serveur (demande de Boukais).

## 2026-10-07
- Paperless (CT 103) : index de recherche reconstruit avec `docker exec -u paperless … document_index reindex`.
  Pourquoi : la reconstruction lancée en root juste après le classement avait cassé la recherche (droits).
  Retour arrière : sans objet.
- Paperless (CT 103) : les 218 documents classés dans 14 dossiers (types de documents + vues du menu de gauche,
  voir `conteneurs/103-paperless.md`), d'après leur contenu. Les 15 anciens types et 11 anciennes vues sont remplacés,
  étiquette « Doublon possible » ajoutée sur 18 documents. Aucun document supprimé, fichiers non déplacés.
  Pourquoi : tout était en vrac, Boukais veut trier dossier par dossier.
  Retour arrière : état d'avant dans `/mnt/docs/data/avant-classement-20261007.json` (Disque2) à réappliquer.
- Homepage (CT 104) : nouveau groupe « Disques » avec l'occupation en direct de Disque1, Disque2, SSD (local-lvm)
  et du disque du CT Plex, via l'API Proxmox (jeton `root@pam!homepage` existant, widgets `customapi`).
  Pourquoi : suivre l'espace disque d'un coup d'œil (relevé du jour : Disque1 14 %, Disque2 0,2 %, local-lvm 12 %,
  CT Plex 50 % ; le « 92 % » venait de l'allocation LVM thin, pas du remplissage réel).
  Retour arrière : dans `/opt/homepage/config/`, remettre `services.yaml.bak-disques` et `settings.yaml.bak-disques`.
  Copie de la nouvelle config dans `config/ct104-accueil/` : à faire (voir le fil « Espace disque et Homepage »).
- Médiathèque : film « Legend (1985) » (6,8 Go) supprimé à la demande de Boukais avec `supprimer-film "legend"`
  (retiré de Radarr avec son dossier, torrent et fichier supprimés dans qBittorrent).
  Retour arrière : le redemander dans Seerr / Radarr.
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
- Disque1 : film corrompu (Harry Potter 5, 2160p) supprimé et re-téléchargé via Radarr, `zpool clear` puis `zpool scrub`.
  Scrub terminé à 15:24 : 0 octet réparé, 0 erreur, « No known data errors ».
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
