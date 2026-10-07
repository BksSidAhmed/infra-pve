# Sauvegardes

## Tâche Proxmox (vzdump)

Définie dans `/etc/pve/jobs.cfg` (copie : [config/hote/jobs.cfg](../config/hote/jobs.cfg)).

| Réglage | Valeur |
|---|---|
| Quand | tous les jours à **01:00** |
| Quoi | tous les CT (`all 1`) |
| Mode | snapshot, compression zstd |
| Où | stockage `backups` = `/Disque1/backups/dump` (disque USB n°1) |
| Rétention | 7 quotidiennes + 4 hebdomadaires |
| Notifications | système de notification Proxmox → `siidu_96@hotmail.fr` via Postfix local (probablement jamais reçues) |

**Ce qui n'est pas sauvegardé par vzdump** : les points de montage (`/mnt/data` des CT 100/101,
`/mnt/docs` et `/mnt/export` du CT 103, marqués `backup=0` ou montages liés).

## Export Paperless

- Cron dans le CT 103 : `/etc/cron.d/paperless-export`, chaque nuit à **00:30**
  (copie : [config/ct103-paperless/cron-paperless-export](../config/ct103-paperless/cron-paperless-export)).
- `document_exporter` vers `/mnt/export` = `Disque1/paperless-export`. Journal : `/var/log/paperless-export.log` dans le CT.
- Originaux sur Disque2, copie sur Disque1.

## Résumé de ce qui est protégé

| Donnée | Copie 1 | Copie 2 | Hors du serveur |
|---|---|---|---|
| Systèmes des CT (configs Plex, *arr, AdGuard…) | SSD | Disque1 (vzdump) | ❌ |
| Documents Paperless | Disque2 | Disque1 (export) | ❌ |
| Médias (~584 Go) | Disque1 | ❌ | ❌ |

## Restaurer un CT

Interface web → stockage `backups` → choisir l'archive → *Restore* (sous un **nouvel ID** pour tester, ex. 902).
En ligne de commande : `pct restore 902 /Disque1/backups/dump/<archive>.tar.zst --storage local-lvm`.
**Demander l'accord de Boukais avant toute restauration sur un ID existant.**
Aucune restauration n'a encore été testée.
