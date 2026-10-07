# CT 105 — surveillance (Uptime Kuma)

| | |
|---|---|
| IP | 192.168.1.105 |
| Système | Debian 13 |
| Ressources | 1 vCPU · 512 Mo RAM · 512 Mo swap · 4 Go sur local-lvm |
| Options | non privilégié, `nesting=1,keyctl=1`, démarrage auto, DNS du CT : 1.1.1.1, tag `monitoring` |
| Docker Compose | `/opt/uptime-kuma/compose.yaml` (copie : [config/ct105-surveillance/](../config/ct105-surveillance/)) |
| Données | `/opt/uptime-kuma/data/` : base SQLite `kuma.db` (sondes, historique, notifications) |
| Compte admin | créé par Boukais dans l'interface (identifiant `admin`), mot de passe non noté ici |
| Config LXC | [config/lxc/105.conf](../config/lxc/105.conf) |

## Service

- Image `louislam/uptime-kuma:2`, port 80 → 3001. Interface : http://192.168.1.105. Réseau local uniquement.
- Base SQLite choisie d'avance par `data/db-config.json` (`{"type":"sqlite"}`).
- Occupe environ 130 Mo de RAM. L'image pèse 2,5 Go (elle embarque Chromium et MariaDB).

## Sondes (13)

Toutes les 60 s (Seerr public : 120 s), alerte après 2 échecs de suite, puis message au retour.
Liste exacte : [config/ct105-surveillance/sondes.sql](../config/ct105-surveillance/sondes.sql).

| Sonde | Vérifie |
|---|---|
| Plex | http://192.168.1.100:32400/identity |
| Seerr (local) | http://192.168.1.101:5055 |
| Seerr (public) | https://cine.bks-home.com (302 vers Cloudflare Access = OK) |
| Sonarr, Radarr, Bazarr, Prowlarr, qBittorrent | ports 8989, 7878, 6767 (401 accepté : mot de passe), 9696, 8080 du CT 101 |
| AdGuard (web) / AdGuard (DNS) | http://192.168.1.102 / résolution de `google.com` par 192.168.1.102:53 |
| Paperless | http://192.168.1.103:8000 |
| Homepage | http://192.168.1.104 |
| Proxmox | https://192.168.1.50:8006 (certificat auto-signé ignoré) |

Si qBittorrent et Prowlarr tombent en même temps, c'est en général gluetun (le VPN).

## Notifications

- Notification **« ntfy téléphone »** (par défaut, appliquée à toutes les sondes) : serveur public https://ntfy.sh,
  priorité maximale, sans compte.
- Le **nom du sujet** sert de clé : il n'est pas dans ce dépôt, il se lit dans Uptime Kuma (Paramètres → Notifications).
  Sur le téléphone : appli ntfy, abonnement à ce sujet.
- Test manuel depuis l'hôte : `pct exec 105 -- curl -d "test" https://ntfy.sh/<sujet>`.
- Limite : si l'hôte `pve` entier tombe (courant, plantage), Uptime Kuma tombe avec lui et **aucune alerte** ne part.

## Ajouter une sonde

Par l'interface web (bouton « Ajouter une sonde »), cocher « ntfy téléphone ». Penser à la noter ici.

## Mise à jour

```sh
pct exec 105 -- bash -c "cd /opt/uptime-kuma && docker compose pull && docker compose up -d && docker image prune -f"
```

Le `prune` est important : deux versions de l'image ne tiennent pas sur le disque.
