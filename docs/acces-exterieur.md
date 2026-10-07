# Accès depuis l'extérieur

Un seul port est ouvert sur la Livebox : **TCP 32400 → Plex (192.168.1.100)**, voir [conteneurs/100-plex.md](../conteneurs/100-plex.md).
Au 07/10, la box est en IPv4 partagée (CGN) Orange : sortie demandée dans la box, pas encore effective, donc Plex passe par son relais.
Pour le reste, deux chemins existent :

## 1. Tailscale (administration)

Depuis un appareil du tailnet : `ssh root@100.73.1.43` ou https://100.73.1.43:8006.
Voir [reseau.md](reseau.md#tailscale).

## 2. Cloudflare Tunnel (famille)

| Élément | Détail |
|---|---|
| Domaine | `bks-home.com` (DNS chez Cloudflare) |
| Adresse publiée | https://cine.bks-home.com → `http://seerr:5055` |
| Tunnel | « maison », conteneur `cloudflared` dans le compose du CT 101 (`/opt/arr/docker-compose.yml`) |
| Jeton du tunnel | `/opt/arr/cloudflared.env` dans le CT 101 (droits 600) — **jamais dans ce dépôt** |
| Protection | Cloudflare Zero Trust (équipe `small-mouse-c3e2`, forfait Free), application Access « cine » |
| Règle | « Famille » : liste d'emails autorisés, code à usage unique par mail, session 1 mois |
| Ensuite | Connexion à Seerr avec le compte Plex, ou un compte local Seerr (activé) pour les profils gérés Plex Home |

### Inviter quelqu'un

1. Cloudflare Zero Trust → Access controls → Policies → **Famille** → ajouter l'email dans *Include · Emails*.
2. Plex : créer un utilisateur géré dans Plex Home (ou partager avec son compte Plex s'il en a un).
3. Seerr : créer un utilisateur local avec le même email (Utilisateurs → Créer un utilisateur local).

### Limites

- **Plex ne passe pas par le tunnel** (streaming vidéo interdit par Cloudflare) : Plex garde son propre accès à distance.
- Paperless et Homepage ne sont **pas** exposés.
- Les routes du tunnel se gèrent dans le tableau de bord Cloudflare (Networks → Tunnels → maison), pas sur le serveur.
