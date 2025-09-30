{ pkgs ? import <nixpkgs> {} }:

 pkgs.mkShellNoCC {
    packages = [
      pkgs.rakudo
      pkgs.zef

      pkgs.gcc # requirement for Term::termios
    ];

    # Avoid this error: Cannot locate native library 'libreadline.so.7': libreadline.so.7: cannot open shared object file: No such file or directory
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
      pkgs.readline70
    ];

	# set some environment variables
    ZEF_FETCH_DEGREE = 4;
    ZEF_TEST_DEGREE = 4;
    
    shellHook = ''
	  # list of packages
	  RAKU_REQUIREMENTS=raku_dev_modules.txt

	  # how many CPUs do we have? - minus 1
      CPUm1=$(raku -e 'print $*KERNEL.cpu-cores - 1')
      	  
      echo "raku --version"
      raku --version

	  echo "zef --version"
	  zef --version

      # get latest defintions
      zef update

      # make zef go parallel
      export ZEF_FETCH_DEGREE=$CPUm1
      export ZEF_TEST_DEGREE=$CPUm1

	  echo "Installing all modules listed in" $RAKU_REQUIREMENTS
	  # one by one
      #cat $RAKU_REQUIREMENTS | raku -e 'for $*IN.lines.grep(/^^\w/) { say shell "zef install \"$_\"" }'
      
      # all with one invocation of zef
      cat $RAKU_REQUIREMENTS | raku -e 'with $*IN.lines.grep(/^^\w/).join("\" \"") { my $cmd = "zef install \"$_\""; say $cmd; shell $cmd }'
    '';
}
