{
  description = "SIUUUUUUUUU";

  inputs = { };

  outputs = { self, nixpkgs } @ inputs:
    let
      system = "x86_64-linux"; # whatever your system name is
      pkgs = import nixpkgs {
        system = "x86_64-linux"; # whatever your system name is
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
          android_sdk.accept_license = true;
        };
      };
    in
    {
      devShells.${system}.default = with pkgs; mkShell rec {
        allowUnfree = true;
  
        packages = [
          godot_4
          godot_4-export-templates
          android-tools
          sdkmanager
          openjdk17-bootstrap
        ];
        buildInputs = [
          # android-studio-full         
        ];

        shellHook = ''
          export GODOT4_EXPORT_TEMPLATES=${godot_4-export-templates}
          export JAVA_HOME=${openjdk17-bootstrap}
          export JRE_HOME=${openjdk17-bootstrap}
        '';
      };
    };
}
