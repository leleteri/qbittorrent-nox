
# Arch Linux

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Archlinux-logo-standard-version.svg/500px-Archlinux-logo-standard-version.svg.png" width="298">


## Instalasi & Konfigurasi qBittorrent

### 1. Install qBittorrent-nox

Gunakan `pacman` untuk menginstall paket dari repository resmi Arch.

Bash

```
sudo pacman -S qbittorrent-nox

```

### 2. Buat System User

Ini adalah praktik keamanan yang baik agar qBittorrent berjalan di bawah user dengan hak akses terbatas.

Bash

```
sudo groupadd --system qbittorrent
sudo useradd --system --no-create-home --group qbittorrent --shell /usr/bin/nologin qbittorrent

```

### 3. Konfigurasi Systemd Service

Buat file service untuk `systemd` agar qBittorrent berjalan otomatis saat boot dengan user yang telah kita buat.

Buat file di `/etc/systemd/system/qbittorrent-nox.service` dan isi dengan konfigurasi berikut:

Ini, TOML

```
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
Type=forking
User=qbittorrent
Group=qbittorrent
ExecStart=/usr/bin/qbittorrent-nox --daemon --webui-port=8080
ExecStop=/usr/bin/killall -w -s 9 /usr/bin/qbittorrent-nox
Restart=on-failure

[Install]
WantedBy=multi-user.target

```

> **Catatan**: Anda bisa mengubah `--webui-port=8080` ke port lain yang Anda inginkan.

Setelah itu, reload daemon `systemd`, lalu aktifkan dan jalankan service qBittorrent.

Bash

```
sudo systemctl daemon-reload
sudo systemctl enable --now qbittorrent-nox.service

```

Cek apakah qBittorrent berjalan:

Bash

```
sudo systemctl status qbittorrent-nox.service

```

## Instalasi & Konfigurasi Cloudflared

### 1. Install Cloudflared

Paket `cloudflared` tersedia di repository resmi Arch.


```bash
sudo pacman -S cloudflared
```

### 2. Login & Buat Tunnel

Proses ini sama persis di semua distro. Sambungkan `cloudflared` dengan akun Cloudflare Zero Trust Anda.


```bash
cloudflared login
```

Perintah di atas akan membuka link di browser Anda. Ini akan membuat file sertifikat di `~/.cloudflared/cert.pem`.

Selanjutnya, buat tunnel dan dapatkan file kredensialnya:



```bash
cloudflared tunnel create <tunnelName>
```

Perintah ini akan membuat file `<Tunnel-ID>.json` di direktori `~/.cloudflared/`. Pindahkan file ini ke `/etc/cloudflared/` agar bisa diakses oleh service systemd.


```bash
sudo mkdir -p /etc/cloudflared
sudo mv ~/.cloudflared/<Tunnel-ID>.json /etc/cloudflared/credentials.json
```

### 3. Konfigurasi Tunnel Ingress

Buat file konfigurasi di `/etc/cloudflared/config.yml` dan isi dengan detail tunnel Anda.



```yaml
tunnel: <Tunnel-ID>
credentials-file: /etc/cloudflared/credentials.json
ingress:
  - hostname: <domain-anda>
    service: http://localhost:8080 # Pastikan port sama dengan qbittorrent
  - service: http_status:404

```

### 4. Jalankan Tunnel sebagai Service

Gunakan `cloudflared` untuk membuat dan mengaktifkan service `systemd` secara otomatis.

```bash
sudo cloudflared service install
sudo systemctl enable --now cloudflared
```

Cek status tunnel pada dashboard Cloudflare Zero Trust Anda.

### Kembali ke [Halaman Utama](../)
