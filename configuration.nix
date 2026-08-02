{ pkgs, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

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
    networkmanager = {
      enable = true;
    };
    nftables = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        8443 # TODO incus
      ];
      trustedInterfaces = [
        "incusbr0"
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
    kanidm = {
      package = pkgs.kanidm_1_10;
      server = {
        enable = true;
        settings = {
          bindaddress = "127.0.0.1:8444";
          domain = "id.cloud.khuedoan.com";
          origin = "https://id.cloud.khuedoan.com";
          tls_chain = "/var/lib/acme/id.cloud.khuedoan.com/fullchain.pem";
          tls_key = "/var/lib/acme/id.cloud.khuedoan.com/key.pem";
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
          uri = "https://id.cloud.khuedoan.com";
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
          originUrl = "https://cloud.khuedoan.com/oidc/callback";
          originLanding = "https://cloud.khuedoan.com/ui/";
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

  virtualisation = {
    incus = {
      enable = true;
      ui = {
        enable = true;
      };
      preseed = {
        config = {
          "core.https_address" = ":8443";
          "user.ui.title" = "HomeCloud";
        };
        networks = [
          {
            name = "incusbr0";
            project = "default";
            type = "bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv6.address" = "auto";
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "btrfs";
            config = {
              size = "30GiB"; # TODO auto?
            };
          }
        ];
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];
      };
    };
  };

  users.users = {
    root = {
      # TODO better way to SSH, maybe without SSH key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5ue4np7cF34f6dwqH1262fPjkowHQ8irfjVC156PCG"
      ];
    };
    admin = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      # TODO better way to SSH, maybe without SSH key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5ue4np7cF34f6dwqH1262fPjkowHQ8irfjVC156PCG"
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
