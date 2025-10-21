{ pkgs, ... }:

{
  # QBittorrent Settings
  services.qbittorrent.enable = true;
  services.qbittorrent = {
    webUIPort = 8080;  # Default Port, Bisa diubah ke port lain
  };
  users.users.qbittorrent = { # System User untuk qbittorent
    group = "qbittorrent";
    isSystemUser = true;
  };
  users.groups.qbittorrent = {};

  # Cloudflared Settings
  services.cloudflared.tunnels = {
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" = {  # Tunnel-ID
      credentialsFile = "/var/lib/cloudflared/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.json";
      ingress = {
        "qbittorent.example.com" = "http://localhost:8080";
      };
      default = "http_status:404";
    };
  };

  users.users.cloudflared = { # System User untuk Cloudflared
    group = "cloudflared";
    isSystemUser = true;
  };
  users.groups.cloudflared = {};

  environment.systemPackages = [
    pkgs.cloudflared  # For Cloudflared commands
  ];
}

