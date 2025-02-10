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
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
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

    # FIXME: disable this if you don't want to use the starship prompt
    starship.enable = true;
    starship.settings = {
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
    };

    # FIXME: disable whatever you don't want
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
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
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
      # run 'scoop install win32yank' on Windows, then add this line with your Windows username to the bottom of interactiveShellInit
      # fish_add_path --append /mnt/c/Users/<Your Windows Username>/scoop/apps/win32yank/0.1.1
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

    # Oxocarbon Dark Theme (Inline)
        ${pkgs.lib.strings.concatStringsSep "\n" [
          "# Scheme: Oxocarbon Dark"
          "# Author: shaunsingh/IBM"

          "set -l base00 \"161616\""
          "set -l base01 \"262626\""
          "set -l base02 \"393939\""
          "set -l base03 \"525252\""
          "set -l base04 \"dde1e6\""
          "set -l base05 \"f2f4f8\""
          "set -l base06 \"ffffff\""
          "set -l base07 \"08bdba\""
          "set -l base08 \"3ddbd9\""
          "set -l base09 \"78a9ff\""
          "set -l base0A \"ee5396\""
          "set -l base0B \"33b1ff\""
          "set -l base0C \"ff7eb6\""
          "set -l base0D \"42be65\""
          "set -l base0E \"be95ff\""
          "set -l base0F \"82cfff\""

          "set fish_color_normal \$base05"
          "set fish_color_command \$base0D"
          "set fish_color_quote \$base0A"
          "set fish_color_redirection \$base05"
          "set fish_color_end \$base09"
          "set fish_color_error \$base08"
          "set fish_color_param \$base05"
          "set fish_color_comment \$base03"
          "set fish_color_match --background=\$base02"
          "set fish_color_search_match --background=\$base02"
          "set fish_color_operator \$base0C"
          "set fish_color_escape \$base0C"
          "set fish_color_cwd \$base0B"
          "set fish_color_cwd_root \$base08"
          "set fish_color_valid_path --underline"
          "set fish_color_autosuggestion \$base03"
          "set fish_pager_color_prefix \$base0B"
          "set fish_pager_color_completion \$base05"
          "set fish_pager_color_description \$base03"
          "set fish_pager_color_progress \$base03"
          "set fish_pager_color_selected_background --background=\$base02"
          "set __fish_highlight_color \$base02"
        ]}

    fish_add_path --append /mnt/c/Users/joshj/scoop/apps/win32yank/current
    set -U fish_greeting
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
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
      shellAbbrs =
        {
          gc = "nix-collect-garbage --delete-old";
        }
        # navigation shortcuts
        // {
          ".." = "cd ..";
          "..." = "cd ../../";
          "...." = "cd ../../../";
          "....." = "cd ../../../../";
        }
        # git shortcuts
        // {
          gapa = "git add --patch";
          grpa = "git reset --patch";
          gst = "git status";
          gdh = "git diff HEAD";
          gp = "git push";
          gph = "git push -u origin HEAD";
          gco = "git checkout";
          gcob = "git checkout -b";
          gcm = "git checkout master";
          gcd = "git checkout develop";
          gsp = "git stash push -m";
          gsa = "git stash apply stash^{/";
          gsl = "git stash list";
        };
      shellAliases = {
        jvim = "nvim";
        lvim = "nvim";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";

        # To use code as the command, uncomment the line below. Be sure to replace [my-user] with your username.
        # If your code binary is located elsewhere, adjust the path as needed.
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
