self: super: {
  cpython = let
    lib = super.lib;
    fetchFromGitHub = super.fetchFromGitHub;
    stdenv = super.stdenv;
    optionals = lib.optionals;
    pkg-config = super.pkg-config;
    autoreconfHook = super.autoreconfHook;
    autoconf-archive = super.autoconf-archive;
    nukeReferences = super.nukeReferences;
    zlib = super.zlib;
    glibc = super.glibc;
    gdbm = super.gdbm;
    sqlite = super.sqlite;
    bzip2 = super.bzip2;
    expat = super.expat;
    ncurses = super.ncurses;
    readline = super.readline;
    xz = super.xz;
    libffi = super.libffi;
    libxcrypt = super.libxcrypt;
    tcl = super.tcl;
    tk = super.tk;
    libX11 = super.xorg.libX11;
    xorgproto = super.xorg.xorgproto;
    bluez = super.bluez;
    tzdata = super.tzdata;
    openssl-1-0-2 = stdenv.mkDerivation {
      pname = "openssl";
      version = "1.0.2";

      src = fetchFromGitHub {
        owner = "openssl";
        repo = "openssl";
        rev = "OpenSSL_1_0_2";
        sha256 = "sha256-so3qv87ph1mA3LMi4zOQ2hOlo9DApbuQc33GSWnBl/E=";
      };

      buildInputs = with super; [ perl ];

      buildPhase = ''
        ./config --prefix=$out
        make
      '';

      installPhase = ''
        make install
      '';
    };
  in {
    "3.7.3" = stdenv.mkDerivation rec {
      pname = "cpython";
      version = "3.7.3";

      src = fetchFromGitHub {
        owner = "python";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-DMz2VdmnNEQIO4ALBP+KBccP3DxI/z+mKQMaReRg070=";
      };

      buildInputs = [
        glibc
        openssl-1-0-2
        zlib
        gdbm
        sqlite
        bzip2
        expat
        ncurses
        readline
        xz
        libffi
        libxcrypt
        tcl
        tk
        libX11
        xorgproto
        bluez
        tzdata
      ];

      nativeBuildInputs = optionals (!stdenv.isDarwin) [
        pkg-config
        autoreconfHook
        autoconf-archive
      ] ++ [ nukeReferences ] ++ optionals (stdenv.cc.isClang
        && (!stdenv.hostPlatform.useAndroidPrebuilt or false))
        [ stdenv.cc.cc.libllvm.out ] ++ [ openssl-1-0-2 ];

      LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
      LDFLAGS = [ "-L${glibc}" "-L${zlib}" ];

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
