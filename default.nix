self: super: {
  cpython = let
    openssl-1-0-2 = super.stdenv.mkDerivation {
      pname = "openssl";
      version = "1.0.2";

      src = super.fetchFromGitHub {
        owner = "openssl";
        repo = "openssl";
        rev = "OpenSSL_1_0_2";
        sha256 = "sha256-so3qv87ph1mA3LMi4zOQ2hOlo9DApbuQc33GSWnBl/E=";
      };

      buildInputs = with super.pkgs; [ perl ];

      buildPhase = ''
        ./config --prefix=$out
        make
      '';

      installPhase = ''
        make install
      '';
    };
  in {
    "3.7.3" = super.stdenv.mkDerivation rec {
      pname = "cpython";
      version = "3.7.3";

      src = super.fetchFromGitHub {
        owner = "python";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-DMz2VdmnNEQIO4ALBP+KBccP3DxI/z+mKQMaReRg070=";
      };

      buildInputs = [ openssl-1-0-2 ];

      nativeBuildInputs = [ openssl-1-0-2 ];

      buildPhase = ''
        ./configure \
          --prefix=$out \
          --enable-optimizations \
          --with-lto \
          --with-openssl=${openssl-1-0-2}/bin/openssl \

        make -s

        # Run the tests
        make test
      '';

      enableParallelBuilding = true;

      installPhase = ''
        make install
      '';

      meta = with super.lib; {
        description = "Python programming language";
        license = licenses.psfl;
        platforms = platforms.all;
      };
    };
  };
}
