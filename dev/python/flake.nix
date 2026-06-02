{
  description = "Basic Python dev environment";

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
