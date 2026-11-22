# Points d'attention et recommandations

Classés par priorité. Rien n'a été modifié : chaque action demande l'accord de Boukais.
Cocher / retirer une ligne quand c'est fait, et l'inscrire dans le [CHANGELOG](../CHANGELOG.md).

## 🔴 Haute

- [ ] **CT 103 (Paperless) ne redémarre pas tout seul** (22/11) : `Disque2` est importé trop tard au démarrage.
  Correctif : `systemctl enable zfs-import@Disque2.service` (comme Disque1). Retour arrière : `systemctl disable` du même service.
- [ ] **Disque1 après la panne du 21/11** : 5 erreurs de lecture, 5 secteurs « en attente » (SMART 197), resets USB.
  Vérifier le câble et l'alimentation du boîtier USB, lancer un test SMART long (`smartctl -t long /dev/sda`, ~10 h)
  puis un scrub. Si les secteurs en attente augmentent : remplacer le disque. Médias et sauvegardes sont dessus.
- [ ] **Un seul serveur DHCP** : depuis la panne, la Livebox et AdGuard distribuent tous les deux des adresses.
  Garder AdGuard (il donne son propre DNS, donc le filtrage) et couper celui de la Livebox ; en cas de panne du serveur,
  réactiver le DHCP de la Livebox (procédure dans [reseau.md](reseau.md)).

- [x] **Erreurs ZFS sur Disque1** (07/10) : 17 erreurs CKSUM et 1 fichier corrompu (Harry Potter 5, 2160p).
  Réglé le 07/10 : film supprimé et re-téléchargé, `zpool clear`, scrub complet terminé à 15:24 avec 0 erreur
  (« No known data errors »). Incident ponctuel, cause probable : liaison USB. À surveiller : si des erreurs
  CKSUM réapparaissent dans `zpool status`, suspecter le câble, le boîtier USB ou le disque.
- [ ] **Corriger `/etc/hosts`** : `192.168.1.19 pve.home pve` → `192.168.1.50 pve.home pve`.
  Proxmox s'appuie sur cette ligne pour connaître sa propre adresse.
- [ ] **Copie des sauvegardes hors du disque USB n°1** : médias et sauvegardes des CT sont sur le même disque.
  Au minimum, copier `/Disque1/backups` ailleurs (Disque2, cloud, PBS).

## 🟠 Moyenne

- [ ] **Recevoir réellement les alertes** : ajouter une cible SMTP authentifiée ou Gotify/ntfy dans Datacenter → Notifications. Le sujet ntfy d'Uptime Kuma (CT 105) peut être réutilisé : les échecs de sauvegarde et erreurs ZFS arriveraient alors sur le téléphone.
- [ ] **Sortir les disques de l'USB** : baies SATA internes du WTR PRO, disques 3,5" CMR (WD Red Plus, IronWolf).
- [ ] **Durcir les accès** : TOTP sur `root@pam`, SSH par clé uniquement, fail2ban.

## 🟢 Basse

- [ ] Appliquer les 17 mises à jour en attente ; `docker compose pull` de temps en temps dans les CT 101, 103, 104, 105.
- [x] Vérifié le 22/11 : le DHCP est fait par AdGuard (CT 102), qui se donne comme DNS. Voir [reseau.md](reseau.md).
- [ ] Tester une restauration (ex. CT 102 → ID 902) puis la supprimer.
- [ ] `pct fstrim 100` pour rendre au pool les blocs libérés du CT 100.
- [ ] Nettoyer `nic1` fantôme dans `/etc/network/interfaces`.
- [ ] Surveiller la RAM (1,5 Gio de swap utilisé) ; prévoir 16–32 Go avant d'ajouter une VM.

## Notes

- Disque de Plex : la doc du 06/10 indiquait 80 %, puis un chiffre de 92 % a circulé le 07/10. Vérifié le 07/10 à 18 h :
  `df` dans le CT et l'API Proxmox donnent 48-50 % (5,7 Go / 12 Go), aucun stockage n'est à 92 %. Ces chiffres élevés
  viennent de l'allocation LVM thin (`lvs` : 99 %), qui compte aussi les blocs déjà libérés (voir `pct fstrim`).
  Suivi en direct sur Homepage, groupe « Disques ».
