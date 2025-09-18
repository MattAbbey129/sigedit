# SPDX-License-Identifier: MIT
# Copyright © 2025 Matt Abbey

{

  description = "Write and sign messages with your GPG key using your favorite text editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = import nixpkgs { inherit lib; };
        myBuildInputs = with pkgs; [ bash coreutils gnupg ];
        myName = "sigedit";
        myScript = (pkgs.writeScriptBin myName (builtins.readFile ./script.bash)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        packages.default = packages.myScript;
        packages.myScript = pkgs.symlinkJoin {
          name = myName;
          paths = [ myScript ] ++ myBuildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${myName} --prefix PATH : $out/bin";
        };
        apps.default = with lib; {
          type = "app";
          program = "${packages.myScript}/bin/sigedit";
          meta = with self; {
            mainProgram = "${self}/bin/sigedit";
            description = "Write and sign messages with your GPG key using your favorite text editor";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };
      }
    );

}
