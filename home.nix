{
# uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
# secrets,
pkgs,
username,
nix-index-database,
...
}: let
  unstable-packages = with pkgs.unstable; [
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    tmux
    tree
    unzip
    vim
    wget
    zip
  ];

  stable-packages = with pkgs; [
    # key tools
    gh # for bootstrapping
    just

    # core languages
    rustup

    # rust stuff
    cargo-cache
    cargo-expand

    # cpp
    ccls
    gcc
    lldb

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix

    # misc
    qmk
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish"; # This line is likely redundant and can cause issues, remove it
  };

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # you can add anything else that doesn't fit into the above two lists in here
    [
      pkgs.siovim
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ];

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        # Basic settings
        aws.disabled = true;
        gcloud.disabled = true;
        kubernetes.disabled = false;
        git_branch.style = "242";
        directory.style = "blue";
        directory.truncate_to_repo = false;
        directory.truncation_length = 8;
        python.disabled = true;
        ruby.disabled = true;
        hostname.ssh_only = false;
        hostname.style = "bold green";

        # Character configuration with bright magenta
        character = {
          success_symbol = "[❯](bright-purple)";  # Using bright-purple for magenta
          error_symbol = "[❯](red)";
          vicmd_symbol = "[❯](green)";
          vimcmd_replace_one_symbol = "[❯](red)";
          vimcmd_replace_symbol = "[❯](red)";
          vimcmd_visual_symbol = "[❯](yellow)";
        };

        # Format specification
        format = "$all";
        add_newline = false;
      };
    };

    fzf.enable = true;
    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = ["--cmd cd"];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "joshj.tx@gmail.com";
      userName = "josh-j";
      extraConfig = {
        # FIXME: uncomment the next lines if you want to be able to clone private https repos
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
        fish_add_path --append /mnt/c/Users/joshj/scoop/apps/win32yank/current
        set -U fish_greeting
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";  # Keep this, but be CAREFUL. See note below.
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
      };
      shellAbbrs = {
        gc = "nix-collect-garbage --delete-old";
      };

      # Removed navigation and git shortcuts, as starship and zoxide handle most of this

      shellAliases = {
        jvim = "nvim";
        lvim = "nvim";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
        code = "/mnt/c/Users/joshj/AppData/Local/Programs/'Microsoft VS Code'/bin/code";
      };
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ];
    };
  };
}
