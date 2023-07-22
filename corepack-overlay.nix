packageJsonFile: final: prev: 
let
    nodejs = prev.nodejs_20;
    packageJson = builtins.fromJSON (builtins.readFile packageJsonFile);
    hash = prev.lib.lists.last (prev.lib.strings.splitString "." packageJson.packageManager);
    corepack_download = prev.stdenv.mkDerivation {
        name = "corepack-download-${packageJson.packageManager}";
        src = packageJsonFile;
        nativeBuildInputs = [ nodejs ];
        phases = [ "installPhase" ];
        installPhase = ''
            echo '{ "packageManager": "${packageJson.packageManager}" }' > package.json

            MGR=`echo "${packageJson.packageManager}" | cut -d '@' -f 1`
            VER=`echo "${packageJson.packageManager}" | cut -d '@' -f 2 | cut -d '+' -f 1`

            mkdir cache
            export COREPACK_HOME=$PWD/cache
            corepack prepare
            mv $COREPACK_HOME/$MGR/$VER/$MGR.js $out
        '';
        #outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = hash;
    };
    corepack = prev.stdenv.mkDerivation {
        name = "corepack-shims";
        nativeBuildInputs = [ nodejs ];
        phases = [ "installPhase" ];
        src = corepack_download;
        dontUnpack = true;
        installPhase = ''
            export COREPACK_ENABLE_NETWORK=0
            export COREPACK_HOME=$out/cache
            mkdir -p $COREPACK_HOME $out/bin
            echo '{ "yarn": "0.0.0", "npm": "0.0.0", "pnpm": "0.0.0" }' > $COREPACK_HOME/lastKnownGood.json

            MGR=`echo "${packageJson.packageManager}" | cut -d '@' -f 1`
            VER=`echo "${packageJson.packageManager}" | cut -d '@' -f 2 | cut -d '+' -f 1`
            mkdir -p $COREPACK_HOME/$MGR/$VER
            cp "$src" $COREPACK_HOME/$MGR/$VER/$MGR.js

            corepack enable --install-directory=$out/bin
        '';
    };
in {
    inherit nodejs;
    corepack = corepack // { home = corepack.out + "/cache"; };
}
