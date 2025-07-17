{ pkgs ? import <nixpkgs> {} }:
let
  # Your API keys
  OPENAI  = "read https://raku.land/zef:antononcube/Jupyter::Chatbook";
  PALM = "find help at https://github.com/antononcube/Raku-Jupyter-Chatbook";
  GEMINI  = "have a look at https://docs.raku.org";
  MISTRAL  = "use https://course.raku.org/";
  DEEPL  = "browse https://raku.org/getting-started/";
  WOLFRAM  = "visit https://rosettacode.org/wiki/Category:Raku";
in
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
      pkgs.readline70
      pkgs.openssl
      pkgs.zlib
      pkgs.zeromq
    ];

    # Set zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;

    # Set your API keys
    OPENAI_API_KEY = OPENAI;
    PALM_API_KEY = PALM;
    GEMINI_API_KEY  = GEMINI;
    MISTRAL_API_KEY  = MISTRAL;
    DEEPL_AUTH_KEY  = DEEPL;
    WOLFRAM_ALPHA_API_KEY  = WOLFRAM;
    
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
        
        echo installing all Raku modules listed in jupyter-chatbook-modules.txt from https://raku.land using zef
        cat jupyter-chatbook-modules.txt | raku -e 'for $*IN.lines.grep(/^^\w/) { say shell "zef --serial --debug install \"$_\"" }'
      
        echo "Creating Raku kernel in path: '$JUPYTER_KERNEL_DIR'"
        jupyter-chatbook.raku --generate-config
      fi

      echo ""
      echo "######################################"
      echo "# API keys set:"
      echo "# OPENAI: $OPENAI_API_KEY"
      echo "# PALM: $PALM_API_KEY"
      echo "# GEMINI: $GEMINI_API_KEY"
      echo "# MISTRAL: $MISTRAL_API_KEY"
      echo "# DEEPL: $DEEPL_AUTH_KEY"
      echo "# WOLFRAM: $WOLFRAM_ALPHA_API_KEY"
      echo "######################################"
      echo ""
      
      #echo listing all jupyter paths
      #jupyter --paths
      
      echo in order to test the jupyter-chatbook kernel and e.g. your OPEN-AI API key, 
      echo create a new RakuChatbook and execute in a code cell
      echo "---------snip-----------"
      echo ""
      echo "#% openai"
      echo "Randomly generate 3 dog names and 4 cat names."
      echo ""
      echo "---------snip-----------"
      
      echo starting codium
      codium -a . jupyter-chatbook.ipynb &

      echo pause 5 seconds, then starting jupyter lab
      sleep 5s
      jupyter-lab --notebook-dir=$HOME jupyter-chatbook.ipynb
    '';    
}
