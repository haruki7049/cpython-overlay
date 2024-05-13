self: super: {
  cpython = {
    "3.7.3" = super.stdenv.mkDerivation rec {
      pname = "cpython";
      version = "3.7.3";

      src = super.fetchFromGitHub {
        owner = "python";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-DMz2VdmnNEQIO4ALBP+KBccP3DxI/z+mKQMaReRg070=";
      };

      buildPhase = ''
        ./configure --prefix=$out
        make

        # Run the tests
        make test
      '';

      installPhase = ''
        make install
      '';

      meta = with super.stdenv.lib; {
        description = "Python programming language";
        license = licenses.psfl;
        platforms = platforms.all;
      };
    };
  };
}
