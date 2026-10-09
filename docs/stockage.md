# Stockage

## Vue d'ensemble

```
SSD NVMe 465,8 Go (Crucial P310) — groupe LVM « pve »
├─ root   96 Go   → /         (5,7 Go utilisés)
├─ swap   7,2 Go
└─ data   338 Go  → pool thin « local-lvm » : disques racine des CT

USB WD 5 To n°1 (sda) — pool ZFS « Disque1 » (un seul disque, pas de redondance)
├─ Disque1/data              ~584 Go → /mnt/data          (médias, partagé CT 100 et 101)
├─ Disque1/backups           ~21 Go  → /Disque1/backups   (stockage Proxmox « backups »)
└─ Disque1/paperless-export  ~0,4 Go → /Disque1/paperless-export (export Paperless, CT 103 /mnt/export)

USB WD 5 To n°2 (sdb) — pool ZFS « Disque2 » (un seul disque)
└─ Disque2/paperless         ~10 Go  → /Disque2/paperless (CT 103 /mnt/docs)
```

Compression ZFS activée, ARC limité à environ 0,72 Gio.

## Stockages Proxmox (`/etc/pve/storage.cfg`)

| Nom | Type | Emplacement | Contenu |
|---|---|---|---|
| local | dir | SSD `/var/lib/vz` | ISO, modèles, import, sauvegardes |
| local-lvm | lvmthin | SSD, pool `data` | disques des CT |
| Disque1 | zfspool | USB n°1 | disques VM/CT (inutilisé) |
| backups | dir | `/Disque1/backups` | sauvegardes vzdump |
| Disque2 | zfspool | USB n°2 | disques VM/CT (inutilisé) |

## Occupation au 07/10/2026 (18 h)

| Stockage | Occupé | Utilisé / total |
|---|---|---|
| Disque1 (médias, sauvegardes) | 14 % | 623 Go / 4,5 To (dont médias 602 Go) |
| Disque2 (Paperless) | 0,2 % | 9,6 Go / 4,5 To |
| local-lvm (SSD, disques des CT) | 12 % | 42 Go / 338 Go |
| local (SSD, système de l'hôte) | 6 % | 5,7 Go / 94 Go |
| Disque du CT 100 plex | 48-50 % | 5,7 Go / 12 Go |

Ces chiffres sont affichés en direct sur Homepage (groupe « Disques », voir [104-accueil.md](../conteneurs/104-accueil.md)).
Le CT Plex contient surtout ROCm (`/opt/rocm-7.2.0`, 2,4 Go, pour l'iGPU AMD), le système (`/usr`, 1,5 Go)
et les données Plex (1,3 Go, dont 0,7 Go de cache de transcodage).

## Disques des conteneurs (local-lvm)

| CT | Taille | Utilisé (df, 07/10) |
|---|---|---|
| 100 plex | 12 Go | 5,6 Go (50 %) |
| 101 arr | 20 Go | 4,5 Go (24 %) |
| 102 adguard | 4 Go | 0,8 Go (21 %) |
| 103 paperless | 24 Go | 5,1 Go (23 %) |
| 104 accueil | 4 Go | 1,6 Go (44 %) |
| 105 surveillance | 8 Go | 3,4 Go (46 %) |
| 106 claude | 8 Go | ~1 Go |

Note : `lvs` montre le thin du CT 100 alloué à 99 % alors que `df` n'en voit que 50 % : des blocs
libérés n'ont pas été rendus au pool (un `pct fstrim 100` les récupérerait). Sans gravité tant que le pool a de la place.

## Arborescence des médias (`/mnt/data`, vu comme `/data` dans les CT 100 et 101)

```
/data
├─ downloads/   ← qBittorrent écrit ici
└─ media/
   ├─ films/
   ├─ series/
   └─ anime/     ← Sonarr/Radarr rangent ici par liens physiques (pas de double occupation)
```

Groupe `media` (GID 10000) avec bit setgid, `UMASK 002`. Les conteneurs Docker tournent en `1000:10000`.

## Paperless (`/Disque2/paperless`, vu comme `/mnt/docs` dans le CT 103)

`media/` (documents), `data/` (index), `pgdata/` (base PostgreSQL), `consume/` (dépôt), `non-pris-en-charge/`.

## ⚠️ État de santé au 07/10/2026

- `Disque1` : **17 erreurs de somme de contrôle (CKSUM) et 1 fichier corrompu** :
  `media/films/Harry Potter and the Order of the Phoenix (2007)/…2160p…FLOP.mkv`.
  SMART du disque OK (0 secteur réalloué, 0 erreur CRC), donc cause probable : liaison USB.
  Voir [recommandations.md](recommandations.md).
- `Disque2` : sain.
- Scrub automatique Debian : 2e dimanche du mois à 00:24 (`/etc/cron.d/zfsutils-linux`), trim le 1er dimanche.
