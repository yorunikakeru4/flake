{
  description = "Basic PHP dev environment";

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
      pkg = pkgs.php84Packages;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          php84
          pkg.php-cs-fixer
          phpactor
        ];

        shellHook = ''
          echo "$(php --version)"
        '';
      };
    });
}
