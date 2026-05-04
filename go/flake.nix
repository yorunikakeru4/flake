{
  description = "Basic Go dev environment";

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
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          dog
          go
          gosimports
          golines
          golangci-lint
          gotools
          go-task
        ];

        shellHook = ''
          echo "$(go --version)"
        '';
      };
    });
}
