{
  description = "Basic Rust dev environment";

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
          cargo
          rust-analyzer # LSP
          clippy # Linter
          rustfmt # Formatter
          rustc # Rust compiler
          cargo-watch # Auto-rebuild
          just
        ];

        shellHook = ''
          echo "$(cargo --version)"

        '';
      };
    });
}
