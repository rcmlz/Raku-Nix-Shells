{ pkgs ? import <nixpkgs> {} }:
let
  buildEnvPackages = [
      pkgs.rakudo
      pkgs.zef
    ];
in
 pkgs.mkShell {
    packages = buildEnvPackages;
    buildInputs = buildEnvPackages;
    propagatedBuildInputs = buildEnvPackages;
    
    # Set some zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;

    # Avoid this error: Cannot locate native library 'libssl.so': libssl.so: cannot open shared object file: No such file or directory
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.openssl
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
      echo "executing: zef install --deps-only IO::Socket::SSL"
      zef install --deps-only IO::Socket::SSL

      # install IO::Socket::SSL
      echo "executing: zef install IO::Socket::SSL"
      zef install IO::Socket::SSL
    '';
}

