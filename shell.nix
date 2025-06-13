{ pkgs ? import <nixpkgs> {} }:

let
  material-symbols-variable = pkgs.stdenv.mkDerivation rec {
    pname = "ttf-material-symbols-variable";
    version = "4.0.0.r119.gc51274e9";
    
    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "material-design-icons";
      rev = "c51274e9";
      sha256 = "sha256-ueh8y6gSs0JfOLzumK09mdc2ZqxXUOQDkAIMGyLCHkc="; # Update with real hash
    };
    
    dontBuild = true;
    
    installPhase = ''
      mkdir -p $out/share/fonts/ttf-material-symbols-variable
      
      # Install only variable TTF fonts (matching package_ttf-material-symbols-variable-git)
      find . -name "*wght*.ttf" -exec cp {} $out/share/fonts/ttf-material-symbols-variable/ \;
    '';
    
    meta = with pkgs.lib; {
      description = "Material Design icons by Google - variable fonts";
      homepage = "https://github.com/google/material-design-icons";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  };

in pkgs.mkShell {
  buildInputs = [ material-symbols-variable ];
  
  shellHook = ''
    echo "Material Symbols Variable TTF fonts installed:"
    echo "${material-symbols-variable}/share/fonts/ttf-material-symbols-variable/"
    
    # Update font cache
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f
    fi
  '';
}
