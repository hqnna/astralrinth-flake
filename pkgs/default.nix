{ pkgs, ... }:

let
  pname = "astralrinth";
  version = "0.14.801";

  src = pkgs.fetchurl {
    url = "https://git.astralium.su/didirus/AstralRinth/releases/download/AR-${version}/AstralRinth%20App_${version}_amd64.AppImage";
    hash = "sha256-aBjhHMdkIP0wlHP3jtCGclhxI/jF2s9WH9KNeZnq/w8=";
    name = "AstralRinth_${version}_amd64.AppImage";
  };

  image = pkgs.appimageTools.extractType1 { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    cp -r "${image}/usr/share" "$out/share"
    substituteInPlace "$out/share/applications/AstralRinth App.desktop" \
      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  '';

  meta = with pkgs.lib; {
    description = "A modern launcher based on Modrinth.";
    homepage = "https://git.astralium.su/didirus/AstralRinth";
    downloadPage = "https://git.astralium.su/didirus/AstralRinth/releases";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ hanna ];
    mainProgram = "astralrinth";
    platforms = [ "x86_64-linux" ];
    license = licenses.mit;
  };
}
