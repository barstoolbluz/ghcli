{
  description = "ghcli: GitHub CLI environment with secure token management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ghcli-runtime = {
      url = "github:barstoolbluz/package-ghcli-runtime";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ghcli-runtime }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ghx = ghcli-runtime.packages.${system}.ghx;

          runtimePackages = [
            ghx
            pkgs.gh
            pkgs.git
            pkgs.gum
            pkgs.bat
            pkgs.curl
            pkgs.openssl
            pkgs.gnused
            pkgs.gawk
            pkgs.gnugrep
            pkgs.coreutils
            pkgs.jq
            pkgs.flock
            pkgs.openssh
            pkgs.bash
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.libsecret
          ];

          shellHook = builtins.readFile ./nix/shell-hook.sh;
          bashProfile = builtins.readFile ./nix/profile-bash.sh;
          zshProfile = builtins.readFile ./nix/profile-zsh.sh;
          fishProfile = builtins.readFile ./nix/profile-fish.sh;

          # Shell launcher scripts for zsh and fish
          ghcli-zsh = pkgs.writeShellScriptBin "ghcli-zsh" ''
            export PATH="${pkgs.lib.makeBinPath runtimePackages}:$PATH"
            ${shellHook}
            _ghcli_zshrc="$(mktemp -d)/ghcli-zshrc"
            mkdir -p "$_ghcli_zshrc"
            cat > "$_ghcli_zshrc/.zshrc" << 'ZSHEOF'
            [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
            ${zshProfile}
            ZSHEOF
            ZDOTDIR="$_ghcli_zshrc" exec ${pkgs.zsh}/bin/zsh "$@"
          '';

          ghcli-fish = pkgs.writeShellScriptBin "ghcli-fish" ''
            export PATH="${pkgs.lib.makeBinPath runtimePackages}:$PATH"
            ${shellHook}
            exec ${pkgs.fish}/bin/fish --init-command '${fishProfile}' "$@"
          '';
        in {
          default = pkgs.mkShell {
            packages = runtimePackages;
            shellHook = ''
              ${shellHook}
              ${bashProfile}
            '';
          };

          zsh = pkgs.mkShell {
            packages = runtimePackages ++ [ pkgs.zsh ];
            shellHook = ''
              ${shellHook}
              ${zshProfile}
              _ghcli_zshrc="$(mktemp -d)/ghcli-zshrc"
              mkdir -p "$_ghcli_zshrc"
              cat > "$_ghcli_zshrc/.zshrc" << 'ZSHEOF'
              [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
              ${zshProfile}
              ZSHEOF
              ZDOTDIR="$_ghcli_zshrc" exec ${pkgs.zsh}/bin/zsh
            '';
          };

          fish = pkgs.mkShell {
            packages = runtimePackages ++ [ pkgs.fish ];
            shellHook = ''
              ${shellHook}
              exec ${pkgs.fish}/bin/fish --init-command '${fishProfile}'
            '';
          };
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ghx = ghcli-runtime.packages.${system}.ghx;

          runtimePackages = [
            ghx
            pkgs.gh
            pkgs.git
            pkgs.gum
            pkgs.bat
            pkgs.curl
            pkgs.openssl
            pkgs.gnused
            pkgs.gawk
            pkgs.gnugrep
            pkgs.coreutils
            pkgs.jq
            pkgs.flock
            pkgs.openssh
            pkgs.bash
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.libsecret
          ];

          shellHook = builtins.readFile ./nix/shell-hook.sh;
          bashProfile = builtins.readFile ./nix/profile-bash.sh;
          zshProfile = builtins.readFile ./nix/profile-zsh.sh;
          fishProfile = builtins.readFile ./nix/profile-fish.sh;

          ghcli-bash = pkgs.writeShellScriptBin "ghcli-bash" ''
            export PATH="${pkgs.lib.makeBinPath runtimePackages}:$PATH"
            ${shellHook}
            ${bashProfile}
            exec ${pkgs.bash}/bin/bash "$@"
          '';

          ghcli-zsh = pkgs.writeShellScriptBin "ghcli-zsh" ''
            export PATH="${pkgs.lib.makeBinPath runtimePackages}:$PATH"
            ${shellHook}
            _ghcli_zshrc="$(mktemp -d)/ghcli-zshrc"
            mkdir -p "$_ghcli_zshrc"
            cat > "$_ghcli_zshrc/.zshrc" << 'ZSHEOF'
            [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
            ${zshProfile}
            ZSHEOF
            ZDOTDIR="$_ghcli_zshrc" exec ${pkgs.zsh}/bin/zsh "$@"
          '';

          ghcli-fish = pkgs.writeShellScriptBin "ghcli-fish" ''
            export PATH="${pkgs.lib.makeBinPath runtimePackages}:$PATH"
            ${shellHook}
            exec ${pkgs.fish}/bin/fish --init-command '${fishProfile}' "$@"
          '';
        in {
          default = {
            type = "app";
            program = "${ghcli-bash}/bin/ghcli-bash";
            meta.description = "bash with gh, git, and ghcli token management";
          };
          zsh = {
            type = "app";
            program = "${ghcli-zsh}/bin/ghcli-zsh";
            meta.description = "zsh with gh, git, and ghcli token management";
          };
          fish = {
            type = "app";
            program = "${ghcli-fish}/bin/ghcli-fish";
            meta.description = "fish with gh, git, and ghcli token management";
          };
        }
      );

      packages = forAllSystems (system: {
        ghx = ghcli-runtime.packages.${system}.ghx;
        default = ghcli-runtime.packages.${system}.ghx;
      });
    };
}
