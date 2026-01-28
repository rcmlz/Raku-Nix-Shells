{ pkgs ? import <nixpkgs> {} }:
let
  buildEnvPackages = [
      pkgs.gcc
      pkgs.gnumake
      pkgs.libxml2

      pkgs.rakudo
      pkgs.zef
    ];
in pkgs.mkShell {
    
    # search on https://raku.land
    MODULE_TO_INSTALL = "LibXML:ver<0.10.19>:auth<zef:dwarring>:api<0.10.0>";
    CUSTOM_INSTALL_FLAGS = "";
#    CUSTOM_INSTALL_FLAGS = "--exclude='curl'";

    packages = buildEnvPackages;
#    buildInputs = buildEnvPackages;
#    propagatedBuildInputs = buildEnvPackages;

    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.libxml2
    ];

    # Set zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;
    
    shellHook = ''
      echo 'executing: PATH=$HOME/.raku/bin:$PATH'
      export PATH=$HOME/.raku/bin:$PATH

      echo 'executing: raku --version'
      raku --version

      echo 'executing: zef --version'
      zef --version

      echo 'executing: zef update'
      zef update

      # install only dependencies
      echo "executing: zef install --debug --deps-only $MODULE_TO_INSTALL $CUSTOM_INSTALL_FLAGS" 
      zef install --debug --deps-only $MODULE_TO_INSTALL $CUSTOM_INSTALL_FLAGS
      
      # install Module
      echo "executing: zef install --debug $MODULE_TO_INSTALL $CUSTOM_INSTALL_FLAGS"
      zef install --debug $MODULE_TO_INSTALL $CUSTOM_INSTALL_FLAGS
    '';    
}
