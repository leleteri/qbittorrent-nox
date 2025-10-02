# ini buat NixOS kalo buat distro lain copy kode ini trus tanya GPT

{ config, pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-enhanced-nox;
    webUIPort = 8080;
  };

  users.users.qbittorrent = {
    isSystemUser = true;
    home = "/var/lib/qbittorrent";
    group = "qbittorrent";
  };

  users.groups.qbittorrent = {};

  # services.nginx.enable = true;
  # services.nginx.virtualHosts."<link taro sini>" = {
  #   # forceSSL = true;    # for https
  #   # enableACME = true;  # SSL certificate
  #   locations."/" = {
  #     proxyPass = "http://localhost:8080";
  #     proxyWebockets = true;
  #     extraConfig = ''
  #       proxy_set_header X-Real-IP $remote_addr;
  #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #       proxy_set_header Host $host;
  #       proxy_http_version 1.1;
  #     '';
  #   };
  # };

  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
}
