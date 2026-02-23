{
  flake.aspects.shell = {
    homeManager = {
      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          right_format = "$time";
          hostname = {
            ssh_only = true;
            detect_env_vars = [
              "!TMUX"
              "SSH_CONNECTION"
            ];
          };
          time = {
            disabled = false;
            use_12hr = true;
          };
          os.disabled = false;
          aws = {
            symbol = " ";
          };
          buf = {
            symbol = " ";
          };
          bun = {
            symbol = " ";
          };
          c = {
            symbol = " ";
          };
          cpp = {
            disabled = false;
            symbol = " ";
          };
          cmake = {
            symbol = " ";
          };
          conda = {
            symbol = " ";
          };
          crystal = {
            symbol = " ";
          };
          dart = {
            symbol = " ";
          };
          deno = {
            symbol = " ";
          };
          directory = {
            read_only = " 󰌾";
          };
          docker_context = {
            symbol = " ";
          };
          elixir = {
            symbol = " ";
          };
          elm = {
            symbol = " ";
          };
          fennel = {
            symbol = " ";
          };
          fortran = {
            symbol = " ";
          };
          fossil_branch = {
            symbol = " ";
          };
          gcloud = {
            symbol = " ";
          };
          git_branch = {
            symbol = " ";
          };
          git_commit = {
            tag_symbol = "  ";
          };
          golang = {
            symbol = " ";
          };
          gradle = {
            symbol = " ";
          };
          guix_shell = {
            symbol = " ";
          };
          haskell = {
            symbol = " ";
          };
          haxe = {
            symbol = " ";
          };
          hg_branch = {
            symbol = " ";
          };
          hostname = {
            ssh_symbol = " ";
          };
          java = {
            symbol = " ";
          };
          julia = {
            symbol = " ";
          };
          kotlin = {
            symbol = " ";
          };
          lua = {
            symbol = " ";
          };
          memory_usage = {
            symbol = "󰍛 ";
          };
          meson = {
            symbol = "󰔷 ";
          };
          nim = {
            symbol = "󰆥 ";
          };
          nix_shell = {
            symbol = " ";
          };
          nodejs = {
            symbol = " ";
          };
          ocaml = {
            symbol = " ";
          };
          os.symbols = {
            Alpaquita = " ";
            Alpine = " ";
            AlmaLinux = " ";
            Amazon = " ";
            Android = " ";
            AOSC = " ";
            Arch = " ";
            Artix = " ";
            CachyOS = " ";
            CentOS = " ";
            Debian = " ";
            DragonFly = " ";
            Elementary = " ";
            Emscripten = " ";
            EndeavourOS = " ";
            Fedora = " ";
            FreeBSD = " ";
            Garuda = "󰛓 ";
            Gentoo = " ";
            HardenedBSD = "󰞌 ";
            Illumos = "󰈸 ";
            Ios = "󰀷 ";
            Kali = " ";
            Linux = " ";
            Mabox = " ";
            Macos = " ";
            Manjaro = " ";
            Mariner = " ";
            MidnightBSD = " ";
            Mint = " ";
            NetBSD = " ";
            NixOS = " ";
            Nobara = " ";
            OpenBSD = "󰈺 ";
            openSUSE = " ";
            OracleLinux = "󰌷 ";
            Pop = " ";
            Raspbian = " ";
            Redhat = " ";
            RedHatEnterprise = " ";
            RockyLinux = " ";
            Redox = "󰀘 ";
            Solus = "󰠳 ";
            SUSE = " ";
            Ubuntu = " ";
            Unknown = " ";
            Void = " ";
            Windows = "󰍲 ";
            Zorin = " ";
          };
          package = {
            symbol = "󰏗 ";
          };
          perl = {
            symbol = " ";
          };
          php = {
            symbol = " ";
          };
          pijul_channel = {
            symbol = " ";
          };
          pixi = {
            symbol = "󰏗 ";
          };
          python = {
            symbol = " ";
          };
          rlang = {
            symbol = "󰟔 ";
          };
          ruby = {
            symbol = " ";
          };
          rust = {
            symbol = "󱘗 ";
          };
          scala = {
            symbol = " ";
          };
          status = {
            symbol = " ";
          };
          swift = {
            symbol = " ";
          };
          xmake = {
            symbol = " ";
          };
          zig = {
            symbol = " ";
          };
        };
      };
    };
  };
}
