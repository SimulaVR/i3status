{
  fetchurl,
  lib,
  stdenv,
  libconfuse,
  yajl,
  libpulseaudio,
  libnl,
  pkg-config,
  asciidoc,
  xmlto,
  docbook_xml_dtd_45,
  docbook_xsl,
  alsa-lib,
}:

stdenv.mkDerivation rec {
  name = "i3status-2.13";

  src = ./.;
  nativeBuildInputs = [
    pkg-config
    asciidoc
    xmlto
    docbook_xml_dtd_45
    docbook_xsl
  ];
  buildInputs = [
    libconfuse
    yajl
    libpulseaudio
    libnl
    alsa-lib
  ];

  makeFlags = [
    "all"
    "PREFIX=$(out)"
  ];

  # This hack is needed because for unknown reasons configure generates a broken makefile on the 2.13 release under nixos
  preBuild = ''
    sed -i -e 's/\$(TEST_LOGS) \$(TEST_LOGS/\$(TEST_LOGS)/g' Makefile
  '';

  meta = {
    description = "Generates a status line for i3bar, dzen2, xmobar or lemonbar";
    homepage = "https://i3wm.org";
    maintainers = [ ];
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };

}
