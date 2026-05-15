{
  description = "C Clang dev environment";

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
          clang
          clang-tools
          lldb
          gdb
          cmake
          gnumake
          pkg-config
        ];

        shellHook = ''
          echo "C Clang dev shell"
          clang --version
        '';
      };
    });
}
