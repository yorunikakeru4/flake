# Nix flake templates

Готовые dev-окружения и build-конфигурации для NixOS и любого Linux / macOS с Nix.

## Предварительные требования

- [Nix](https://nixos.org/download) с включёнными flakes
- Добавить в `~/.config/nix/nix.conf` (или `/etc/nix/nix.conf`):
  ```
  experimental-features = nix-command flakes
  ```

## Использование

```bash
# Инициализировать шаблон в текущей директории
nix flake init -t github:yorunikakeru/flake#<template>

# Войти в dev shell
nix develop

# Для build-шаблонов: собрать / запустить / проверить
nix build
nix run
nix flake check
```

## Dev shells (`*-dev`)

`nix develop` подтягивает компилятор, LSP, linter, formatter. Изолировано от системы.
Внутри dev-шаблонов есть `NOTE` для обычной кастомизации и `WARNING` для случаев, где нужны unfree-пакеты или unsupported system.

```nix
pkgs = import nixpkgs {
  inherit system;
  config.allowUnfree = true;
  config.allowUnsupportedSystem = true;
};
```

| Шаблон | Язык / версия | LSP | Linter | Formatter | Дополнительно |
|--------|---------------|-----|--------|-----------|---------------|
| `base` | — | — | — | — | Пустая оболочка |
| `python-dev` | Python 3.13 | basedpyright | ruff | ruff | — |
| `go-dev` | Go | — | golangci-lint | gofumpt | delve, gosimports, golines, go-swagger, go-task |
| `rust-dev` | Rust (nixpkgs) | rust-analyzer | clippy | rustfmt | cargo-watch, just |
| `haskell-dev` | GHC | haskell-language-server | hlint | ormolu | hoogle, just |
| `elixir-dev` | Elixir + Erlang | — | — | — | inotify-tools |
| `lua-dev` | Lua | lua-language-server | — | stylua | — |
| `cpp-dev` | Clang | clang-tools | — | — | lldb, gdb, cmake, gnumake |
| `c-sharp-dev` | .NET | omnisharp-roslyn, csharp-ls | — | — | — |
| `android-dev` | Android SDK 35 + NDK 27 | — | — | — | cmake, ninja, clang |
| `php-dev` | PHP 8.4 | phpactor | php-cs-fixer | — | — |
| `js-dev` | Node.js | — | — | prettierd | TypeScript, Vite, Bun |
| `nix-dev` | Nix | nil | statix, deadnix | alejandra | — |

## Build flakes (`*-build`)

Полная Nix-деривация: `nix build`, `nix run`, `nix flake check`, автоформатирование через `treefmt`.
Требует настройки под конкретный проект (имя пакета, хэши зависимостей — см. NOTE-комментарии внутри шаблона).

| Шаблон | Стек | Formatter |
|--------|------|-----------|
| `rust-build` | Rust (fenix toolchain) | alejandra, rustfmt, taplo |
| `cpp-build` | C++ / CMake / Ninja | alejandra, clang-format, cmake-format |
| `android-build` | Android + Gradle + JDK 17 + NDK 27 | — |
| `go-build` | Go (buildGoModule) | alejandra, gofmt |
| `haskell-build` | Haskell / Cabal (callCabal2nix) | alejandra, ormolu |

## Кастомизация

### Python — добавить зависимости

```nix
let
  python = pkgs.python313;
  pkg = pkgs.python313Packages;
in {
  devShells.default = pkgs.mkShell {
    buildInputs = [
      python
      pkg.numpy
      pkg.requests
    ];
  };
}
```

Все доступные пакеты: [search.nixos.org](https://search.nixos.org/packages) → фильтр `python313Packages`.

### Go build — указать vendorHash

```nix
app = pkgs.buildGoModule {
  pname = "your-app";
  version = "0.1.0";
  src = ./.;

  # Первый раз запустить с fakeHash, скопировать реальный хэш из ошибки:
  vendorHash = pkgs.lib.fakeHash;
  # Заменить на реальный:
  # vendorHash = "sha256-AAAA...";

  # Если vendor/ закоммичен в репо:
  # vendorHash = null;
};
```

### Rust build — выбрать тулчейн

```nix
# Стабильный:
rustToolchain = fenix.packages.${system}.stable.toolchain;

# Из rust-toolchain.toml в проекте:
rustToolchain = fenix.packages.${system}.fromToolchainFile {
  file = ./rust-toolchain.toml;
};
```

### Haskell build — выбрать версию GHC

```nix
# Стабильный GHC из nixpkgs (по умолчанию):
haskellPkgs = pkgs.haskellPackages;

# Конкретная версия:
haskellPkgs = pkgs.haskell.packages.ghc966;
haskellPkgs = pkgs.haskell.packages.ghc947;
```
