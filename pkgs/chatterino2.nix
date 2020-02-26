{ lib, mkDerivation, fetchFromGitHub, makeWrapper, qmake, pkgconfig, qtbase
, qtsvg, qtmultimedia, boost, openssl }:

mkDerivation rec {
  pname = "chatterino2";
  version = "2.1.7";

  src = fetchFromGitHub {
    owner = "Chatterino";
    repo = pname;
    rev = "v${version}";
    sha256 = "0bbdzainfa7hlz5p0jfq4y04i3wix7z3i6w193906bi4gr9wilpg";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qmake pkgconfig ];

  buildInputs = [ qtbase qtsvg qtmultimedia boost openssl makeWrapper ];

  # NOTE: creates files in ~/.local/share/.chatterino-wrapped (or similar) now
  postInstall = ''
    wrapProgram $out/bin/chatterino \
      --set QT_XCB_FORCE_SOFTWARE_OPENGL 1 \
      --set QT_QPA_PLATFORM xcb
  '';

  meta = with lib; {
    description = "A chat client for Twitch chat";
    longDescription = ''
      Chatterino is a chat client for Twitch chat. It aims to be an
      improved/extended version of the Twitch web chat. Chatterino 2 is
      the second installment of the Twitch chat client series
      "Chatterino".
    '';
    homepage = "https://github.com/fourtf/chatterino2";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ cole-h ];
  };
}
