# CT 100 — plex

| | |
|---|---|
| IP | 192.168.1.100 |
| Système | Ubuntu 24.04 (installé via community-scripts) |
| Ressources | 2 vCPU · 2 Go RAM · 512 Mo swap · 12 Go sur local-lvm |
| Options | non privilégié, `nesting=1,keyctl=1`, démarrage auto, tags `community-script;media` |
| Montage | `/mnt/data` (hôte) → `/data` |
| Périphériques | `/dev/dri/renderD128`, `/dev/dri/card0`, `/dev/kfd` (transcodage matériel iGPU Radeon) |
| Config LXC | [config/lxc/100.conf](../config/lxc/100.conf) |

## Service

- **Plex Media Server**, installé en paquet (pas Docker) : http://192.168.1.100:32400/web
- Lit les bibliothèques dans `/data/media` (films, series, anime).
- Métadonnées et vignettes sur le disque racine du CT (sauvegardé par vzdump).
- Accès distant : direct par la box (port 32400), **pas** par Cloudflare. Voir ci-dessous.

## Accès à distance (depuis le 07/10/2026)

| Réglage `Preferences.xml` | Valeur | Effet |
|---|---|---|
| `ManualPortMappingMode` | 1 | « Spécifier manuellement le port public » (au lieu de l'UPnP automatique) |
| `ManualPortMappingPort` | 32400 | Port public annoncé à plex.tv |

- Livebox (fait par Boukais le 07/10) : règle NAT/PAT « Plex » TCP 32400 → 32400 vers l'équipement `plex`,
  pare-feu « Moyen », onglet CGN « Ne pas mutualiser mon IPv4 » coché, box redémarrée.
- **État au 07/10 : toujours « Not Reachable »** pour plex.tv. Depuis le réseau local, `http://86.248.94.57:32400`
  répond (la règle NAT marche), mais aucune connexion venant d'Internet n'arrive au serveur (tcpdump sur `vmbr0`).
  Cause probable : IPv4 partagée (CGN) chez Orange pas encore levée → Boukais doit appeler le 3900.
- En attendant, les lectures hors du domicile passent par le **relais Plex** (~2 Mbit/s, qualité réduite).
- Vérifier : `grep "mapping state set" ".../Logs/Plex Media Server.log" | tail -2` → doit afficher `Mapped - Published`.
- Sauvegarde d'avant : `Preferences.xml.bak-20261007` (même procédure de retour arrière que plus bas).
- Partage : profils « utilisateurs gérés » Plex Home, appareils connectés via plex.tv/link. Ces profils n'ont pas
  d'identifiants Plex : pour Seerr, leur créer un compte local.

## Mise à jour automatique des bibliothèques (depuis le 07/10/2026)

Réglages dans `Preferences.xml` (`/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/`) :

| Réglage | Valeur | Effet |
|---|---|---|
| `FSEventLibraryUpdatesEnabled` | 1 | « Analyser ma bibliothèque automatiquement » : Plex surveille `/data/media` (inotify) |
| `FSEventLibraryPartialScanEnabled` | 1 | Ne scanne que le dossier modifié |
| `ScheduledLibraryUpdatesEnabled` | 1 | Analyse périodique de secours |
| `ScheduledLibraryUpdateInterval` | 21600 | Toutes les 6 h |

- La surveillance marche à travers le montage : CT 100, CT 101 et l'hôte partagent le même dataset ZFS
  `Disque1/data` sur le même noyau (testé : `[Notify] New directory` dans le journal Plex).
- Sauvegarde d'avant : `Preferences.xml.bak-scan-auto`. Retour arrière : `systemctl stop plexmediaserver`,
  remettre la sauvegarde, `systemctl start plexmediaserver`.
- Radarr et Sonarr préviennent aussi Plex après chaque import (connexion « Plex Media Server », voir [101-arr.md](101-arr.md)).

## Commandes utiles (depuis l'hôte)

```sh
pct exec 100 -- systemctl status plexmediaserver
pct exec 100 -- df -h /
```
