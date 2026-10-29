{
  pkgs,
  config,
  ...
}:
{
  accounts = {
    calendar = {
      accounts.ivand = {
        khal = {
          enable = true;
          color = "light green";
          type = "discover";
        };
        pimsync = {
          enable = true;
          extraPairDirectives = [
            {
              name = "collections";
              params = [ "all" ];
            }
          ];
        };
        remote = {
          passwordCommand = [
            "${pkgs.uutils-coreutils-noprefix}/bin/cat"
            "${config.home.homeDirectory}/.wg_cred"
          ];
          type = "caldav";
          url = "https://dav.idimitrov.dev";
          userName = "ivan@idimitrov.dev";
        };
      };
    };
    contact = {
      accounts.ivand = {
        khal = {
          enable = true;
          color = "light red";
          addresses = [ "ivan@idimitrov.dev" ];
          collections = [ "770000ed-6b2a-4dec-9534-f12bd3f8a482" ];
        };
        khard = {
          enable = true;
          type = "discover";
        };
        pimsync = {
          enable = true;
          extraPairDirectives = [
            {
              name = "collections";
              params = [ "all" ];
            }
          ];
        };
        remote = {
          type = "carddav";
          url = "https://dav.idimitrov.dev";
          userName = "ivan@idimitrov.dev";
          passwordCommand = [
            "${pkgs.uutils-coreutils-noprefix}/bin/cat"
            "${config.home.homeDirectory}/.wg_cred"
          ];
        };
      };
    };
    email = {
      accounts = {
        "ivan@idimitrov.dev" = rec {
          primary = true;
          realName = "Ivan Kirilov Dimitrov";
          address = "ivan@idimitrov.dev";
          userName = address;
          passwordCommand = "${pkgs.uutils-coreutils-noprefix}/bin/cat ${config.home.homeDirectory}/.wg_cred";
          msmtp = {
            enable = true;
            extraConfig = {
              auth = "login";
            };
          };
          signature = {
            text = ''
              Ivan Dimitrov
              Software Developer
              ivan@idimitrov.dev
            '';
            showSignature = "append";
          };
          gpg = {
            encryptByDefault = true;
            signByDefault = true;
            key = "ED7A E641 69C1 DB37 F48D  68A7 1C27 6C0A 3909 B508";
          };
          smtp = {
            host = "mail.idimitrov.dev";
            port = 465;
            authentication = "login";
          };
          imap = {
            host = "mail.idimitrov.dev";
            authentication = "login";
          };
          notmuch.enable = true;
          mbsync = {
            enable = true;
            create = "both";
          };
        };
      };
    };
  };
  services = {
    mbsync = {
      enable = true;
      frequency = "*:0/1";
      postExec = "${pkgs.notmuch}/bin/notmuch new";
    };
    pimsync.enable = true;
  };
  programs = {
    notmuch = {
      enable = true;
      hooks = {
        postNew = ''
          ${pkgs.notmuch-ics-import}/bin/notmuch-ics-import
          afew --tag --new
        '';
      };
      settings = {
        new = {
          tags = [ "new" ];
        };
        search.excludeTags = [
          "trash"
          "spam"
        ];
      };
    };
    pimsync.enable = true;
    msmtp.enable = true;
    mbsync.enable = true;
    khal = {
      enable = true;
      settings.default.default_calendar = "ivand1";
      locale = {
        dateformat = "%Y-%m-%d";
        longdateformat = "%Y-%m-%d";
        timeformat = "%H:%M";
      };
    };
    khard.enable = true;
    afew = {
      enable = true;
      extraConfig =
        let
          spammers = [
            "linkedin.com"
            "grafana.com"
            "bg.econcast.net"
            "ticketportal.cz"
            "uber.com"
            "brightdata.com"
            "cal.com"
            "rkc.edu"
            "office1.bg"
            "github.com"
            "snowflake.com"
            "proxify.io"
            "toptal.com"
            "onetravelspecials.com"
            "redglobal.com"
            "b4b-inkasso.com"
            "agoda.com"
          ];
        in
        ''
          [SpamFilter]

          [Filter.0]
          message = Delete all messages from spammers
          query = ${builtins.concatStringsSep " " (map (x: "from:*@${x}") spammers)}
          tags = +spam;-inbox;-unread

          [InboxFilter]
        '';
    };
  };
}
