# CT 104 — accueil (Homepage)

| | |
|---|---|
| IP | 192.168.1.104 · nom `accueil.home` (réécriture AdGuard) |
| Système | Debian 13 |
| Ressources | 1 vCPU · 512 Mo RAM · 256 Mo swap · 4 Go sur local-lvm |
| Options | non privilégié, `nesting=1,keyctl=1`, démarrage auto, DNS du CT : 1.1.1.1, tag `dashboard` |
| Docker Compose | `/opt/homepage/compose.yaml` (copie : [config/ct104-accueil/](../config/ct104-accueil/)) |
| Config Homepage | `/opt/homepage/config/` : `services.yaml`, `settings.yaml`, `widgets.yaml` (pris en compte sans redémarrage) |
| Secrets | `/opt/homepage/.env` (variables `HOMEPAGE_VAR_*`) |
| Config LXC | [config/lxc/104.conf](../config/lxc/104.conf) |

## Service

- Image `ghcr.io/gethomepage/homepage:latest`, port 80 → 3000. Réseau local uniquement (pas dans le tunnel).
- `HOMEPAGE_ALLOWED_HOSTS` : `192.168.1.104,accueil.home,localhost:3000`.
- 3 groupes : **Médias** (Plex, Seerr, Bazarr), **Téléchargements** (Radarr, Sonarr, Prowlarr, qBittorrent),
  **Maison** (Proxmox, AdGuard, Paperless, Uptime Kuma). Voyant vert/rouge par service.
- Chiffres en direct pour Plex, Seerr, Bazarr, Radarr, Sonarr, Prowlarr et Proxmox
  (jeton `root@pam!homepage`, PVEAuditor). qBittorrent, AdGuard, Paperless, Uptime Kuma : voyant seulement.

## Ajouter un service

Ajouter une entrée dans `services.yaml` ; si une clé est nécessaire, la mettre dans `.env`
(`HOMEPAGE_VAR_XXX`) et la référencer par `{{HOMEPAGE_VAR_XXX}}`. Mettre à jour la copie dans `config/`.

## Mise à jour

```sh
pct exec 104 -- bash -c "cd /opt/homepage && docker compose pull && docker compose up -d"
```
