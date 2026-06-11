{
  description = "NOTE: Lua 5.4 and LuaRocks project development and build flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lua = pkgs.lua5_4;
      luaPackages = pkgs.lua54Packages;

      # NOTE: Change these values to match the rockspec.
      packageName = "base";
      version = "0.1.0-1";

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";

        programs.alejandra.enable = true;
        programs.stylua.enable = true;
      };

      app = luaPackages.buildLuaApplication {
        pname = packageName;
        inherit version;

        src = ./.;

        # NOTE: Change this path if the rockspec uses another name.
        knownRockspec = ./${packageName}-${version}.rockspec;

        # NOTE: Add LuaRocks dependencies from luaPackages here.
        propagatedBuildInputs = [];

        doCheck = false;
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
          lua
          luaPackages.luarocks
          pkgs.lua-language-server
          pkgs.stylua
          treefmtEval.config.build.wrapper
        ];
      };
    });
}
