{ pkgs ? import <nixpkgs> {} }:

 pkgs.mkShellNoCC {
    packages = [
      pkgs.rakudo
      pkgs.zef
    ];

    # Avoid this error: Cannot locate native library 'libreadline.so.7': libreadline.so.7: cannot open shared object file: No such file or directory
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.readline70
    ];

    shellHook = ''
      zef update
      zef install Readline
    '';    
}
