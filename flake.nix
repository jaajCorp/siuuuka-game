{
  description = "SIUUUUUUUUU";

  inputs = { };

  outputs = { self, nixpkgs } @ inputs:
    let
      system = "x86_64-linux"; # whatever your system name is
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = with pkgs; mkShell rec {
        packages = [
          godot_4
          android-tools
          sdkmanager
          openjdk17-bootstrap
        ];

        shellHook = ''
          export JAVA_HOME=${openjdk17-bootstrap}
          export JRE_HOME=${openjdk17-bootstrap}
          export ANDROID_HOME=~/.local/share/android-sdk

          sdkmanager --sdk_root="$ANDROID_HOME" "platform-tools" "build-tools;33.0.2" "platforms;android-33" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;23.2.8568313"
          sed -i '1s|#!/bin/bash|#!/usr/bin/env bash|' "$ANDROID_HOME"/build-tools/*/apksigner # FIX: Ugly AF
        '';
      };
    };
}
