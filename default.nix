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
    };
  };
}
