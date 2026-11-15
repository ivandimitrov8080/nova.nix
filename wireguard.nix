{
  custom.wireguard = {
    enable = true;
    killswitch = true;
    ips = [ "10.0.0.2/32" ];
    privateKeyFile = "/etc/systemd/network/wg0.key";
    peers = [
      {
        name = "vpsfree";
        publicKey = "iRSHYRPRELX8lJ2eHdrEAwy5ZW8f5b5fOiIGhHQwKFg=";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "37.205.13.29:51820";
        persistentKeepalive = 7;
      }
    ];
  };
}
