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
}
