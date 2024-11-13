{
  networking = {
    nftables = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [
        51820 # WireGuard
        8443 # Incus
      ];
    };
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          privateKeyFile = "/run/secrets/wireguard_private_key";
          listenPort = 51820;
          ips = [ "172.16.0.5/32" ];
          peers = [
            {
              endpoint = "172.168.7.33/32";
              publicKey = "6qT2XzUJFornPdYwF8/y6VG+01sZrxM9I7keR+wvjjA=";
              allowedIPs = [ "172.16.0.4/32" ];
            }
          ];
        };
      };
    };
  };
  services = {
    yggdrasil = {
      enable = true;
      persistentKeys = true;
      settings = {
        Peers = [
          # https://publicpeers.neilalexander.dev
          "tls://sin.yuetau.net:6643" # Singapore
          "tls://mima.localghost.org:443" # Philippines
          "tls://133.18.201.69:54232" # Japan
          "tls://vpn.itrus.su:7992" # Netherlands
          "tls://ygg.jjolly.dev:3443" # United States
        ];
      };
    };
  };
}
