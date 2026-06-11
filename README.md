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
| `node-build` | Node.js / npm / dream2nix | alejandra, prettier |
| `bun-build` | Bun / bun2nix | alejandra, prettier |
| `typescript-build` | TypeScript / esbuild / dream2nix | alejandra, prettier |
| `lua-build` | Lua 5.4 / LuaRocks | alejandra, stylua |

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

### Node.js и TypeScript build — lock-файл

`node-build` и `typescript-build` используют dream2nix и требуют
`package-lock.json`. Имя пакета в `flake.nix` должно совпадать с `name` в
`package.json`. Для `nix run` добавьте исполняемый файл в поле `bin`.

### Bun build — сгенерировать bun.nix

```bash
bun install
bun2nix -o bun.nix
```

Повторяйте генерацию `bun.nix` после изменения `bun.lock`.

### Lua build — rockspec

`lua-build` использует Lua 5.4 и `buildLuaApplication`. Имя rockspec по
умолчанию: `base-0.1.0-1.rockspec`. Измените `packageName`, `version` и
`knownRockspec` в шаблоне под проект.
