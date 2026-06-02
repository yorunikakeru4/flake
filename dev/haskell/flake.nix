{
  description = "Haskell GHC dev environment";

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
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          ghc
          cabal-install
          haskell-language-server # LSP
          hlint # Linter
          ormolu # Formatter
          haskellPackages.hoogle # Docs search
          just
        ];

        shellHook = ''
          echo "$(ghc --version)"
        '';
      };
    });
}
