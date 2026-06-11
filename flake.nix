{
  description = "My Nix flake templates";

  outputs = {self}: {
    templates = {
      python-dev = {
        path = ./dev/python;
        description = "Python dev shell";
      };

      go-dev = {
        path = ./dev/go;
        description = "Go dev shell";
      };

      rust-dev = {
        path = ./dev/rust;
        description = "Rust dev shell";
      };

      rust-build = {
        path = ./build/rust;
        description = "Rust build shell";
      };

      node-build = {
        path = ./build/node;
        description = "Node.js dream2nix build flake";
      };

      bun-build = {
        path = ./build/bun;
        description = "Bun bun2nix build flake";
      };

      typescript-build = {
        path = ./build/typescript;
        description = "TypeScript esbuild dream2nix build flake";
      };

      lua-build = {
        path = ./build/lua;
        description = "Lua 5.4 LuaRocks build flake";
      };

      elixir-dev = {
        path = ./dev/elixir;
        description = "Elixir dev shell";
      };

      lua-dev = {
        path = ./dev/lua;
        description = "Lua dev shell";
      };

      cpp-dev = {
        path = ./dev/cpp;
        description = "CPP dev shell";
      };

      cpp-build = {
        path = ./build/cpp;
        description = "CPP build shell";
      };

      android-dev = {
        path = ./dev/android;
        description = "Android dev shell";
      };

      android-build = {
        path = ./build/android;
        description = "Android build shell";
      };

      php-dev = {
        path = ./dev/php;
        description = "PHP dev shell";
      };

      js-dev = {
        path = ./dev/js;
        description = "JavaScript dev shell";
      };

      nix-dev = {
        path = ./dev/nix;
        description = "Nix dev shell";
      };

      haskell-dev = {
        path = ./dev/haskell;
        description = "Haskell GHC dev shell";
      };

      go-build = {
        path = ./build/go;
        description = "Go build flake";
      };

      haskell-build = {
        path = ./build/haskell;
        description = "Haskell Cabal build flake";
      };

      base = {
        path = ./base;
        description = "Base dev shell";
      };
    };
  };
}
