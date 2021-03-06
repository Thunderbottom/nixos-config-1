{ lib
, stdenv
, pkgs
, fetchFromGitHub
, nodejs-12_x
, remarshal
, ttfautohint-nox
, otfcc
}:
let
  # outputHash = "sha256-S3SVR0ppVJ3UJpCo6OI4dWPo3Wn6OBB/BHrGcD0oTD0=";
  sha256 = "sha256-vFXO+cf+FVNR7QxESULS2dkjS5WYO4CNe+BBQhUOWfw=";
  pname = "iosevka-${set}";
  version = "5.0.0-rc.1";

  set = "custom";

  privateBuildPlan = {
    hintParams = [ "-a" "sss" ];
    family = "Iosevka Custom";

    weights = {
      thin = {
        shape = 100;
        menu = 100;
        css = 100;
      };

      extralight = {
        shape = 200;
        menu = 200;
        css = 200;
      };

      light = {
        shape = 300;
        menu = 300;
        css = 300;
      };

      regular = {
        shape = 400;
        menu = 400;
        css = 400;
      };

      book = {
        shape = 450;
        menu = 450;
        css = 450;
      };

      medium = {
        shape = 500;
        menu = 500;
        css = 500;
      };

      semibold = {
        shape = 600;
        menu = 600;
        css = 600;
      };

      bold = {
        shape = 700;
        menu = 700;
        css = 700;
      };

      extrabold = {
        shape = 800;
        menu = 800;
        css = 800;
      };

      heavy = {
        shape = 900;
        menu = 900;
        css = 900;
      };
    };

    slants = {
      upright = "normal";
      italic = "italic";
      oblique = "oblique";
    };

    no-ligation = true;
    spacing.fixed = true;

    variants.design = {
      a = "double-storey";
      f = "serifless"; # straight
      g = "single-storey";
      i = "serifed";
      l = "serifed-tailed";
      m = "short-leg";
      q = "tailed";
      t = "standard";
      y = "straight";

      eszet = "sulzbacher";
      zero = "reverse-slashed";
      one = "base";
      three = "flattop";
      tilde = "low";
      asterisk = "high";
      underscore = "high";
      paragraph-sign = "high";
      caret = "high";
      brace = "curly";
      number-sign = "slanted";
      at = "threefold";
      dollar = "through";
      percent = "dots";
      # lig-ltgteq = "slanted";
    };
  };

  buildDeps = (import ./. { inherit pkgs; }).package;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "be5invis";
    repo = "Iosevka";
    rev = "v${version}";
    inherit sha256;
  };

  nativeBuildInputs = [
    nodejs-12_x
    buildDeps
    remarshal
    otfcc
    ttfautohint-nox
  ];

  privateBuildPlanJSON = builtins.toJSON { buildPlans.${pname} = privateBuildPlan; };

  passAsFile = [ "privateBuildPlanJSON" ];

  configurePhase = ''
    ${lib.optionalString (privateBuildPlan != null) ''
      remarshal -i "$privateBuildPlanJSONPath" -o private-build-plans.toml -if json -of toml
    ''}

    ln -s ${buildDeps}/lib/node_modules/iosevka/node_modules .
  '';

  buildPhase = ''
    npm run build --no-update-notifier -- ttf::$pname | cat
  '';

  installPhase = ''
    fontdir="$out/share/fonts/truetype"
    install -d "$fontdir"
    install "dist/$pname/ttf"/* "$fontdir"
  '';

  enableParallelBuilding = true;

  # inherit outputHash;
  # outputHashAlgo = "sha256";
  # outputHashMode = "recursive";
}
