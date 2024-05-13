self: super: {
  cpython =
    let
      pkgs = super.pkgs;
      lib = super.lib;
      fetchFromGitHub = super.fetchFromGitHub;
      stdenv = pkgs.stdenv;
      optionals = lib.optionals;
      pkg-config = pkgs.pkg-config;
      autoreconfHook = pkgs.autoreconfHook;
      autoconf-archive = pkgs.autoconf-archive;
      nukeReferences = pkgs.nukeReferences;
      zlib = pkgs.zlib;
      glibc = pkgs.glibc;
      gdbm = pkgs.gdbm;
      sqlite = pkgs.sqlite;
      bzip2 = pkgs.bzip2;
      expat = pkgs.expat;
      ncurses = pkgs.ncurses;
      readline = pkgs.readline;
      xz = pkgs.xz;
      libffi = pkgs.libffi;
      libxcrypt = pkgs.libxcrypt;
      tcl = pkgs.tcl;
      tk = pkgs.tk;
      libX11 = pkgs.xorg.libX11;
      xorgproto = pkgs.xorg.xorgproto;
      bluez = pkgs.bluez;
      tzdata = pkgs.tzdata;
      openssl-1-0-2 = stdenv.mkDerivation {
        pname = "openssl";
        version = "1.0.2";

        src = fetchFromGitHub {
          owner = "openssl";
          repo = "openssl";
          rev = "OpenSSL_1_0_2";
          sha256 = "sha256-so3qv87ph1mA3LMi4zOQ2hOlo9DApbuQc33GSWnBl/E=";
        };

        buildInputs = with pkgs; [ perl ];

        buildPhase = ''
          ./config --prefix=$out
          make
        '';

        installPhase = ''
          make install
        '';
      };
    in
    {
      "3.7.3" = stdenv.mkDerivation rec {
        pname = "cpython";
        version = "3.7.3";

        src = fetchFromGitHub {
          owner = "python";
          repo = pname;
          rev = "v${version}";
          hash = "sha256-DMz2VdmnNEQIO4ALBP+KBccP3DxI/z+mKQMaReRg070=";
        };

        buildInputs = [ glibc openssl-1-0-2 zlib gdbm sqlite bzip2 expat ncurses readline xz libffi libxcrypt tcl tk libX11 xorgproto bluez tzdata ];

        nativeBuildInputs = optionals (!stdenv.isDarwin)
          [ pkg-config autoreconfHook autoconf-archive ] ++ [
          nukeReferences
        ] ++ optionals (stdenv.cc.isClang && (!stdenv.hostPlatform.useAndroidPrebuilt or false)) [
          stdenv.cc.cc.libllvm.out
        ] ++ [
          openssl-1-0-2
        ];

        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
        LDFLAGS = [
          "-L${glibc}"
          "-L${zlib}"
        ];

        enableParallelBuilding = true;

        #patches = [
        #  ./cpython-3.7.3/static-openssl.patch
        #];

        buildPhase = ''
          ./configure \
            --prefix=$out \
            --enable-optimizations \
            --with-lto \
            --with-openssl=${openssl-1-0-2} \
            --with-openssl-rpath=$out/lib \
            --with-ssl-default-suites=openssl \
            --with-zlib=${zlib}
            #--with-libc=${stdenv.cc.libc}

          #make -s

          # Run the tests
          #make test
        '';

        installPhase = ''
          make install
        '';

        meta = with lib; {
          description = "Python programming language";
          license = licenses.psfl;
          platforms = platforms.linux;
        };
      };
    };
}
