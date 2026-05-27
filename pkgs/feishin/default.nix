{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  makeWrapper,
  http-server,
}:

stdenv.mkDerivation rec {
  pname = "feishin";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "jeffvli";
    repo = "feishin";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    makeWrapper
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit pname src;
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  };

  buildPhase = ''
    runHook preBuild

    # Build the web application
    pnpm run build:web

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install the built web application
    mkdir -p $out/share/feishin/web
    cp -r out/web/* $out/share/feishin/web/

    # Create a simple wrapper script to serve the application
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/feishin-web \
      --add-flags "${http-server}/bin/http-server" \
      --add-flags "$out/share/feishin/web"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern self-hosted music player";
    homepage = "https://github.com/jeffvli/feishin";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      jeffvli
      gerrydoro
    ];
    platforms = platforms.all;
  };
}
