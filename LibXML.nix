{ pkgs ? import <nixpkgs> {} }:
 pkgs.mkShellNoCC {
    
    # search on https://raku.land
    MODULE_TO_INSTALL = "LibXML";

    packages = [
      pkgs.gcc
      pkgs.libxml2.dev

      pkgs.rakudo
      pkgs.zef
    ];

    # Avoid this error: Cannot locate native library 'libreadline.so.7': libreadline.so.7: cannot open shared object file: No such file or directory
    # or: Cannot locate native library 'libssl.so': libssl.so: cannot open shared object file: No such file or directory
    # etc.
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
    #  pkgs.readline
    #  pkgs.openssl
    #  pkgs.zlib
      pkgs.libxml2.dev
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
      echo "executing: zef install --debug --deps-only $MODULE_TO_INSTALL"
      zef install --debug --deps-only $MODULE_TO_INSTALL

      # install Module
      echo "executing: zef install --debug $MODULE_TO_INSTALL"
      zef install --debug $MODULE_TO_INSTALL
    '';    
}
