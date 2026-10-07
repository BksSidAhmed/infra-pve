# CT 102 — adguard

| | |
|---|---|
| IP | 192.168.1.102 |
| Système | Debian 13 |
| Ressources | 1 vCPU · 512 Mo RAM · 256 Mo swap · 4 Go sur local-lvm |
| Options | non privilégié, démarrage auto, DNS du CT : 1.1.1.1, tags `adblock;dns` |
| Config | `/opt/AdGuardHome/AdGuardHome.yaml` (extrait DNS : [config/ct102-adguard/dns-extrait.yaml](../config/ct102-adguard/dns-extrait.yaml)) |
| Config LXC | [config/lxc/102.conf](../config/lxc/102.conf) |

## Service

- **AdGuard Home** (binaire, pas Docker) : DNS sur le port 53, interface web http://192.168.1.102 (port 80).
- Serveurs amont en DNS chiffré (DoH) : Quad9 (`dns10.quad9.net`) et Cloudflare (`1.1.1.1`), en répartition de charge.
- Réécritures DNS (`filtering.rewrites`) : `accueil.home` → `192.168.1.104`.
- Sauvegardes de config : `AdGuardHome.yaml.bak`, `AdGuardHome.yaml.bak-accueil`.

## Ajouter un nom local

Interface web → Filtres → Réécritures DNS → ajouter `nom.home` → IP. (Ou éditer `filtering.rewrites`
puis redémarrer le service — demander l'accord.)
