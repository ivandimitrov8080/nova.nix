{ inputs }:
{
  pkgs,
  lib,
  ...
}:
{
  home-manager = {
    backupFileExtension = "bak";
    useUserPackages = true;
    useGlobalPkgs = true;
    users.ivand = { ... }: {
      imports = [
        ./accounts.nix
        (import ./desktop.nix { inherit inputs; })
      ];
      home = {
        username = "ivand";
        homeDirectory = "/home/ivand";
        stateVersion = "26.05";
      };
      programs = {
        ssh.settings = {
          vpsfree-ivand = {
            HostName = "10.0.0.1";
            User = "ivand";
          };
        };
        git = {
          settings = {
            user.name = "Ivan Kirilov Dimitrov";
            user.email = "ivan@idimitrov.dev";
          };
          signing.key = "ED7A E641 69C1 DB37 F48D  68A7 1C27 6C0A 3909 B508";
        };
      };
    };
  };
  hardware.bluetooth.enable = true;
  time.timeZone = "UTC";
  environment = {
    systemPackages = with pkgs; [
      simplex-chat-desktop
    ];
  };
  users = {
    users = {
      ivand = {
        isNormalUser = true;
        createHome = true;
        shell = pkgs.nushell;
        extraGroups = [
          "adbusers"
          "adm"
          "audio"
          "bluetooth"
          "wpa_supplicant"
          "dialout"
          "input"
          "kvm"
          "mlocate"
          "realtime"
          "render"
          "ssh"
          "video"
          "wheel"
          "transmission"
        ];
        hashedPassword = "$y$j9T$Wf9ljhi4c.LUoX/LJEll//$cTP..D/lBWq1PPCzaHhym8V.cibPTjy2JvRYLTf5SZ7";
      };
    };
    extraGroups = {
      realtime = { };
    };
  };
  zramSwap.enable = true;
  systemd.network.networks = lib.genAttrs [ "wlp45s0" "enp47s0" ] (name: {
    matchConfig.Name = name;
    networkConfig.DHCP = "yes";
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
    ipv6AcceptRAConfig.UseDNS = false;
  });
  networking = {
    hostName = "nova";
    firewall.interfaces.wg0 = {
      allowedTCPPorts = [
        26969 # linking port
      ];
      allowedUDPPorts = [
        26969 # linking port
      ];
    };
    wireless = {
      enable = true;
      allowAuxiliaryImperativeNetworks = true;
      userControlled = true;
      networks = {
        "3G".psk = "bumshakalaka";
        "danasol.dn".psk = "hellosunshine";
        "Mzone 301".psk = "Mzone@107";
        "Luna House".psk = "68686868";
        "Gold Time".psk = "goldtime";
      };
    };
    stevenblack = {
      enable = true;
      block = [
        "fakenews"
        "gambling"
      ];
    };
  };
  programs.java.enable = true;
}
