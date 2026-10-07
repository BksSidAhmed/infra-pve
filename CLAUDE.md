# CLAUDE.md — règles pour travailler sur l'infra de Boukais

Ce dépôt est **la source de vérité** de l'infrastructure maison (serveur Proxmox `pve`).
Lis-le avant d'aller fouiller le serveur : la plupart des réponses sont ici, et ça évite
de refaire un relevé complet à chaque fois.

## 1. Règles d'or (à respecter absolument)

1. **Demander l'accord de Boukais avant toute modification importante.** Explique ce que
   tu vas faire, ce que ça risque de casser et comment revenir en arrière, puis attends
   un « oui » clair. Sont considérés comme importants (liste non exhaustive) :
   - créer, supprimer, redémarrer, arrêter ou redimensionner un conteneur / une VM ;
   - toucher au réseau (`/etc/network/interfaces`, `/etc/hosts`, IP, DNS, pare-feu, Tailscale, Cloudflare) ;
   - toucher aux disques et stockages (ZFS, LVM, `storage.cfg`, montages, formatage, `zpool`/`zfs` en écriture) ;
   - modifier un `docker-compose.yml`, mettre à jour / recréer des conteneurs Docker ;
   - modifier les sauvegardes (tâche vzdump, cron d'export Paperless), en supprimer ;
   - installer/mettre à jour des paquets (`apt upgrade`), redémarrer l'hôte ;
   - tout ce qui touche aux accès (SSH, comptes, jetons API, mots de passe, Cloudflare Access) ;
   - supprimer des fichiers de données (médias, documents Paperless, sauvegardes).
2. **Lecture seule par défaut.** Les commandes de consultation (`pct list`, `pct config`,
   `zpool status`, `docker ps`, `cat`…) peuvent se faire sans demander.
3. **Toujours une sauvegarde avant de modifier un fichier de config** : `cp fichier fichier.bak-<raison>`.
4. **Mettre à jour ce dépôt après chaque changement de l'infra** (voir section 5). Un changement
   qui n'est pas dans le dépôt est considéré comme non terminé.
5. **Aucun secret dans ce dépôt** : pas de mot de passe, clé API, jeton, clé WireGuard, `TUNNEL_TOKEN`,
   `PAPERLESS_SECRET_KEY`… On note seulement **où** il se trouve sur le serveur
   (ex. « jeton dans `/opt/arr/cloudflared.env` »). Les fichiers `.env` ne sont jamais copiés ici.
6. Répondre à Boukais **en français**, simplement.

## 2. Accès

| Quoi | Comment |
|---|---|
| Hôte Proxmox | `ssh root@192.168.1.50` (nom `pve.home`) |
| Clé SSH de Claude (PC Windows) | `~/.ssh/id_ed25519_proxmox_audit` → `ssh -i ~/.ssh/id_ed25519_proxmox_audit root@192.168.1.50` |
| Interface web | https://192.168.1.50:8006 (certificat auto-signé) |
| À distance | Tailscale : `100.73.1.43` (SSH et :8006) |
| Entrer dans un conteneur | depuis l'hôte : `pct enter <id>` ou `pct exec <id> -- <commande>` |
| Docker dans un CT | `pct exec 101 -- docker ps` / `pct exec 101 -- sh -c "cd /opt/arr && docker compose ps"` |

Il n'y a **pas** de SSH direct dans les conteneurs : on passe toujours par l'hôte avec `pct exec`.

## 3. Où trouver l'information

| Sujet | Dans ce dépôt | Sur le serveur |
|---|---|---|
| Vue d'ensemble, IP, ports | [README.md](README.md) | — |
| Schémas (réseau, médias, stockage, sauvegardes) | [docs/schemas.md](docs/schemas.md), à mettre à jour si l'architecture change | — |
| Matériel | [docs/materiel.md](docs/materiel.md) | `lsblk`, `smartctl -a /dev/sdX` |
| Réseau, DNS, Tailscale | [docs/reseau.md](docs/reseau.md) | `/etc/network/interfaces`, `ip -br a`, `tailscale status` |
| Accès depuis Internet (Cloudflare) | [docs/acces-exterieur.md](docs/acces-exterieur.md) | `/opt/arr/docker-compose.yml` (CT 101) |
| Disques, ZFS, LVM | [docs/stockage.md](docs/stockage.md) | `zpool status`, `zfs list`, `pvesm status`, `lvs` |
| Sauvegardes | [docs/sauvegardes.md](docs/sauvegardes.md) | `/etc/pve/jobs.cfg`, `/Disque1/backups/dump` |
| Sécurité | [docs/securite.md](docs/securite.md) | `/etc/ssh/sshd_config`, `pveum user list` |
| Problèmes connus / à faire | [docs/recommandations.md](docs/recommandations.md) | — |
| Un conteneur précis | [conteneurs/](conteneurs/) (une fiche par CT) | `pct config <id>` |
| Fichiers de config (copies sans secrets) | [config/](config/) | chemins indiqués dans chaque fiche |
| Historique des changements | [CHANGELOG.md](CHANGELOG.md) | — |

Si une info du dépôt semble fausse, vérifie sur le serveur (lecture seule) et corrige le dépôt.

## 4. Organisation de l'infra en une phrase par CT

- **CT 100 plex** (192.168.1.100) — Plex, transcodage iGPU, lit `/data/media`.
- **CT 101 arr** (192.168.1.101) — Docker : Seerr, Sonarr, Radarr, Bazarr, Prowlarr + qBittorrent derrière gluetun (ProtonVPN), cloudflared. Compose : `/opt/arr`.
- **CT 102 adguard** (192.168.1.102) — AdGuard Home (DNS :53, web :80). Config : `/opt/AdGuardHome/AdGuardHome.yaml`.
- **CT 103 paperless** (192.168.1.103) — Paperless-ngx (Docker, `/opt/paperless`) + Samba `\\192.168.1.103\scan`.
- **CT 104 accueil** (192.168.1.104) — Homepage (Docker, `/opt/homepage`), alias `accueil.home`.
- **CT 105 surveillance** (192.168.1.105) — Uptime Kuma (Docker, `/opt/uptime-kuma`), 13 sondes, alertes ntfy sur le téléphone.

## 5. Procédure après chaque modification de l'infra

1. Mettre à jour la ou les fiches concernées (`README.md`, `docs/`, `conteneurs/`).
2. Si un fichier de config a changé, recopier sa nouvelle version dans `config/` **en retirant les secrets**.
3. Ajouter une ligne datée dans [CHANGELOG.md](CHANGELOG.md) : date, quoi, pourquoi, comment revenir en arrière.
4. Vérifier qu'aucun secret n'est présent :
   `git diff --cached | grep -iE "password|passwd|secret|token|api[_-]?key|private_key|BEGIN .*KEY"`
5. Commit en français (`git commit -m "CT 101 : ajout de ..."`) puis `git push`.

## 6. Pièges connus

- `/etc/hosts` de l'hôte annonce encore `192.168.1.19` alors que l'IP réelle est `192.168.1.50` (voir recommandations).
- Les disques de 5 To sont branchés en **USB** : ne pas lancer de grosses opérations ZFS sans prévenir.
- Les volumes montés dans les CT (`/mnt/data`, `/Disque2/paperless`…) **ne sont pas** dans les sauvegardes vzdump.
- Prowlarr et qBittorrent partagent le réseau de `gluetun` : leurs ports (9696, 8080) sont publiés par gluetun. Redémarrer gluetun coupe ces deux services.
- Plex ne doit pas passer par le tunnel Cloudflare (interdit par leurs conditions).
- Le nom `accueil.home` ne marche que sur les appareils qui utilisent AdGuard (192.168.1.102) comme DNS.
