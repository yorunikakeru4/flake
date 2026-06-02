{
  description = "msu-agent-krystallic-version C++/CMake dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;

        # WARNING: Android SDK packages require accepting the license and unfree packages.
        # Set allowUnsupportedSystem here too if your host is not supported by nixpkgs.
        config.android_sdk.accept_license = true;
        config.allowUnfree = true;
        # config.allowUnsupportedSystem = true;
      };

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        platformVersions = ["35"];
        buildToolsVersions = ["35.0.0"];

        includeNDK = true;

        # NOTE: Если CMakePresets/toolchain ругнётся, заменить на версию NDK,
        # которую ожидает проект.
        ndkVersions = ["27.2.12479018"];

        includeCmake = true;
        cmakeVersions = ["3.22.1"];

        includeEmulator = false;
        includeSystemImages = false;
      };

      androidSdk = androidComposition.androidsdk;
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.cmake
          pkgs.ninja
          pkgs.clang
          pkgs.llvm
          pkgs.pkg-config
          pkgs.git

          androidSdk
        ];

        shellHook = ''
          export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
          export ANDROID_SDK_ROOT="$ANDROID_HOME"
          export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.2.12479018"
          export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"

          export PATH="$ANDROID_HOME/platform-tools:$PATH"

          echo "ANDROID_HOME=$ANDROID_HOME"
          echo "ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
        '';
      };
    });
}
