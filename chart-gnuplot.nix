{ pkgs ? import <nixpkgs> {} }:
let
  buildEnvPackages = [
      pkgs.rakudo
      pkgs.zef
      
      pkgs.readline70
      pkgs.rlwrap
      pkgs.zlib
      
      pkgs.gnuplot
    ];
in
 pkgs.mkShell {
    packages = buildEnvPackages;
    buildInputs = buildEnvPackages;
    propagatedBuildInputs = buildEnvPackages;
    
    # Set some zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;

    # Avoid this error: Cannot locate native library 'libreadline.so.7': libreadline.so.7: cannot open shared object file: No such file or directory
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.readline70
    ];

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
      echo "executing: zef install --debug --deps-only Chart::Gnuplot"
      zef install --debug --deps-only Chart::Gnuplot

      # install Chart::Gnuplot - no build as we intend to use the NixOS-installed gnuplot
      echo "executing: zef install --debug --/build Chart::Gnuplot"
      zef install --debug --/build Chart::Gnuplot
    '';
}
    