# Debian / Ubuntu

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Debian-OpenLogo.svg/1280px-Debian-OpenLogo.svg.png" width="300">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ubuntu-logo-2022.svg/500px-Ubuntu-logo-2022.svg.png" width="300">

## Instalasi & Konfigurasi qBittorrent

### 1. Install qBittorrent-nox

Gunakan `apt` untuk menginstall paket dari repository resmi Debian/Ubuntu.
```bash
sudo apt update
sudo apt install qbittorrent-nox -y 
```
### 2. Buat System User

Agar qBittorrent berjalan dengan hak akses terbatas.
```bash
sudo groupadd --system qbittorrent
sudo useradd --system --no-create-home --group qbittorrent --shell /usr/sbin/nologin qbittorrent
```

### 3. Konfigurasi Systemd Service

Buat file service di `/etc/systemd/system/qbittorrent-nox.service`:
```toml
[Unit] 
Description=qBittorrent Command Line Client
After=network.target
[Service] 
Type=forking User=qbittorrent
Group=qbittorrent
ExecStart=/usr/bin/qbittorrent-nox --daemon --webui-port=8080 
ExecStop=/usr/bin/killall -w -s 9 /usr/bin/qbittorrent-nox Restart=on-failure
[Install] 
WantedBy=multi-user.target
```
> **Catatan**: Ubah `--webui-port=8080` sesuai port yang diinginkan.

Reload systemd, aktifkan, dan jalankan service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now qbittorrent-nox.service
sudo systemctl status qbittorrent-nox.service 
```
----------

## Instalasi & Konfigurasi Cloudflared

### 1. Install Cloudflared

Untuk Debian/Ubuntu, Cloudflare menyediakan `.deb` resmi. Jalankan:
```
curl -LO https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```
### 2. Login & Buat Tunnel

Sambungkan `cloudflared` dengan akun Cloudflare Zero Trust:
```bash
cloudflared login
```

Buat tunnel dan dapatkan file kredensial:
```bash
cloudflared tunnel create <tunnelName>
```
Pindahkan file kredensial ke `/etc/cloudflared`:

```bash
sudo mkdir -p /etc/cloudflared
sudo mv ~/.cloudflared/<Tunnel-ID>.json /etc/cloudflared/credentials.json
``` 

### 3. Konfigurasi Tunnel Ingress

Buat file `/etc/cloudflared/config.yml`:

```yaml
tunnel:  <Tunnel-ID>  credentials-file:  /etc/cloudflared/credentials.json  ingress:  -  hostname:  <domain-anda>  service:  http://localhost:8080  # Sama dengan port qbittorrent  -  service:  http_status:404
```

### 4. Jalankan Tunnel sebagai Service

```
sudo cloudflared service install
sudo systemctl enable --now cloudflared
sudo systemctl status cloudflared
```

Cek status tunnel melalui dashboard Cloudflare Zero Trust.

### Kembali ke [Halaman Utama](../)
