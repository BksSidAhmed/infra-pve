-- Sondes Uptime Kuma créées le 2026-10-07 (CT 105), à appliquer conteneur arrêté :
--   docker compose stop && sqlite3 data/kuma.db < sondes.sql && docker compose start
-- __SUJET_NTFY__ : le vrai sujet est dans la notification « ntfy téléphone » d'Uptime Kuma (pas dans le dépôt).
-- user_id = 1 : le compte admin créé par Boukais.
BEGIN;

INSERT INTO notification (name, active, user_id, is_default, config) VALUES
('ntfy téléphone', 1, 1, 1,
 '{"name":"ntfy téléphone","type":"ntfy","isDefault":true,"ntfyserverurl":"https://ntfy.sh","ntfytopic":"__SUJET_NTFY__","ntfyPriority":5,"ntfyAuthenticationMethod":"none"}');

-- Sondes HTTP : toutes les 60 s, 2 essais avant alerte.
INSERT INTO monitor (name, user_id, type, url, interval, retry_interval, maxretries, ignore_tls, maxredirects, accepted_statuscodes_json, description) VALUES
('Plex',          1, 'http', 'http://192.168.1.100:32400/identity', 60, 60, 2, 0, 10, '["200-299"]', 'CT 100'),
('Seerr (local)', 1, 'http', 'http://192.168.1.101:5055',           60, 60, 2, 0, 10, '["200-299"]', 'CT 101'),
('Seerr (public)',1, 'http', 'https://cine.bks-home.com',           120, 60, 2, 0, 0, '["200-299","300-399"]', 'Tunnel Cloudflare + Access (redirection attendue)'),
('Sonarr',        1, 'http', 'http://192.168.1.101:8989',           60, 60, 2, 0, 10, '["200-299"]', 'CT 101'),
('Radarr',        1, 'http', 'http://192.168.1.101:7878',           60, 60, 2, 0, 10, '["200-299"]', 'CT 101'),
('Bazarr',        1, 'http', 'http://192.168.1.101:6767',           60, 60, 2, 0, 10, '["200-299","401"]', 'CT 101, mot de passe (401 attendu)'),
('Prowlarr',      1, 'http', 'http://192.168.1.101:9696',           60, 60, 2, 0, 10, '["200-299"]', 'CT 101 via gluetun'),
('qBittorrent',   1, 'http', 'http://192.168.1.101:8080',           60, 60, 2, 0, 10, '["200-299"]', 'CT 101 via gluetun'),
('AdGuard (web)', 1, 'http', 'http://192.168.1.102',                60, 60, 2, 0, 10, '["200-299"]', 'CT 102'),
('Paperless',     1, 'http', 'http://192.168.1.103:8000',           60, 60, 2, 0, 10, '["200-299"]', 'CT 103'),
('Homepage',      1, 'http', 'http://192.168.1.104',                60, 60, 2, 0, 10, '["200-299"]', 'CT 104'),
('Proxmox',       1, 'http', 'https://192.168.1.50:8006',           60, 60, 2, 1, 10, '["200-299"]', 'Hôte, certificat auto-signé');

-- Sonde DNS : AdGuard doit résoudre google.com.
INSERT INTO monitor (name, user_id, type, hostname, port, dns_resolve_server, dns_resolve_type, interval, retry_interval, maxretries, description) VALUES
('AdGuard (DNS)', 1, 'dns', 'google.com', 53, '192.168.1.102', 'A', 60, 60, 2, 'CT 102, résolution DNS');

-- Toutes les sondes notifient ntfy.
INSERT INTO monitor_notification (monitor_id, notification_id)
SELECT m.id, n.id FROM monitor m, notification n WHERE n.name = 'ntfy téléphone';

COMMIT;
