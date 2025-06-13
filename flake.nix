{
  description = "Development environment with multimedia and desktop tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Shell
            fish
            
            # Fonts and Icons
            material-icons
            nerd-fonts.jetbrains-mono
            ibm-plex
            material-design-icons
            
            # Python packages
            python312Packages.aubio
            python312Packages.pyaudio
            python312Packages.numpy
            python312Packages.materialyoucolor
            
            # System utilities
            ddcutil
            xdg-user-dirs
            socat
            
            # Wayland/Hyprland tools
            hyprpaper
            fuzzel
            wayfreeze
            wl-screenrec
          ];

          shellHook = ''
            echo "Development environment loaded!"
            echo "Available tools: fish, fonts, Python audio packages, Wayland utilities"
          '';
        };
      });
}
