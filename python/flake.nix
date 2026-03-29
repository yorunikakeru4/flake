{
  description = "Basic Python dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python313;
      pkg = pkgs.python313Packages;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python
          ruff # Linter & formatter
          basedpyright # LSP server
        ];

        shellHook = ''
          echo "$(python --version)"

        '';
      };
    });
}
