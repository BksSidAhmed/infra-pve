# Sécurité et accès

| Élément | État au 07/10/2026 |
|---|---|
| Comptes Proxmox | `root@pam` uniquement |
| Jetons API | `root@pam!homepage` (« Homepage lecture seule », rôle PVEAuditor, privsep) — secret dans `/opt/homepage/.env` du CT 104 |
| SSH | `PermitRootLogin yes`, mot de passe accepté, pas de fail2ban |
| Clés SSH autorisées (`/root/.ssh/authorized_keys`) | `root@pve` (RSA), `claude-audit-lecture-seule` (clé de Claude, PC Windows) |
| 2FA interface web | non activée |
| Pare-feu Proxmox | non configuré |
| Certificat web | auto-signé, valide jusqu'au 30/09/2028 |
| Conteneurs | tous **non privilégiés** ; CT 101 a accès à `/dev/net/tun` (VPN), CT 100 à l'iGPU |

## Emplacement des secrets (jamais copiés dans ce dépôt)

| Secret | Emplacement |
|---|---|
| Clé privée WireGuard ProtonVPN | CT 101 `/opt/arr/.env` (`WIREGUARD_PRIVATE_KEY`) |
| Jeton du tunnel Cloudflare | CT 101 `/opt/arr/cloudflared.env` (`TUNNEL_TOKEN`) |
| Clés API Radarr/Sonarr/Prowlarr/Bazarr | dans leurs `config.xml` / `config.yaml` sous CT 101 `/opt/arr/config/<appli>/` |
| Clés pour Homepage (Plex, *arr, Seerr, jeton Proxmox) | CT 104 `/opt/homepage/.env` (`HOMEPAGE_VAR_*`) |
| Mot de passe base Paperless | CT 103 `/opt/paperless/.env` (`DB_PASS`) |
| Clé secrète Paperless | CT 103 `/opt/paperless/paperless.env` (`PAPERLESS_SECRET_KEY`) |
| Compte Samba `scanner` | base Samba du CT 103 (`pdbedit -L`) |
| Compte admin AdGuard | CT 102 `/opt/AdGuardHome/AdGuardHome.yaml` (section `users`, hash) |
| Compte admin Uptime Kuma | CT 105 `/opt/uptime-kuma/data/kuma.db` (table `user`, hash) |
| Sujet ntfy des alertes (sert de clé) | Uptime Kuma, notification « ntfy téléphone » (CT 105 `kuma.db`, table `notification`), copie sur l'hôte dans `/etc/films-introuvables.conf` |

Tous ces fichiers sont en droits 600.
