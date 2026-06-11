{
  description = "NOTE: Bun project development and build flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    bun2nix = {
      url = "github:nix-community/bun2nix?ref=2.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    bun2nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [bun2nix.overlays.default];
      };

      # NOTE: Change these values to match package.json.
      packageName = "base";
      version = "0.1.0";

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";

        programs.alejandra.enable = true;
        programs.prettier.enable = true;
      };

      app = pkgs.bun2nix.mkDerivation {
        pname = packageName;
        inherit version;

        src = ./.;

        bunDeps = pkgs.bun2nix.fetchBunDeps {
          # NOTE: Regenerate after changing bun.lock:
          # `bun2nix -o bun.nix`
          bunNix = ./bun.nix;
        };

        # NOTE: Change this to the Bun entrypoint.
        module = "src/index.ts";
      };
    in {
      packages = {
        default = app;
        ${packageName} = app;
      };

      apps = let
        defaultApp =
          (flake-utils.lib.mkApp {
            drv = app;
          })
          // {
            meta.description = "Run ${packageName}";
          };
      in {
        default = defaultApp;
        ${packageName} = defaultApp;
      };

      checks = {
        ${packageName} = app;
        formatting = treefmtEval.config.build.check self;
      };

      formatter = treefmtEval.config.build.wrapper;

      devShells.default = pkgs.mkShell {
        inputsFrom = [app];

        packages = [
          pkgs.bun
          pkgs.bun2nix
          pkgs.prettierd
          treefmtEval.config.build.wrapper
        ];
      };
    });
}
