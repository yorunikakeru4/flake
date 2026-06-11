{
  description = "NOTE: Node.js project development and build flake";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # NOTE: Change this to the package name from package.json.
      packageName = "base";

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";

        programs.alejandra.enable = true;
        programs.prettier.enable = true;
      };

      app = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ({dream2nix, ...}: {
            imports = [
              dream2nix.modules.dream2nix.nodejs-package-lock-v3
              dream2nix.modules.dream2nix.nodejs-granular-v3
            ];

            name = packageName;
            version = "0.1.0";

            mkDerivation.src = ./.;
            nodejs-package-lock-v3.packageLockFile = ./package-lock.json;

            deps = {nixpkgs, ...}: {
              inherit
                (nixpkgs)
                nodejs
                stdenv
                ;
            };

            # NOTE: By default dream2nix runs `npm run build` when package.json
            # defines it and installs executables listed in package.json `bin`.
          })
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
          }
        ];
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
          pkgs.nodejs
          pkgs.nodePackages.typescript-language-server
          pkgs.prettierd
          treefmtEval.config.build.wrapper
        ];
      };
    });
}
