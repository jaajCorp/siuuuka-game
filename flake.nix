{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.android_sdk.accept_license = true;
    };

    godot_version = "4.3-stable";
    godot = pkgs.godot.override {
      version = godot_version;
      hash = "sha256-MzElflwXHWLgPtoOIhPLA00xX8eEdQsexZaGIEOzbj0=";
    };
    export-templates = pkgs.godot-export-templates-bin.override {
      version = godot_version;
      hash = "sha256-9fENuvVqeQg0nmS5TqjCyTwswR+xAUyVZbaKK7Q3uSI=";
    };

    # Android
    androidComposition = pkgs.androidenv.composeAndroidPackages {
      platformVersions = [
        "35"
      ];
      systemImageTypes = ["default"];
      abiVersions = [
        "armeabi-v7a"
        "arm64-v8a"
      ];
      ndkVersion = "25.2.9519653";
      includeNDK = true;
      includeExtras = [
        "extras;google;auto"
      ];
    };
    androidsdk = androidComposition.androidsdk;
    sdk_root = "${androidsdk}/libexec/android-sdk";
    ndk_root = "${sdk_root}/ndk-bundle";
    ndk_path = "${ndk_root}/toolchains/llvm/prebuilt/linux-x86_64/bin";
    java = pkgs.openjdk17-bootstrap;
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        godot
        android-tools
        sdkmanager
        openjdk17-bootstrap
      ];

      JAVA_HOME = java;
      JRE_HOME = java;

      ANDROID_HOME = "${sdk_root}";
      ANDROID_NDK_ROOT = "${ndk_root}";
      NDK_HOME = "${ndk_root}";

      shellHook = ''
        export PATH="${ndk_path}:${androidsdk}/bin:$PATH";
        ln -sf "${export-templates}"/share/godot/export_templates "$HOME"/.local/share/godot/
      '';
    };
  };
}
