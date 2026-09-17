{
  description = "NOTE: Rust project development and build flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      fenix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # NOTE: Change this to your package/binary name.
        packageName = "base";

        # NOTE:
        # Fenix provides Rust toolchains for Nix.
        # `complete.toolchain` includes rustc, cargo, clippy, rustfmt, rust-src, etc.
        # You can replace it with:
        #   fenix.packages.${system}.stable.toolchain
        #   fenix.packages.${system}.minimal.toolchain
        #   fenix.packages.${system}.fromToolchainFile { file = ./rust-toolchain.toml; }
        rustToolchain = fenix.packages.${system}.complete.toolchain;

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs.alejandra.enable = true;
          programs.rustfmt.enable = true;
          programs.taplo.enable = true;
        };

        app = rustPlatform.buildRustPackage {
          pname = packageName;

          # NOTE: Fill this when you start versioning releases.
          version = "0.1.0";

          src = ./.;

          cargoLock.lockFile = ./Cargo.lock;

          nativeBuildInputs = [
            pkgs.pkg-config
          ];

          # NOTE:
          # Set to true when your tests do not require external services.
          # For integration tests with Postgres/Redis/etc, keep false and run them separately.
          doCheck = false;
        };
      in
      {
        packages = {
          default = app;

          # NOTE: This exposes `nix build .#base`.
          # Rename this attr together with `packageName`.
          base = app;
        };

        apps =
          let
            defaultApp =
              (flake-utils.lib.mkApp {
                drv = app;

                # NOTE:
                # Set this only if the binary name differs from packageName.
                # exePath = "/bin/${packageName}";
              })
              // {
                meta.description = "Run ${packageName}";
              };
          in
          {
            default = defaultApp;

            # NOTE: This exposes `nix run .#base`.
            # Rename this attr together with `packageName`.
            base = defaultApp;
          };

        checks = {
          # NOTE: This makes `nix flake check` build the package.
          base = app;

          formatting = treefmtEval.config.build.check self;
        };

        formatter = treefmtEval.config.build.wrapper;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ app ];

          packages = [
            rustToolchain
            pkgs.rust-analyzer
            treefmtEval.config.build.wrapper
          ];
        };
      }
    );
}
