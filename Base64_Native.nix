{ pkgs ? import <nixpkgs> {} }:
let
  # ===> Building [FAIL]: Base64::Native:ver<0.0.10>:auth<zef:dwarring>
  # make: *** [Makefile:14: resources/libraries/libbase64.so] Fehler 1
  # [Base64::Native] The spawned command 'make' exited unsuccessfully (exit code: 2, signal: 0)

  # the module's Makefile explicitly invokes ld, so overriding the default Make linker variable has no effect.
  # We need to intercept the linker invocation or patch the Makefile.
  ld-wrapper = pkgs.writeShellScriptBin "ld" ''
    exec ${pkgs.stdenv.cc}/bin/cc "$@"
  '';
in
pkgs.mkShell {
  packages = with pkgs; [
    rakudo
    zef
    gcc
    gnumake
    binutils
  ];

  # Avoid this error: Failed to find dependencies: curl:ver<4>:from<native> 
  # Failed to resolve some missing dependencies (use e.g. --exclude="curl" to skip)
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
        pkgs.curl
        pkgs.readline
        pkgs.openssl.dev
  ];
  
  # this is not sufficient - we need to intercept ld
  MAKEFLAGS = "LD=${pkgs.stdenv.cc}/bin/cc";

  # Set zef environment variables
  ZEF_FETCH_DEGREE = 4;
  ZEF_TEST_DEGREE = 4;
  
  shellHook = ''
      export PATH="${ld-wrapper}/bin:$PATH"
      export PATH=$HOME/.raku/bin:$PATH
      zef install --debug Base64::Native 
    '';    
}
