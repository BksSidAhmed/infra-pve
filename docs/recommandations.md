# Points d'attention et recommandations

Classés par priorité. Rien n'a été modifié : chaque action demande l'accord de Boukais.
Cocher / retirer une ligne quand c'est fait, et l'inscrire dans le [CHANGELOG](../CHANGELOG.md).

## 🔴 Haute

- [ ] **Erreurs ZFS sur Disque1** (nouveau, relevé du 07/10) : 17 erreurs CKSUM et 1 fichier corrompu
  (film Harry Potter et l'Ordre du Phénix, 2160p). SMART du disque OK → câble/port USB probable.
  À faire : vérifier le câble et le port USB, re-télécharger le film, puis `zpool clear Disque1` et un `zpool scrub Disque1`
  pour vérifier tout le disque. Si les erreurs reviennent, le disque ou le boîtier USB est en cause.
- [ ] **Corriger `/etc/hosts`** : `192.168.1.19 pve.home pve` → `192.168.1.50 pve.home pve`.
  Proxmox s'appuie sur cette ligne pour connaître sa propre adresse.
- [ ] **Copie des sauvegardes hors du disque USB n°1** : médias et sauvegardes des CT sont sur le même disque.
  Au minimum, copier `/Disque1/backups` ailleurs (Disque2, cloud, PBS).

## 🟠 Moyenne

- [ ] **Recevoir réellement les alertes** : ajouter une cible SMTP authentifiée ou Gotify/ntfy dans Datacenter → Notifications.
- [ ] **Sortir les disques de l'USB** : baies SATA internes du WTR PRO, disques 3,5" CMR (WD Red Plus, IronWolf).
- [ ] **Durcir les accès** : TOTP sur `root@pam`, SSH par clé uniquement, fail2ban.

## 🟢 Basse

- [ ] Appliquer les 17 mises à jour en attente ; `docker compose pull` de temps en temps dans les CT 101, 103, 104.
- [ ] Vérifier que la box distribue `192.168.1.102` (AdGuard) en DNS DHCP, avec un DNS de secours.
- [ ] Tester une restauration (ex. CT 102 → ID 902) puis la supprimer.
- [ ] `pct fstrim 100` pour rendre au pool les blocs libérés du CT 100.
- [ ] Nettoyer `nic1` fantôme dans `/etc/network/interfaces`.
- [ ] Surveiller la RAM (1,5 Gio de swap utilisé) ; prévoir 16–32 Go avant d'ajouter une VM.

## Notes

- Disque de Plex : la doc du 06/10 indiquait 80 % ; le 07/10, `df` dans le CT donne 45 % (5,0 Go / 12 Go).
  Le chiffre de 80 % venait probablement de l'allocation LVM thin (voir `pct fstrim` ci-dessus). À surveiller quand même.
