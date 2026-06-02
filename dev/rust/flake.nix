{
  description = "Basic Rust dev environment";

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
      # NOTE: Replace or add packages below to match your project.
      # WARNING: For unfree or unsupported packages, import nixpkgs with config:
      # pkgs = import nixpkgs {
      #   inherit system;
      #   config.allowUnfree = true;
      #   config.allowUnsupportedSystem = true;
      # };
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
