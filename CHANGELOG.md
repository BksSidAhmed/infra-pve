# Historique des modifications

Format : date — quoi — pourquoi — comment revenir en arrière. Le plus récent en haut.

## 2026-10-07
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
