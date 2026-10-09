# CT 106 — claude (Claude Code « Plex seulement »)

| | |
|---|---|
| IP | 192.168.1.106 |
| Système | Debian 13 |
| Ressources | 2 vCPU · 1 Go RAM · 512 Mo swap · 8 Go sur local-lvm |
| Options | non privilégié, `nesting=1`, démarrage auto, DNS du CT : 1.1.1.1, tag `claude`, SSH et postfix désactivés |
| Utilisateur | `claude` (uid 1000), Claude Code dans `~/.local/bin/claude` (installeur officiel, mise à jour automatique) |
| Dossier de travail | `/home/claude/plex` : `CLAUDE.md` (règles), `.claude/settings.json`, `journal.md` (actions faites) |
| Service | `claude-rc.service` (systemd) : lance `claude remote-control --name plex --capacity 2` dans tmux (session `claude`), max 2 sessions à la fois pour tenir dans 1 Go |
| Secrets | `/home/claude/.config/plex-api.env` (600) : clés Radarr, Sonarr, Prowlarr, Seerr, jeton Plex, compte qBittorrent ; connexion au compte Claude dans `~/.claude/` |
| Config LXC | [config/lxc/106.conf](../config/lxc/106.conf) · fichiers : [config/ct106-claude/](../config/ct106-claude/) |

## Rôle

Permet à Boukais de demander depuis son portable (projet Claude) de chercher, télécharger, supprimer ou réparer
films et séries **sans que le PC soit allumé**. Créé le 09/10/2026.

**Volontairement limité** : aucune clé SSH vers l'hôte, aucun jeton Proxmox, aucun montage de disque.
Il n'agit que par les API de Radarr, Sonarr, Prowlarr, qBittorrent, Seerr (CT 101) et Plex (CT 100).
Tout le reste du serveur se gère toujours depuis le PC. Il demande confirmation avant toute suppression
et note ses actions dans `journal.md` (à recopier ici dans le CHANGELOG de temps en temps).

## Commandes utiles (depuis l'hôte)

```sh
pct exec 106 -- systemctl status claude-rc       # le service tourne ?
pct exec 106 -- su - claude -c "tmux attach -t claude"   # voir la session (quitter : Ctrl+B puis D)
pct exec 106 -- systemctl restart claude-rc      # relancer
pct exec 106 -- cat /home/claude/plex/journal.md # ce que Claude a fait
```

## Première mise en route (une seule fois)

Depuis l'hôte (Termius → `100.73.1.43`) : `pct enter 106`, puis `su - claude`, `claude`, suivre le lien de
connexion au compte Claude, accepter de faire confiance au dossier, quitter (Ctrl+C deux fois), puis en root :
`systemctl enable --now claude-rc` et répondre `y` à « Enable Remote Control? » dans `tmux attach -t claude`
(une seule fois, le choix est retenu). Fait le 09/10/2026 (compte Claude Pro de Boukais).

## Utilisation

Depuis le portable : appli Claude → onglet **Code** → session **plex** (ou https://claude.ai/code),
ou dans le projet Claude « ProxMox » en demandant de travailler dans le dossier `plex` de l'appareil `claude`.

## Retour arrière / coupure d'urgence

- Couper : `pct stop 106` (ou `pct exec 106 -- systemctl disable --now claude-rc`).
- Supprimer complètement : `pct destroy 106`. Les clés API copiées restent valables dans les applis :
  les régénérer dans Radarr/Sonarr/Prowlarr/Seerr si le conteneur a pu être compromis.
