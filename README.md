# infra-pve — Homelab de Boukais

Documentation de l'infrastructure maison : un serveur **Proxmox VE** (`pve`) qui fait tourner
une chaîne multimédia (Plex + suite *arr derrière VPN), un bloqueur de pubs DNS, une GED
Paperless et une page d'accueil. Dernier relevé : **7 octobre 2026**.

> Règles de travail (pour Claude et pour toi) : voir [CLAUDE.md](CLAUDE.md).

## En bref

| | |
|---|---|
| Serveur | Mini-PC TianBei WTR PRO, Ryzen 7 5825U (8c/16t), 8 Go RAM |
| Système | Proxmox VE 9.2.21 (Debian 13 trixie), nœud seul |
| IP | `192.168.1.50` (LAN) · `100.73.1.43` (Tailscale) |
| Disques | SSD NVMe 500 Go (système + CT) · 2 × WD 5 To en USB (ZFS `Disque1`, `Disque2`) |
| Conteneurs | 5 LXC non privilégiés (100 à 104), aucune VM |
| Sauvegarde | vzdump chaque nuit à 01:00 vers `Disque1` (7 jours + 4 semaines) |
| Accès extérieur | Tailscale (admin) · Cloudflare Tunnel pour `cine.bks-home.com` (Seerr) |

## Schéma

```
Internet ─── Box 192.168.1.1 (passerelle + DHCP)
                 │
          LAN 192.168.1.0/24
                 │
   ┌─────────────┴──────────────────────────────────────────────┐
   │ pve 192.168.1.50  (nic0 → vmbr0)   tailscale0 100.73.1.43   │
   │                                                             │
   │  CT 100 plex      .100  Plex :32400 (iGPU)                  │
   │  CT 101 arr       .101  Seerr, Sonarr, Radarr, Bazarr       │
   │                         gluetun(VPN) → Prowlarr, qBittorrent│
   │                         cloudflared → cine.bks-home.com     │
   │  CT 102 adguard   .102  AdGuard Home DNS :53 / web :80      │
   │  CT 103 paperless .103  Paperless-ngx :8000 + Samba         │
   │  CT 104 accueil   .104  Homepage :80                        │
   │                                                             │
   │  SSD NVMe  → local-lvm (disques des CT)                     │
   │  USB WD 5To → ZFS Disque1 : /mnt/data (médias), backups     │
   │  USB WD 5To → ZFS Disque2 : paperless                       │
   └─────────────────────────────────────────────────────────────┘
```

## Accès rapide

| Service | Adresse | Où |
|---|---|---|
| Page d'accueil (Homepage) | http://accueil.home ou http://192.168.1.104 | CT 104 |
| Proxmox | https://192.168.1.50:8006 (Tailscale : https://100.73.1.43:8006) | hôte |
| Plex | http://192.168.1.100:32400/web | CT 100 |
| Seerr | http://192.168.1.101:5055 · https://cine.bks-home.com | CT 101 |
| Sonarr | http://192.168.1.101:8989 | CT 101 |
| Radarr | http://192.168.1.101:7878 | CT 101 |
| Bazarr | http://192.168.1.101:6767 | CT 101 |
| Prowlarr | http://192.168.1.101:9696 (via gluetun) | CT 101 |
| qBittorrent | http://192.168.1.101:8080 (via gluetun) | CT 101 |
| AdGuard Home | http://192.168.1.102 | CT 102 |
| Paperless-ngx | http://192.168.1.103:8000 · dépôt `\\192.168.1.103\scan` | CT 103 |

## Plan d'adressage

| IP | Machine |
|---|---|
| 192.168.1.1 | Box (passerelle, DHCP, DNS) |
| 192.168.1.10 | Téléphone S25 Ultra (Tailscale 100.83.204.51) |
| 192.168.1.13 | PC Windows |
| 192.168.1.50 | pve (hôte Proxmox) |
| 192.168.1.100 | CT 100 plex |
| 192.168.1.101 | CT 101 arr |
| 192.168.1.102 | CT 102 adguard |
| 192.168.1.103 | CT 103 paperless |
| 192.168.1.104 | CT 104 accueil |

Prochaines IP libres conseillées pour un nouveau CT : `192.168.1.105` et suivantes (ID 105…).

## Contenu du dépôt

- [CLAUDE.md](CLAUDE.md) — règles, accès, où trouver quoi
- [docs/](docs/) — matériel, réseau, accès extérieur, stockage, sauvegardes, sécurité, recommandations
- [conteneurs/](conteneurs/) — une fiche par conteneur
- [config/](config/) — copies des fichiers de config (sans secrets)
- [CHANGELOG.md](CHANGELOG.md) — historique des modifications
