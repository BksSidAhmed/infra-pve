# Matériel et système

| Élément | Détail |
|---|---|
| Machine | TianBei WTR PRO (mini-PC/NAS), BIOS du 28/01/2026 |
| Processeur | AMD Ryzen 7 5825U, 8 cœurs / 16 threads, iGPU Radeon (passé à Plex) |
| Mémoire | 8 Go (7,2 Gio visibles). Relevé du 07/10 : 4,8 Gio utilisés, 1,5 Gio de swap |
| Disque système | Crucial P310 500 Go NVMe (`nvme0n1`, n° 254754825D75) |
| Disque données 1 | WD 5 To 2,5" USB, modèle WD50NDZW-11A8JS1, n° WD-WXD2D7150KLY (`sda`) → pool ZFS `Disque1` |
| Disque données 2 | WD Elements 5 To USB, modèle WD50NDZW-11BCSS0, n° WD-WX62DA147PZK (`sdb`) → pool ZFS `Disque2` |
| Réseau | 2 × Intel I226-V 2,5 GbE : `nic0` utilisée (négociée à 1 Gb/s), `nic2` débranchée |

## Système

- Proxmox VE **9.2.21**, Debian 13 « trixie », noyau 7.0.14-20-pve.
- Installé le 2 octobre 2026. Nœud seul, pas de cluster.
- Dépôt `pve-no-subscription` (pas d'abonnement).
- 17 paquets en attente de mise à jour au 07/10/2026.
- Fuseau : Europe/Paris, clavier `fr`.

## Remarques

- Les deux disques de 5 To sont des modèles 2,5" **SMR** en **USB** : lents en écriture soutenue et
  sensibles aux micro-déconnexions. Le WTR PRO a des baies SATA internes (voir recommandations).
- 8 Go de RAM : suffisant pour les 5 CT actuels, juste pour ajouter une VM.
