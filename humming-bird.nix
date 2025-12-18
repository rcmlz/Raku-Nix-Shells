{ pkgs ? import <nixpkgs> {} }:
let
  buildEnvPackages = [
      pkgs.rakudo
      pkgs.zef
      
      pkgs.readline
      pkgs.rlwrap
      pkgs.zlib
      
    ];
  exampleScript = pkgs.writeText "humming-bird.demo.raku" 
  ''
		use v6.d;
	  use Humming-Bird::Core;

		get('/', -> $request, $response {
					$response.html('<h1>Hello World</h1>');
		});

		listen(8080);
  '';

in
 pkgs.mkShell {
    packages = buildEnvPackages;
    buildInputs = buildEnvPackages;
    propagatedBuildInputs = buildEnvPackages;
    
    # Set some zef environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;

    # Avoid e.g. this error: Cannot locate native library 'libreadline.so.7': libreadline.so.7: cannot open shared object file: No such file or directory
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.readline
      pkgs.openssl
      pkgs.zlib
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
      echo "executing: zef install --debug --deps-only Humming-Bird"
      zef install --debug --deps-only Humming-Bird

      # install Humming-Bird
      echo 'executing: zef install --debug Humming-Bird'
      zef install --debug Humming-Bird
      
      # delayed webbrowser start
      echo 'executing: sleep 2 && xdg-open http://localhost:8080 &'
	    sleep 2 && xdg-open http://localhost:8080 &

	    # start example script
      echo 'executing: raku ${exampleScript}'
	    raku ${exampleScript}    
    '';
}
    
