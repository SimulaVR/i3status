{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/63dacb46bf939521bdc93981b4cbb7ecb58427a0";
    systems.url = "github:nix-systems/x86_64-linux";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, lib, ... }:
        let
          i3status = pkgs.stdenv.mkDerivation rec {
            pname = "i3status";
            version = "2.13";
            src = lib.cleanSource ./.;

            nativeBuildInputs = [
              pkgs.pkg-config
              pkgs.asciidoc
              pkgs.xmlto
              pkgs.docbook_xml_dtd_45
              pkgs.docbook_xsl
            ];

            buildInputs = [
              pkgs.libconfuse
              pkgs.yajl
              pkgs.libpulseaudio
              pkgs.libnl
              pkgs.alsa-lib
            ];

            makeFlags = [
              "all"
              "PREFIX=$(out)"
            ];

            # This hack is needed because for unknown reasons configure generates a broken makefile on the 2.13 release under nixos
            preBuild = ''
              sed -i -e 's/\$(TEST_LOGS) \$(TEST_LOGS/\$(TEST_LOGS)/g' Makefile
            '';

            meta = {
              description = "Generates a status line for i3bar, dzen2, xmobar or lemonbar";
              homepage = "https://i3wm.org";
              license = lib.licenses.bsd3;
              platforms = [ "x86_64-linux" ];
            };
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };

          packages = {
            inherit i3status;
            default = i3status;
          };

          devShells.default = pkgs.mkShell rec {
            nativeBuildInputs = [
              # Development tools
              pkgs.nil
            ];

            shellHook = ''
              export PS1="\n[nix-shell:\w]$ "
            '';
          };
        };
    };
}
