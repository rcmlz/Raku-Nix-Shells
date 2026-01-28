{ pkgs ? import <nixpkgs> {} }:
let
  myPython = (pkgs.python3.withPackages (p: with p; [
          numpy
          matplotlib
          pandas
          requests
          pip
      ]));

  buildEnvPackages = [
      # https://nixos.wiki/wiki/Raku
      pkgs.rakudo
      pkgs.zef
      
      # https://github.com/niner/Inline-Python
      # https://raku.land/zef:slavenskoj/Inline::Python3
      # https://semyonsinchenko.github.io/ssinchenko/post/using-pyenv-with-nixos/
      pkgs.gcc
      pkgs.gnumake
      pkgs.zlib
      pkgs.libffi
      pkgs.readline
      pkgs.bzip2
      pkgs.openssl
      pkgs.ncurses
      myPython
    ];
in pkgs.mkShell {
    
    # search on https://raku.land
    MODULE_TO_INSTALL = "Inline::Python:ver<0.5>:auth<cpan:NINE>";
    CUSTOM_INSTALL_FLAGS = "--exclude='python3'";
    
    packages = buildEnvPackages;
    buildInputs = buildEnvPackages;
    propagatedBuildInputs = buildEnvPackages;
    
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.readline
      pkgs.openssl
      pkgs.zlib
      pkgs.gcc
      pkgs.gnumake
      pkgs.zlib
      pkgs.libffi
      pkgs.bzip2
      pkgs.ncurses
      myPython
    ];

    # Set zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;

    shellHook = ''
      echo "#################################"
      echo "# $MODULE_TO_INSTALL"
      echo "#################################"

      echo 'executing: PATH=$HOME/.raku/bin:$PATH'
      export PATH=$HOME/.raku/bin:$PATH

      echo 'executing: python --version'
      python --version

      echo 'executing: pip --version'
      pip --version

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
