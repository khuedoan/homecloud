{ pkgs, ... }:

let
  domain = "khuedoan.com";
  cloudHost = "cloud.${domain}";
  idHost = "id.${cloudHost}";
  cloudUrl = "https://${cloudHost}";
  idUrl = "https://${idHost}";
in
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    hostName = "homecloud";
    nftables = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      gcc
      git
      gnumake
      jq
      neovim
      tmux
    ];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
    fail2ban = {
      enable = true;
    };
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      appendHttpConfig = ''
        proxy_ssl_server_name on;
        proxy_ssl_name $server_name;
        proxy_ssl_trusted_certificate ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt;
        proxy_ssl_verify on;
        proxy_ssl_verify_depth 4;
      '';
      virtualHosts = {
        "${cloudHost}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://127.0.0.1:8443";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 0;
              proxy_buffering off;
              proxy_request_buffering off;
              proxy_read_timeout 3600s;
            '';
          };
        };
        "${idHost}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://127.0.0.1:8444";
            proxyWebsockets = true;
          };
        };
      };
    };
    kanidm = {
      package = pkgs.kanidm_1_11;
      server = {
        enable = true;
        settings = {
          bindaddress = "127.0.0.1:8444";
          domain = idHost;
          origin = idUrl;
          tls_chain = "/var/lib/acme/${idHost}/fullchain.pem";
          tls_key = "/var/lib/acme/${idHost}/key.pem";
          online_backup = {
            path = "/var/lib/kanidm/backups";
            schedule = "00 22 * * *";
            versions = 7;
          };
        };
      };
      client = {
        enable = true;
        settings = {
          uri = idUrl;
          verify_ca = true;
          verify_hostnames = true;
        };
      };
      provision = {
        enable = true;
        instanceUrl = "https://localhost:8444";
        acceptInvalidCerts = true;
        groups.incus-users = { };
        persons = {
          khuedoan = {
            displayName = "Khue Doan";
            groups = [ "incus-users" ];
          };
        };
        systems.oauth2.incus = {
          displayName = "Incus";
          public = true;
          originUrl = "${cloudUrl}/oidc/callback";
          originLanding = "${cloudUrl}/ui/";
          scopeMaps.incus-users = [
            "openid"
            "profile"
            "email"
          ];
        };
      };
    };
    yggdrasil = {
      enable = true;
      persistentKeys = true;
      settings = {
        Peers = [
          # https://publicpeers.neilalexander.dev
          "quic://asia.deinfra.org:15015" # Singapore
          "quic://yg-hkg.magicum.net:32334" # Hong Kong
          "tls://133.18.201.69:54232" # Japan
        ];
      };
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      certs = {
        "${idHost}" = {
          group = "kanidm";
          reloadServices = [ "kanidm.service" ];
        };
      };
    };
  };

  systemd.services.kanidm = {
    after = [ "acme-${idHost}.service" ];
    requires = [ "acme-${idHost}.service" ];
  };

  virtualisation = {
    incus = {
      enable = true;
      useACMEHost = cloudHost;
      ui = {
        enable = true;
      };
      preseed = {
        config = {
          "core.https_address" = "127.0.0.1:8443";
          "oidc.audience" = "incus";
          "oidc.client.id" = "incus";
          "oidc.issuer" = "${idUrl}/oauth2/openid/incus";
          "oidc.scopes" = "openid,profile,email";
          "user.ui.title" = "HomeCloud";
        };
      };
    };
  };

  users.users = {
    nginx = {
      extraGroups = [ "kanidm" ];
    };
    root = {
      # TODO better way to SSH, maybe without SSH key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5ue4np7cF34f6dwqH1262fPjkowHQ8irfjVC156PCG"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM/WQcPFuzsPmfXSM1GGkIndFcDRirTl5Aqsou8lWPJyUNZOdFt2cWlUkm+Q1F+LFJQ2+YdIXPZlTqhWLF1eWuY= khuedoan@codeserver"
      ];
    };
    admin = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      # TODO better way to SSH, maybe without SSH key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5ue4np7cF34f6dwqH1262fPjkowHQ8irfjVC156PCG"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM/WQcPFuzsPmfXSM1GGkIndFcDRirTl5Aqsou8lWPJyUNZOdFt2cWlUkm+Q1F+LFJQ2+YdIXPZlTqhWLF1eWuY= khuedoan@codeserver"
      ];
    };
  };

  system = {
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "25.05"; # Did you read the comment?
  };
}
