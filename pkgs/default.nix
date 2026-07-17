{ pkgs, ... }:

let
  pname = "astralrinth";
  version = "0.14.801";

  src = pkgs.fetchurl {
    url = "https://git.astralium.su/didirus/AstralRinth/releases/download/AR-${version}/AstralRinth%20App_${version}_amd64.AppImage";
    hash = "sha256-aBjhHMdkIP0wlHP3jtCGclhxI/jF2s9WH9KNeZnq/w8=";
    name = "AstralRinth_${version}_amd64.AppImage";
  };

  image = pkgs.appimageTools.extract { inherit pname version src; };

  patched = pkgs.runCommand "${pname}-patched" { } ''
    cp -r ${image} $out
    chmod -R u+w $out
    rm -rf $out/usr/lib
  '';
in
pkgs.appimageTools.wrapAppImage rec {
  inherit pname version;
  
  src = patched;

  profile = ''
    export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/"
  '';

  extraPkgs = pkgs: with pkgs; [
    libayatana-appindicator
    glib-networking
    webkitgtk_4_1
    libsoup_3
  ] ++ (with pkgs.gst_all_1; [
    gst-plugins-good
    gst-plugins-base
    gstreamer
  ]);

  extraInstallCommands = ''
    cp -r "${image}/usr/share" "$out/share"
    substituteInPlace "$out/share/applications/AstralRinth App.desktop" \
      --replace-fail 'Exec=AstralRinthApp' 'Exec=${meta.mainProgram}'
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
