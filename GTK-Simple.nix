{ pkgs ? import <nixpkgs> {} }:
let
  buildEnvPackages = [
      pkgs.gtk3
      pkgs.glib

      pkgs.rakudo
      pkgs.zef
    ];
in pkgs.mkShell {
    
    # search on https://raku.land
    MODULE_TO_INSTALL = "GTK::Simple:ver<0.3.0>:auth<zef:finanalyst>";
    CUSTOM_INSTALL_FLAGS = "";

    packages = buildEnvPackages;
    #buildInputs = buildEnvPackages;
    #propagatedBuildInputs = buildEnvPackages;

    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
       pkgs.glib
       pkgs.gtk3
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
      
      # install module
      echo "executing: zef install --debug $MODULE_TO_INSTALL $CUSTOM_INSTALL_FLAGS"
      zef install --debug $MODULE_TO_INSTALL $CUSTOM_INSTALL_FLAGS
    '';    
}
