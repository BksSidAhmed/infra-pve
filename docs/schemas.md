# Schémas

Schémas de l'infra en Mermaid : GitHub les affiche directement en image. Pour les modifier,
éditer le texte du bloc `mermaid` (aperçu possible sur https://mermaid.live).
Relevé du 7 octobre 2026.

## 1. Réseau

```mermaid
flowchart LR
    internet(("Internet"))
    box["Box 192.168.1.1<br/>passerelle + DHCP + DNS"]
    cf["Cloudflare<br/>cine.bks-home.com<br/>Access « Famille »"]
    proton["ProtonVPN<br/>WireGuard France"]
    ts["Tailscale<br/>tailnet siidu_96@"]

    subgraph lan["LAN 192.168.1.0/24"]
        pc["PC Windows<br/>.13"]
        tel["Téléphone S25 Ultra<br/>.10 · TS 100.83.204.51"]
        subgraph pve["pve · hôte Proxmox · 192.168.1.50"]
            nic0["nic0 (1 Gb/s)"] --- vmbr0["pont vmbr0"]
            tsh["tailscale0<br/>100.73.1.43"]
            vmbr0 --- ct100["CT 100 plex<br/>.100 · :32400"]
            vmbr0 --- ct101["CT 101 arr<br/>.101 · Docker"]
            vmbr0 --- ct102["CT 102 adguard<br/>.102 · DNS :53, web :80"]
            vmbr0 --- ct103["CT 103 paperless<br/>.103 · :8000, Samba"]
            vmbr0 --- ct104["CT 104 accueil<br/>.104 · :80"]
            vmbr0 --- ct105["CT 105 surveillance<br/>.105 · Uptime Kuma :80"]
            vmbr0 --- ct106["CT 106 claude<br/>.106 · Claude Code (API Plex/arr)"]
        end
    end

    internet --- box
    box --- pc
    box --- tel
    box --- nic0
    ct101 -. "qBittorrent, Prowlarr<br/>via gluetun" .-> proton
    ct101 -. "cloudflared<br/>(tunnel sortant)" .-> cf
    tsh <-. "accès admin à distance" .-> ts
    tel <-.-> ts
    proton --- internet
    cf --- internet
    ct105 -. "alertes ntfy.sh<br/>(sortant)" .-> internet
    nic0 -. "films-introuvables<br/>ntfy.sh (sortant)" .-> internet
```

- Trait plein : réseau local. Pointillés : tunnels chiffrés, tous **sortants** (aucun port ouvert sur la box).
- Tailscale n'est que sur l'hôte : à distance on joint Proxmox, pas directement les CT.

## 2. Chaîne multimédia (CT 101 → CT 100)

```mermaid
flowchart LR
    famille["Famille<br/>cine.bks-home.com"] --> seerr
    subgraph ct101["CT 101 arr (Docker)"]
        seerr["Seerr :5055<br/>demandes"]
        sonarr["Sonarr :8989<br/>séries"]
        radarr["Radarr :7878<br/>films"]
        bazarr["Bazarr :6767<br/>sous-titres"]
        subgraph gluetun["gluetun · ProtonVPN"]
            prowlarr["Prowlarr :9696<br/>indexeurs"]
            qbt["qBittorrent :8080"]
        end
        cfd["cloudflared"]
    end
    cfd -.-> seerr
    seerr --> sonarr & radarr
    sonarr & radarr --> prowlarr
    sonarr & radarr --> qbt
    qbt -->|écrit| dl[("/data/downloads")]
    dl -->|liens physiques| media[("/data/media<br/>films · series · anime")]
    bazarr -->|sous-titres| media
    media --> plex["CT 100 Plex :32400<br/>transcodage iGPU"]
```

`/data` = dataset ZFS `Disque1/data`, monté dans les CT 100 et 101.

## 3. Stockage

```mermaid
flowchart TB
    subgraph nvme["SSD NVMe 500 Go · LVM « pve »"]
        root["root 96 Go<br/>système Proxmox"]
        swap["swap 7 Go"]
        thin["pool thin « local-lvm » 338 Go"]
        thin --> d100["CT 100 · 12 Go"]
        thin --> d101["CT 101 · 20 Go"]
        thin --> d102["CT 102 · 4 Go"]
        thin --> d103["CT 103 · 24 Go"]
        thin --> d104["CT 104 · 4 Go"]
        thin --> d105["CT 105 · 8 Go"]
        thin --> d106["CT 106 · 8 Go"]
    end
    subgraph usb1["Disque USB 5 To n°1 · ZFS « Disque1 »"]
        data["Disque1/data ~584 Go<br/>/mnt/data"]
        bk["Disque1/backups ~21 Go<br/>sauvegardes vzdump"]
        pexp["Disque1/paperless-export<br/>~0,4 Go"]
    end
    subgraph usb2["Disque USB 5 To n°2 · ZFS « Disque2 »"]
        pdocs["Disque2/paperless ~10 Go<br/>/Disque2/paperless"]
    end
    data -->|"/data"| c100["CT 100 plex"]
    data -->|"/data"| c101["CT 101 arr"]
    pdocs -->|"/mnt/docs"| c103["CT 103 paperless"]
    pexp -->|"/mnt/export"| c103
```

Chaque pool ZFS tient sur **un seul disque**, sans redondance. Voir [stockage.md](stockage.md).

## 4. Sauvegardes

```mermaid
flowchart LR
    subgraph src["Sources"]
        cts["Disques des 5 CT<br/>(SSD)"]
        docs["Documents Paperless<br/>(Disque2)"]
        med["Médias ~584 Go<br/>(Disque1)"]
    end
    cts -->|"vzdump chaque nuit 01:00<br/>snapshot zstd · 7 j + 4 sem."| bk[("Disque1/backups")]
    docs -->|"document_exporter<br/>chaque nuit 00:30"| pexp[("Disque1/paperless-export")]
    med -.->|aucune copie| rien["❌"]
    bk -.->|aucune copie| off["❌ hors du serveur"]
    pexp -.->|aucune copie| off
```

Les points de montage (`/mnt/data`, `/mnt/docs`, `/mnt/export`) ne sont **pas** inclus dans vzdump.
Si le disque USB n°1 lâche, on perd les médias **et** toutes les sauvegardes. Voir [sauvegardes.md](sauvegardes.md).
