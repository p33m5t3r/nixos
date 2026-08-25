{ lib
, appimageTools
, fetchurl
, makeWrapper
, symlinkJoin
}:

let
  pname = "slippi-launcher";
  version = "2.15.0";

  src = fetchurl {
    url = "https://github.com/project-slippi/slippi-launcher/releases/download/v${version}/Slippi-Launcher-${version}-x86_64.AppImage";
    hash = "sha256-FZyZx/bvtbVR/UJyVcWODP12/6XI5Omp8H5w/61LLds=";
  };

  # Used only to pull the .desktop file and icon out of the AppImage.
  contents = appimageTools.extract { inherit pname version src; };

  # The launcher downloads the Slippi *Dolphin* AppImage at runtime into
  # ~/.config/SlippiOnline. That child process inherits this FHS environment,
  # so Dolphin's runtime libraries have to be listed here too -- not just the
  # launcher's own Electron deps.
  app = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = import ./runtime-deps.nix;

    extraInstallCommands = ''
      install -Dm444 ${contents}/${pname}.desktop \
        -t $out/share/applications
      install -Dm444 ${contents}/${pname}.png \
        $out/share/icons/hicolor/512x512/apps/${pname}.png
    '';
  };
in
# APPIMAGE_EXTRACT_AND_RUN makes the *child* Slippi Dolphin AppImage unpack
# itself instead of demanding a FUSE mount, which is not available inside the
# FHS sandbox.
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ app ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/${pname} \
      --set APPIMAGE_EXTRACT_AND_RUN 1

    # symlinkJoin links the .desktop straight to the inner, unwrapped
    # derivation. Replace it with a real file pointing at the wrapper, so
    # launching from a desktop menu gets APPIMAGE_EXTRACT_AND_RUN too.
    rm -f $out/share/applications/${pname}.desktop
    install -Dm444 ${app}/share/applications/${pname}.desktop \
      -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname}"
  '';

  meta = with lib; {
    description = "Slippi Launcher - Melee rollback netplay, replays and matchmaking";
    homepage = "https://slippi.gg";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
