# CT 103 — paperless

| | |
|---|---|
| IP | 192.168.1.103 |
| Système | Debian 13 |
| Ressources | 2 vCPU · 2,5 Go RAM · 1 Go swap · 24 Go sur local-lvm |
| Options | non privilégié, `nesting=1,keyctl=1`, démarrage auto (ordre 4) |
| Montages | `/Disque2/paperless` → `/mnt/docs` · `/Disque1/paperless-export` → `/mnt/export` (tous deux `backup=0`) |
| Docker Compose | `/opt/paperless/docker-compose.yml` (copie : [config/ct103-paperless/](../config/ct103-paperless/)) |
| Réglages | `/opt/paperless/paperless.env` (copie sans la clé secrète : `paperless.env.exemple`) |
| Secrets | `/opt/paperless/.env` (`DB_PASS`), `PAPERLESS_SECRET_KEY` dans `paperless.env` |
| Config LXC | [config/lxc/103.conf](../config/lxc/103.conf) |

## Services Docker

| Conteneur | Image | Rôle |
|---|---|---|
| paperless-webserver-1 | ghcr.io/paperless-ngx/paperless-ngx:latest | Application, port 8000 |
| paperless-db-1 | postgres:17 | Base, données dans `/mnt/docs/pgdata` |
| paperless-broker-1 | redis:7 | File de tâches (volume Docker `redisdata`) |

## Données (`/mnt/docs` = Disque2)

`media/` documents · `data/` index · `pgdata/` base · `consume/` dépôt · `non-pris-en-charge/` fichiers non PDF.

## Réglages principaux

- OCR `fra+eng`, dates JJ/MM/AAAA, rangement `année/correspondant/date titre`.
- Consommation récursive, sous-dossiers → étiquettes, doublons supprimés, **polling 30 s** (inotify échoue sur les sous-dossiers profonds).
- 11 types de documents en français en apprentissage automatique, étiquette d'arrivée « À traiter ».

## Partages Samba (compte `scanner`)

| Partage | Chemin | Usage |
|---|---|---|
| `\\192.168.1.103\scan` | `/mnt/docs/consume/Scanner` | Dépôt du scanner, étiquette « Scanner » auto |
| `\\192.168.1.103\non-pris-en-charge` | `/mnt/docs/non-pris-en-charge` | Fichiers Word, PowerPoint… mis de côté |

Config : [config/ct103-paperless/smb.conf](../config/ct103-paperless/smb.conf).

## Sauvegarde

Export lisible chaque nuit à 00:30 vers `/mnt/export` (Disque1), voir [docs/sauvegardes.md](../docs/sauvegardes.md).

## Accès extérieur

Non ouvert (en attente).
