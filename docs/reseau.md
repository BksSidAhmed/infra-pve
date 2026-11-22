# Réseau

## Hôte

- Une seule carte utilisée : `nic0`, rattachée au pont `vmbr0`.
- `vmbr0` : `192.168.1.50/24`, passerelle `192.168.1.1`.
- DNS de l'hôte : `192.168.1.1` (box), domaine de recherche `home`.
- Pas de VLAN, pas de SDN, **pas de pare-feu Proxmox** actif.
- Config : `/etc/network/interfaces` (copie : [config/hote/interfaces](../config/hote/interfaces)).
  Elle déclare une carte `nic1` qui n'existe pas (reste d'installation, sans effet).

## Conteneurs

Tous sur `vmbr0` avec une IP fixe, passerelle `192.168.1.1`.

| CT | IP | DNS configuré | Ports en écoute |
|---|---|---|---|
| 100 plex | 192.168.1.100 | 192.168.1.1 | 32400 |
| 101 arr | 192.168.1.101 | 192.168.1.1 | 5055, 6767, 7878, 8989, 8080 et 9696 (via gluetun) |
| 102 adguard | 192.168.1.102 | 1.1.1.1 | 53 (DNS), 80 (web) |
| 103 paperless | 192.168.1.103 | 192.168.1.1 | 8000, 445 (Samba) |
| 104 accueil | 192.168.1.104 | 1.1.1.1 | 80 |
| 105 surveillance | 192.168.1.105 | 1.1.1.1 | 80 (Uptime Kuma) |
| 106 claude | 192.168.1.106 | 1.1.1.1 | aucun (sortant seulement) |

## Hôte : ports en écoute

| Port | Service |
|---|---|
| 22 | SSH |
| 8006 | Interface web Proxmox (pveproxy) |
| 3128 | spiceproxy |
| 111 | rpcbind |
| 25 (local) | Postfix (mails d'alerte) |

## DNS et AdGuard

- AdGuard Home (CT 102) interroge Quad9 et Cloudflare en DoH (`upstream_mode: load_balance`).
- Réécriture DNS : `accueil.home` → `192.168.1.104`.
- Les CT eux-mêmes n'utilisent pas AdGuard.

## DHCP (vérifié le 22/11/2026)

- Le DHCP du réseau est assuré par **AdGuard (CT 102)** : plage 192.168.1.10-40, bail 24 h, passerelle 192.168.1.1,
  DNS donné = AdGuard lui-même (`dhcp:` dans `/opt/AdGuardHome/AdGuardHome.yaml`, baux dans `data/leases.json`).
- Le DHCP de la Livebox doit rester **coupé** en temps normal, sinon deux serveurs se répondent (adresses en double).
- **Si le serveur `pve` est en panne** : plus de DHCP ni de DNS. Réactiver le DHCP dans l'interface de la Livebox
  (http://192.168.1.1) pour retrouver Internet, puis le recouper quand le serveur est revenu.
- Le 21/11 (panne de courant) le DHCP de la Livebox a été activé (10-49) ; au 22/11 les deux tournent en même temps.

## Tailscale

- Installé sur l'**hôte uniquement** : `pve` = `100.73.1.43`.
- Pas de *subnet router* ni d'*exit node* : à distance on atteint Proxmox (SSH, :8006) mais pas les CT directement.
- Appareils du tailnet (compte `siidu_96@`) : `pve`, `s25-ultra-de-sid-ahmed` (100.83.204.51).

## VPN de téléchargement

Voir [conteneurs/101-arr.md](../conteneurs/101-arr.md) : gluetun + ProtonVPN WireGuard (France),
avec redirection de port transmise automatiquement à qBittorrent.
