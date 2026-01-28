{ pkgs ? import <nixpkgs> {} }:
 pkgs.mkShellNoCC {
    packages = [
      pkgs.git
      pkgs.curl
      pkgs.wget
      pkgs.gcc
      pkgs.gnumake
      pkgs.readline70
      pkgs.cacert
      pkgs.rakudo
      pkgs.zef
      pkgs.zlib
      pkgs.openssl        
      pkgs.zeromq
      (pkgs.jupyter-all.withPackages(ps: with ps; [
        distutils
        pip
        notebook
        jupyter-console
        jupytext
        jupyterlab-lsp
        jedi-language-server
      ]))
      pkgs.vscodium
      pkgs.firefox
    ];

    # Avoid this error: Cannot locate native library 'libreadline.so.7': libreadline.so.7: cannot open shared object file: No such file or directory
    # or: Cannot locate native library 'libssl.so': libssl.so: cannot open shared object file: No such file or directory
    # etc.
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.readline
      pkgs.openssl
      pkgs.zlib
      pkgs.zeromq
    ];

    # Set zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;

    shellHook = ''
      echo including $HOME/.raku/bin in PATH
      export PATH="$HOME/.raku/bin:$PATH"

      export JUPYTER_KERNEL_DIR=$(jupyter --data)/kernels/raku            
      if [ -d "$JUPYTER_KERNEL_DIR" ]; then
        echo "Skipping kernel creation and module installation, '$JUPYTER_KERNEL_DIR' already exists"
        echo "to trigger a fresh installation, delete the kernel directory: 'rm -rf $JUPYTER_KERNEL_DIR'"
      else
        echo "Initializing kernel and module installation"
        echo Updating zef
        zef update
        
        echo "installing Jupyter::Kernel:ver<1.0.3>:auth<zef:bduggan>"
        zef --serial --debug install "Jupyter::Kernel:ver<1.0.3>:auth<zef:bduggan>"
      
        echo "Creating Raku kernel in path: '$JUPYTER_KERNEL_DIR'"
        raku-jupyter-kernel --generate-config --location=$JUPYTER_KERNEL_DIR
      fi
      
      #echo listing all jupyter paths
      #jupyter --paths
      
      jupyter-lab --notebook-dir=$HOME
    '';
}
