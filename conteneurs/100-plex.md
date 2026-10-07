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
- Accès distant : par le relais/accès distant Plex, **pas** par Cloudflare.

## Commandes utiles (depuis l'hôte)

```sh
pct exec 100 -- systemctl status plexmediaserver
pct exec 100 -- df -h /
```
