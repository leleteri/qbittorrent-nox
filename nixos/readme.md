

# NixOS
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/NixOS_logo.svg/2880px-NixOS_logo.svg.png" width="300">

### Konfigurasi lengkapnya bisa lihat di [sini](./qbittorrent.nix)

## Instalasi & Konfigurasi qBittorrent

Tambahkan line ini ke file configuration.nix anda:
```nix
{
  users.users.qbittorrent = {  # System User untuk qBittorrent
    group = "qbittorrent";
    isSystemUser = true;
  };
  users.groups.qbittorrent = {};
  services.qbittorrent.enable = true;
}
```
Jika ingin menggunakan port lain (default: 8080), bisa dengan menambahkan:
```nix
{
  services.qbittorrent.webUIPort = 8090;  # pilih port yang anda mau
}
```
Untuk konfigurasi lainnya bisa cek di:
https://search.nixos.org/options?channel=25.05&query=qbittorrent

Rebuild sistem anda:
```bash
sudo nixos-rebuild switch
```
 Cek apakah qBittorrent berjalan
```bash
sudo systemctl qbittorrent
```

## Instalasi & Konfigurasi Cloudflared
### 1. Install Cloudflared
Tambahakan ini ke file configuration.nix anda
```nix
{
  environment.systemPackages = [
    pkgs.cloudflared
  ];
  services.cloudflared = {
    enable = true;
    certificateFile = "/var/lib/cloudflared/cert.pem";
  }
}
``` 
lalu reebuild sistem anda
```bash
sudo nixos-rebuild switch
# atau dengan
sudo nix-rebuild test  # untuk rebuild hanya pada sesi saat ini
```
<br>

### 2. Konfigurasi Cloudflared
 Sambungkan cloudflared dengan Cloudflare Zero Trust anda
```bash
cloudflared login
```
command di atas akan membuka link dengan browser anda, pastikan anda sudah memiliki dan login akun cloudflare pada browser anda. Ini akan membuat certificate file di `~/.cloudflared/cert.pem`<br>

Selanjutnya buat tunnel dengan dan dapatkan tunnel-ID dengan:
```bash
cloudflared tunnel create <tunnelName>
cloudflared tunnel info <tunnelName>
```
Tambahkan lagi ini ke file configuration.nix anda, ini akan mengaktifkan tunnel lalu rebuild
```nix
{
  services.cloudflared.tunnel = {
    <tunnel-id> = {
      credentialsFile = "/var/lib/cloudflared/<tunnel-id>.json";
      ingress = {
        "<domain-anda>" = "http://localhost:8080";  # Pastikan sama dengan port qbittorrent
      };
      default = "http_status:404";
    };
  };
}
```
setelah rebuild, cek pada cloudflare zero trust anda apakah tunnel sudah aktif. Jika sudah bisa lanjut ke Cloudflare Dashboard

### Kembali ke [Halaman Utama](../)


