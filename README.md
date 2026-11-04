# nvim-config

A modern, keyboard-first Neovim setup for daily C/C++/CUDA, Rust, Python and Lean work — on a
laptop or over SSH on a remote dev server. Built on Neovim's own built-in LSP, with a small set of
well-maintained plugins and mnemonic keymaps you can learn in a few weeks.

> **New to Vim?** Read [Learning Vim](#learning-vim) first, then come back to the keymaps.

## Contents

- [What you get](#what-you-get)
- [Requirements](#requirements)
- [Install](#install)
- [Update, reset, uninstall](#update-reset-uninstall)
- [One config, every machine](#one-config-every-machine)
- [How the config is organized](#how-the-config-is-organized)
- [Plugins](#plugins)
- [Keymaps](#keymaps)
- [Languages](#languages)
- [Customizing](#customizing)
- [Remote development and Zellij](#remote-development-and-zellij)
- [Learning Vim](#learning-vim)
- [Troubleshooting](#troubleshooting)
- [More plugins worth knowing](#more-plugins-worth-knowing)
- [What changed in the 2026 rewrite](#what-changed-in-the-2026-rewrite)

## What you get

- **IDE features from the built-in LSP**: go to definition, references, rename, code actions, inlay
  hints, diagnostics. The language servers are installed for you by Mason.
- **Fast fuzzy finding** for files, text, symbols, help, keymaps and git (fzf-lua).
- **Completion with snippets** using Vim's standard keys (blink.cmp).
- **Treesitter** highlighting, indentation, folding, and code-aware text objects ("delete this function").
- **Format on save**, which is safe in foreign codebases (conform.nvim).
- **Git**: change signs, hunk staging, blame, lazygit, side-by-side diffs.
- **Debugger** (nvim-dap) for C/C++/CUDA/Rust (codelldb) and Python (debugpy).
- **C++/CUDA with CMake**: configure, build, run and debug targets (`<Space>m`), and clangd set up to understand nvcc builds.
- **Tests and tasks**: run the nearest test (neotest) and build/run with cargo/cmake/make (overseer).
- **Seamless splits**: `Ctrl-h/j/k/l` moves between Neovim splits *and* Zellij/tmux panes.
- **Clipboard over SSH**: when you yank on the server, the text lands on your laptop's clipboard (OSC 52).
- **Transparent tokyonight theme**, with catppuccin and onedark one keystroke away (`<Space>uC`).
- **Discoverability**: press `<Space>` and wait, and a menu shows every command.

## Requirements

| Tool | Why |
|---|---|
| **Neovim ≥ 0.12** | built-in LSP config, `winborder`, newest APIs |
| git, curl, unzip, tar | plugin and tool installs |
| C compiler (`cc`/`clang`/`gcc`) | building treesitter parsers |
| [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [fzf](https://github.com/junegunn/fzf) | searching (fzf-lua) |
| [lazygit](https://github.com/jesseduffield/lazygit) | git UI (`<Space>gg`) |
| python3 with `venv` | Mason installs the Python tools (basedpyright, ruff, debugpy) |
| A [Nerd Font](https://www.nerdfonts.com/) set in your terminal | icons (otherwise you'll see boxes) |
| Optional: [rustup](https://rustup.rs) + `rustup component add rust-analyzer` | Rust |
| Optional: [elan](https://github.com/leanprover/elan) | Lean 4 |
| Optional: [Zellij](https://zellij.dev) | terminal multiplexer (see [below](#remote-development-and-zellij)) |

Everything else (clangd, basedpyright, ruff, lua-language-server, neocmakelsp, clang-format, stylua,
codelldb, debugpy, the tree-sitter CLI) is installed automatically by **Mason** on first start.

**macOS**

```bash
brew install neovim git ripgrep fd fzf lazygit zellij python
```

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

**Linux (no root needed, works on a remote server)**: distro Neovim packages are often too old.
Use [bob](https://github.com/MordechaiHadad/bob), a Neovim version manager:

```bash
cargo install --locked bob-nvim && bob use stable
```

Then install the rest, for example on Debian/Ubuntu (`fd` is called `fdfind` there, which fzf-lua finds automatically):

```bash
sudo apt install git curl unzip build-essential ripgrep fd-find fzf python3-venv
```

On Arch:

```bash
sudo pacman -S neovim git ripgrep fd fzf lazygit zellij base-devel unzip python
```

**Windows**

```bash
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd junegunn.fzf JesseDuffield.lazygit zig.zig
```

Zig serves as the C compiler for treesitter. The config folder on Windows is `%LOCALAPPDATA%\nvim`.

## Install

**Quick install** (macOS, Linux or a remote server; safe to re-run):

```bash
curl -fsSL https://raw.githubusercontent.com/Kelvinyu1117/nvim-config/main/install.sh | sh
```

[`install.sh`](install.sh) does the following:
- checks for Neovim 0.12+ and warns about missing tools
- clones the repo to `~/nvim-config`, or pulls if it's already there
- moves any existing `~/.config/nvim` to a timestamped `.bak`
- links `~/.config/nvim` to the repo
- installs the plugins at the versions in `lazy-lock.json`

Running it again later is how you update. Then continue with step 3 below.

**Manual install**

1. Back up any existing config:

   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

   ```bash
   mv ~/.local/share/nvim ~/.local/share/nvim.bak
   ```

2. Clone this repo and link the `nvim/` folder into place:

   ```bash
   git clone https://github.com/kelvinyu1117/nvim-config.git ~/nvim-config
   ```

   ```bash
   ln -s ~/nvim-config/nvim ~/.config/nvim
   ```

3. Start `nvim`. On first launch:
   - lazy.nvim installs every plugin (a window shows progress; press `q` when it's done).
   - Mason installs the language servers and tools in the background (watch with `:Mason`).
   - **Restart Neovim once** after Mason finishes, so the treesitter parsers can be built with the
     freshly installed `tree-sitter` CLI.
4. Run `:checkhealth` and fix anything shown in red.
5. Commit the generated `nvim/lazy-lock.json`. It pins every plugin version, so all your machines run
   exactly the same setup:

   ```bash
   cd ~/nvim-config && git add nvim/lazy-lock.json && git commit -m "Pin plugin versions"
   ```

## Update, reset, uninstall

- **Update the config on a machine**: run `./install.sh` again (or `git pull`, then `:Lazy restore`).
- **Update plugins**: `:Lazy` then `U` (update), or `:Lazy sync`. Commit the new `lazy-lock.json`.
  To roll back, check out an older lockfile and run `:Lazy restore`.
- **Update tools**: `:Mason` then `U`.
- **Update parsers**: `:TSUpdate`.
- **Reset everything** (plugins, tools, caches; your config is untouched):

  ```bash
  rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
  ```

- **Uninstall**: remove the symlink (`rm ~/.config/nvim`), run the reset command above, and restore your `.bak` folders.

## One config, every machine

Use the **same repo on every machine** (Mac, Linux desktop, remote servers): install once with
`install.sh`, then keep machines in sync with git. You never reinstall by hand.

| Shared through git (identical everywhere) | Per machine (never committed) |
|---|---|
| everything in `nvim/`: options, keymaps, plugins | Mason's tools (downloaded for that OS/CPU) in `~/.local/share/nvim/mason` |
| `nvim/lazy-lock.json`: exact plugin versions | clangd's CUDA settings written by `:CudaClangdSetup` |
| | undo history, sessions, shada in `~/.local/state/nvim` |

The workflow: update plugins on one machine (`:Lazy update`), test, and commit `lazy-lock.json`. On
the other machines, run `./install.sh` (or `git pull` + `:Lazy restore`) to get exactly the same versions.

Anything that depends on the machine detects it at runtime:
- clipboard over SSH
- the `~/.cargo/bin` PATH entry
- the multiplexer (Zellij/tmux)
- CUDA (see [C/C++/CUDA](#languages))

On a Mac without CUDA, CUDA support simply stays off. Nothing errors.

## How the config is organized

```
nvim/
├── init.lua                 entry point: sets <Space> as leader, loads the four config files
├── lua/config/
│   ├── options.lua          editor settings, clipboard (OSC 52 over SSH), diagnostics look
│   ├── lazy.lua             installs and starts the plugin manager
│   ├── keymaps.lua          global keymaps (save, splits, buffers, moving lines...)
│   └── autocmds.lua         automatic behaviour + LSP keymaps when a server attaches
├── lua/plugins/             one file per area, each returns lazy.nvim plugin specs
│   ├── colorscheme.lua      tokyonight (default), catppuccin, onedarkpro; transparency switch
│   ├── ui.lua               statusline, which-key menu, breadcrumbs, LSP progress
│   ├── snacks.lua           explorer, lazygit, terminal, notifications, dashboard, toggles
│   ├── fzf.lua              all fuzzy pickers
│   ├── editor.lua           flash, surround, autopairs, todo, trouble, sessions, smart-splits
│   ├── treesitter.lua       parsers, highlighting, text objects
│   ├── completion.lua       blink.cmp
│   ├── lsp.lua              Mason + language servers
│   ├── formatting.lua       conform (format on save)
│   ├── cpp.lua              C/C++/CUDA: cmake-tools, clangd_extensions, :CudaClangdSetup
│   ├── lang.lua             Rust (rustaceanvim), Lean (lean.nvim)
│   ├── git.lua              gitsigns, diffview
│   ├── dap.lua              debugger
│   └── test.lua             neotest, overseer
├── after/lsp/               your tweaks to individual language servers
│   ├── clangd.lua  basedpyright.lua  ruff.lua  lua_ls.lua
└── templates/
    └── clangd-cuda.yaml     clangd rules for CUDA, installed by :CudaClangdSetup
```

Every file is commented. Reading them top to bottom is a good way to learn how Neovim works.

## Plugins

| Area | Plugin | Why this one |
|---|---|---|
| Plugin manager | [lazy.nvim](https://github.com/folke/lazy.nvim) | lazy-loading, lockfile, great UI |
| Picker | [fzf-lua](https://github.com/ibhagwan/fzf-lua) | fastest picker (native fzf), stays instant in huge repos |
| QoL bundle | [snacks.nvim](https://github.com/folke/snacks.nvim) | explorer, lazygit, terminal, notifier, indent guides, dashboard, toggles: one plugin instead of ten |
| Completion | [blink.cmp](https://github.com/saghen/blink.cmp) | fast (Rust matcher), batteries included |
| LSP | built-in `vim.lsp` + [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | upstream-native, no wrapper layer |
| Installer | [mason.nvim](https://github.com/mason-org/mason.nvim) + mason-lspconfig + mason-tool-installer | same tools on every machine, no root needed |
| Syntax | [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (main) + textobjects | accurate highlighting, `af`/`if`/`aa` objects |
| Formatting | [conform.nvim](https://github.com/stevearc/conform.nvim) | predictable format on save |
| Git | [gitsigns](https://github.com/lewis6991/gitsigns.nvim), [diffview](https://github.com/sindrets/diffview.nvim), lazygit | inline hunks, reviews, merges |
| Debug | [nvim-dap](https://github.com/mfussenegger/nvim-dap) + dap-ui + virtual-text + dap-python | the standard DAP client |
| Tests/tasks | [neotest](https://github.com/nvim-neotest/neotest), [overseer](https://github.com/stevearc/overseer.nvim) | pytest/gtest/cargo test; cmake/cargo/make tasks |
| C/C++/CUDA | [clangd_extensions](https://github.com/p00f/clangd_extensions.nvim), [cmake-tools](https://github.com/Civitasv/cmake-tools.nvim) | AST/type hierarchy/header switch; configure-build-run-debug CMake targets, keeps clangd's compile_commands.json linked |
| Rust | [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) | richer than plain rust-analyzer (macros, runnables, debugging) |
| Lean | [lean.nvim](https://github.com/Julian/lean.nvim) | infoview, unicode input |
| Motion | [flash.nvim](https://github.com/folke/flash.nvim) | jump anywhere visible in 3 keystrokes |
| Editing | [nvim-surround](https://github.com/kylechui/nvim-surround), [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | classic `ys`/`cs`/`ds` keys (same as vim-surround, IdeaVim, VSCode-Vim) |
| Lists | [trouble.nvim](https://github.com/folke/trouble.nvim), [todo-comments](https://github.com/folke/todo-comments.nvim) | diagnostics/quickfix/TODO panels |
| Sessions | [persistence.nvim](https://github.com/folke/persistence.nvim) | reopen a project where you left off |
| Splits | [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) | one set of keys for nvim splits + Zellij/tmux/WezTerm/Kitty panes |
| UI | [lualine](https://github.com/nvim-lualine/lualine.nvim), [which-key](https://github.com/folke/which-key.nvim), [dropbar](https://github.com/Bekaboo/dropbar.nvim), [fidget](https://github.com/j-hui/fidget.nvim) | statusline, key menu, breadcrumbs, LSP progress |
| Theme | [tokyonight](https://github.com/folke/tokyonight.nvim), [catppuccin](https://github.com/catppuccin/nvim), [onedarkpro](https://github.com/olimorris/onedarkpro.nvim) | switch live with `<Space>uC` |

## Keymaps

`<Space>` is the **leader** key. Press it and wait about half a second, and which-key shows every
option. Search all keymaps with `<Space>sk`. Keys are grouped by a mnemonic letter:
**f**ind, **s**earch, **c**ode, **g**it, **d**ebug, **t**est, **r**un, **m** cmake, **x** lists, **b**uffer, **u**i, **q**uit, **w**indow.

### The ones to learn first

| Key | Action |
|---|---|
| `<Space><Space>` | find file |
| `<Space>/` | grep the whole project |
| `<Space>,` | switch between open files (buffers) |
| `<Space>e` | file explorer |
| `gd` / `grr` | go to definition / list references |
| `K` | documentation for the thing under the cursor |
| `gra` / `grn` | code action (quick fix) / rename symbol |
| `[d` / `]d` | previous / next error or warning |
| `<C-o>` / `<C-i>` | jump back / forward (after `gd`, searches, ...) |
| `<C-s>` | save |
| `s` + 2 chars + label | jump anywhere on screen |
| `<C-/>` | toggle a terminal |
| `<Space>gg` | lazygit |

### General

| Key | Mode | Action |
|---|---|---|
| `jk` or `<C-[>` or `<Esc>` | insert | back to normal mode |
| `<C-s>` | any | save |
| `<Esc>` | normal | clear search highlight |
| `<C-h/j/k/l>` | normal | move to split/pane left/down/up/right (works across Zellij panes) |
| `<A-h/j/k/l>` | normal | resize split |
| `<Space>-` / `<Space>\|` | normal | split below / right |
| `<Space>w…` | normal | all window commands (same as `<C-w>…`), e.g. `<Space>wq` close, `<Space>wo` only |
| `<S-h>` / `<S-l>` | normal | previous / next buffer |
| `<Space>bb` / `bd` / `bo` | normal | alternate buffer / delete buffer / delete others |
| `<C-d>` / `<C-u>` | normal | half-page down / up (cursor stays centered) |
| `J` / `K` | visual | move selected lines down / up |
| `<` / `>` | visual | indent, keeping the selection |
| `P` | visual | paste over the selection without losing what you yanked |
| `gc{motion}` / `gcc` | normal | comment (built in), e.g. `gcip` comments a paragraph |
| `<Space>qq` | normal | quit all |
| `<Space>?` | normal | keymaps local to this buffer |
| `<Space>l` / `<Space>cm` | normal | plugin manager (Lazy) / tool installer (Mason) |
| `<Space>n` / `<Space>un` | normal | notification history / dismiss |
| `<Space>.` | normal | scratch buffer |
| `<Space>;` | normal | pick a breadcrumb (file › class › function) |

### Find & search (`<Space>f`, `<Space>s`)

Inside any picker: type to filter, `<C-j>/<C-k>` or arrows to move, `<CR>` to open, `<C-v>`/`<C-s>` to
open in a vertical/horizontal split, `<C-q>` to send all results to the quickfix list, `<F1>` for help.

| Key | Action | Key | Action |
|---|---|---|---|
| `<Space>ff` | files | `<Space>sg` | grep |
| `<Space>fr` | recent files | `<Space>sw` | grep word under cursor / selection |
| `<Space>fg` | git files | `<Space>sb` | lines in this buffer |
| `<Space>fb` | buffers | `<Space>ss` / `sS` | symbols in buffer / workspace |
| `<Space>fc` | config files | `<Space>sd` / `sD` | diagnostics buffer / workspace |
| `<Space>fn` | new file | `<Space>sh` | help pages |
| `<Space>:` | command history | `<Space>sk` | keymaps |
| | | `<Space>sr` | resume last picker |
| | | `<Space>sm` / `sR` / `sj` | marks / registers / jumps |
| | | `<Space>sc` / `sC` | command history / commands |
| | | `<Space>sq` / `st` | quickfix / TODOs |

### Code & LSP

Many of these are Neovim's own defaults (`grn`, `gra`, `grr`, `gri`, `grt`, `gO`, `K`, `[d`, `]d`), so they work on any machine.

| Key | Action |
|---|---|
| `gd` / `gD` | definition / declaration |
| `grr` | references |
| `gri` | implementation |
| `grt` | type definition |
| `gO` | document symbols (outline) |
| `K` | hover documentation (press twice to enter the window) |
| `<C-k>` (insert) | function signature help |
| `gra` or `<Space>ca` | code action |
| `grn` or `<Space>cr` | rename symbol |
| `<Space>cR` | rename file (updates imports) |
| `<Space>cf` | format file / selection |
| `<Space>cd` or `<C-w>d` | diagnostic under cursor |
| `[d` / `]d` | previous / next diagnostic |
| `]]` / `[[` | next / previous use of the word under the cursor |
| `<Space>ce` | Rust: expand macro |
| `<Space>ch` | C/C++: switch header ↔ source |
| `<Space>ci` / `cH` | C/C++: symbol info / type hierarchy |
| `<Space>cA` / `cM` | C/C++: show AST / clangd memory usage |

**Completion** (insert mode): `<C-n>`/`<C-p>` next/previous, `<C-y>` accept, `<C-e>` close,
`<C-space>` open/toggle docs, `<Tab>`/`<S-Tab>` jump between snippet placeholders. These are Vim's
standard completion keys, so they work everywhere.

### Text objects and motions

| Key | Action |
|---|---|
| `af` / `if` | a function / inside a function: `vaf`, `dif`, `yaf` |
| `ac` / `ic` | a class / inside a class |
| `aa` / `ia` | an argument / inside an argument: `cia` changes one argument |
| `ih` | inside git hunk |
| `ii` / `ai` | inside / around indent scope |
| `]f` / `[f` | next / previous function |
| `]C` / `[C` | next / previous class |
| `]h` / `[h` | next / previous git hunk |
| `]t` / `[t` | next / previous TODO comment |
| `s` | flash jump: type 2 chars, then the label |
| `S` | flash: select a syntax node (great with `y`, `d`, `c`) |
| `ys{motion}{char}` | add surround: `ysiw"` → `"word"`, `ysip(` |
| `cs{old}{new}` | change surround: `cs"'` |
| `ds{char}` | delete surround: `ds(` |
| `S{char}` (visual) | surround the selection |
| `za` / `zR` / `zM` | toggle fold / open all / close all |

### Git (`<Space>g`)

| Key | Action |
|---|---|
| `<Space>gg` | lazygit (commit, push, rebase, ...) |
| `<Space>gs` / `gc` | status / commits (picker) |
| `<Space>gb` / `gA` | blame line / blame whole file |
| `<Space>ghs` / `ghr` | stage / reset hunk (works on a visual selection too) |
| `<Space>ghS` / `ghR` | stage / reset whole file |
| `<Space>ghp` | preview hunk |
| `<Space>gd` / `gD` | open / close diff view |
| `<Space>gF` / `gf` | file history (diffview / lazygit) |
| `<Space>gl` | git log (lazygit) |
| `<Space>gB` | open file on GitHub/GitLab |

### Debug (`<Space>d`) and tests (`<Space>t`)

| Key | Action | Key | Action |
|---|---|---|---|
| `<Space>db` / `F9` | toggle breakpoint | `<Space>tt` | run nearest test |
| `<Space>dB` | conditional breakpoint | `<Space>tf` | run tests in file |
| `<Space>dc` / `F5` | start / continue | `<Space>tT` | run all tests |
| `<Space>dC` | run to cursor | `<Space>tl` | run last |
| `<Space>do` / `F10` | step over | `<Space>td` | debug nearest test |
| `<Space>di` / `F11` | step into | `<Space>ts` | summary panel |
| `<Space>dO` / `F12` | step out | `<Space>to` / `tO` | output / output panel |
| `<Space>de` | evaluate expression | `<Space>tw` | watch file |
| `<Space>du` / `dr` | toggle UI / REPL | `<Space>tS` | stop |
| `<Space>dl` / `dt` | run last / terminate | | |

**Tasks** (`<Space>r`): `<Space>rr` runs a task (cargo build, cmake, make, ...), `<Space>rt` toggles the task list, and `<Space>ra` acts on a task (restart, stop, ...).

### CMake (`<Space>m`)

| Key | Action | Key | Action |
|---|---|---|---|
| `<Space>mg` | generate (configure) + link compile_commands.json | `<Space>mt` | select build target |
| `<Space>mb` | build | `<Space>ml` | select launch target |
| `<Space>mr` | run | `<Space>mv` | select build type (Debug/Release) |
| `<Space>md` | debug (codelldb) | `<Space>mp` | select configure preset |
| `<Space>mT` | run tests (ctest) | `<Space>ma` | set launch arguments |
| `<Space>mc` | clean | `<Space>ms` | stop build |

### Lists (`<Space>x`), UI toggles (`<Space>u`), sessions (`<Space>q`)

| Key | Action | Key | Action |
|---|---|---|---|
| `<Space>xx` / `xX` | diagnostics project / buffer | `<Space>uC` | **colorscheme picker (live preview)** |
| `<Space>xs` | symbols outline | `<Space>uf` | format on save on/off |
| `<Space>xq` / `xl` | quickfix / location list | `<Space>uh` | inlay hints |
| `<Space>xt` | TODO list | `<Space>ud` | diagnostics |
| `<Space>qs` | restore session for this folder | `<Space>uw` / `us` | wrap / spell |
| `<Space>ql` / `qS` | last session / pick session | `<Space>uL` | relative numbers |
| `<Space>qd` | don't save this session | `<Space>ug` / `uT` | indent guides / treesitter |
| | | `<Space>uz` / `uD` | zen mode / dim inactive code |

## Languages

**C / C++ / CUDA (CMake)**: clangd is the language server for all three, including CUDA (there's no
separate "CUDA LSP"). clangd_extensions adds extra views, and cmake-tools drives CMake.

1. **Open the project root** (the folder with the top-level `CMakeLists.txt`) and press `<Space>mg`. This
   configures into `build/<BuildType>/` and links `compile_commands.json` into the project root, which is
   how clangd learns your include paths and flags. It regenerates automatically when you save a
   `CMakeLists.txt`.
2. **Build, run, debug**:
   - `<Space>mb` builds, `<Space>mr` runs, `<Space>md` debugs the selected target in codelldb, and `<Space>mT` runs `ctest`.
   - Pick the target with `<Space>mt` (build) or `<Space>ml` (launch), and Debug/Release with `<Space>mv`.
   - If you use `CMakePresets.json`, pick a preset with `<Space>mp`.
   - Build output and errors appear in the task list (`<Space>rt`).
3. **CUDA, once per machine**: run `:CudaClangdSetup`, then restart Neovim.
   - Without this step, every `.cu` file is full of "unknown argument" errors. CMake writes nvcc-only
     flags (`--generate-code=…`, `-Xcompiler`, `--expt-relaxed-constexpr`, …) into
     `compile_commands.json`, and clangd doesn't know them.
   - The command reads your GPU's compute capability from `nvidia-smi` (for example 8.9 → `sm_89`).
   - It writes [`nvim/templates/clangd-cuda.yaml`](nvim/templates/clangd-cuda.yaml) into clangd's user config
     (`~/.config/clangd/config.yaml`). That file strips the nvcc flags, sets the GPU arch, and makes `.cuh`
     headers parse as CUDA. The rules only apply to `.cu`/`.cuh` files.
   - If you already have that file, merge the template by hand, or use `:CudaClangdSetup!` to replace it
     (a `.bak` copy is kept).
   - The toolkit is found automatically in `$CUDA_PATH`, `$CUDA_HOME`, next to `nvcc`, `/usr/local/cuda`
     or `/opt/cuda`. You can also pass a folder: `:CudaClangdSetup /path/to/cuda`.
4. **Navigate**:
   - All the usual LSP keys work, including on `__global__` kernels (`gd`, `grr`, `K`, `grn`, `gra`).
   - C++ extras: `<Space>ch` switches between header and source, `<Space>ci` shows symbol info,
     `<Space>cH` shows the type hierarchy, `<Space>cA` shows the AST (also works on a selection), and
     `<Space>cM` shows clangd's memory usage.

A good CMake starting point for CUDA:

```cmake
cmake_minimum_required(VERSION 3.24)
project(app LANGUAGES CXX CUDA)
set(CMAKE_CUDA_ARCHITECTURES native)   # build for the GPU in this machine
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CUDA_STANDARD 20)
add_executable(app main.cu)
```

- **Formatting** runs **only if the project has a `.clang-format` file**, so you never reformat a
  codebase that doesn't use clang-format. Create one with `clang-format -style=llvm -dump-config > .clang-format`.
- **Debugging**: codelldb debugs host code (build type Debug, then `<Space>md` or `<Space>dc`). For
  device code (inside kernels), run NVIDIA's `cuda-gdb ./build/Debug/app` in a terminal (`<C-/>`).
  Build with `-G` for device debug info. Use `compute-sanitizer ./app` to find out-of-bounds and race bugs.
- **Tests**: GoogleTest tests run through neotest (`<Space>tt`), or all of them via ctest (`<Space>mT`).
- **Not a CMake project?** Generate `compile_commands.json` with `bear -- make`.
- **Mac / machines without CUDA**: C and C++ work normally, but there's no CUDA toolkit to build,
  run or debug with.
  - **Recommended**: do CUDA work on the GPU machine over SSH (see
    [Remote development](#remote-development-and-zellij)), where everything works.
  - On the Mac, `:CudaClangdSetup` detects that CUDA is missing, explains the options, and writes nothing.
  - To read and write `.cu` files offline on the Mac, copy the headers once and point clangd at them:

    ```bash
    rsync -a <gpu-host>:/usr/local/cuda/include/ ~/.local/cuda/include/
    ```

    Then run `:CudaClangdSetup ~/.local/cuda` in nvim. This gets you completion, hover and
    go-to-definition for the CUDA API. CMake can't configure a CUDA project without `nvcc`, though, so
    your project's own include paths are guessed. For real work, use the GPU machine.

**Rust**: install rust-analyzer with `rustup component add rust-analyzer`. rustaceanvim sets it up with
clippy checks. Useful commands: `:RustLsp runnables`, `:RustLsp debuggables`, `:RustLsp explainError`,
`:RustLsp openCargo`. `K` shows hover actions. Tests run through neotest (`<Space>tt`).

**Python**: basedpyright handles types and navigation, ruff handles lint, format and import sorting.
Activate your virtualenv before starting `nvim`, or keep a `.venv` in the project root, so imports resolve.
Change strictness in `after/lsp/basedpyright.lua` (`typeCheckingMode`). Tests use pytest via neotest; debugging uses debugpy.

**Lean 4**: install [elan](https://github.com/leanprover/elan) and open a file in a Lake project.
lean.nvim starts the server and the infoview. Type unicode with backslash abbreviations (`\alpha` → α,
`\to` → →). Lean keymaps use the *local* leader `\`; for example `\i` toggles the infoview. See `:help lean`.

**Lua**: lua_ls and lazydev give full completion for the Neovim API while you edit this config.

**Other languages**: open `:Mason` and press `i` on a server to install it (mason-lspconfig enables
it automatically), then run `:TSInstall <language>` for highlighting.

## Customizing

- **Theme**: change `COLORSCHEME` at the top of `lua/plugins/colorscheme.lua` (try options live with
  `<Space>uC`). Set `TRANSPARENT = false` for a solid background. With transparency on, Neovim shows your
  terminal's background color or image, so set that in your terminal.
- **Add a plugin**: create `lua/plugins/<name>.lua` returning a spec:

  ```lua
  return {
    "author/plugin.nvim",
    event = "VeryLazy", -- or cmd = ..., ft = ..., keys = ... to load it lazily
    opts = {},          -- passed to require("plugin").setup()
  }
  ```

- **Add or tune a language server**: install it in `:Mason` (or add it to `ensure_installed` in
  `lua/plugins/lsp.lua`). To change its settings, create `after/lsp/<server>.lua` returning a table
  (see the existing files). Server names are listed in `:help lspconfig-all`.
- **Add a formatter**: add it under `formatters_by_ft` in `lua/plugins/formatting.lua` and to the Mason list.
- **Disable format on save** for one project: `<Space>uf`, or put `vim.b.disable_autoformat = true` in an autocmd.
- **Change a keymap**: global ones live in `lua/config/keymaps.lua`. Plugin keymaps sit in each
  plugin's `keys = { ... }` table. LSP keymaps are in `lua/config/autocmds.lua`.
- **Profile startup**: `:Lazy profile`.

## Remote development and Zellij

**Should Neovim run on the server? Yes.**
- Language servers, compilers, the CUDA toolkit and the debugger have to run where the code and the
  GPU are. So run nvim *on* the server over SSH, with the same config installed there by `install.sh`
  (see [One config, every machine](#one-config-every-machine)).
- Editing remote files from your laptop's nvim (sshfs, `scp://`, remote-editing plugins) doesn't work
  well for C++/CUDA: your laptop's clangd can't see the server's headers, toolkit or build.
- Neovim's `--remote-ui` (editor on the server, UI on the laptop) still needs the config on the server,
  so it doesn't save you anything over plain SSH.

**Recommended setup**: run a terminal on your laptop (Ghostty, WezTerm, Kitty, iTerm2 or Windows
Terminal) → `ssh devbox` → **Zellij on the server** → `nvim`. When your SSH connection drops, the
Zellij session keeps running. Reconnect and run `zellij attach` to get everything back.

**Clipboard**: over SSH, yanking sends the text to your laptop with OSC 52 (set up in `options.lua`).
Your terminal must allow it:
- Ghostty, WezTerm, Kitty and Windows Terminal allow it by default.
- iTerm2: enable *Settings → General → Selection → Applications in terminal may access clipboard*.

To paste text from your laptop into nvim, use your terminal's paste shortcut (`Cmd-V` / `Ctrl-Shift-V`) in insert mode.

**macOS Alt key**: the `<A-h/j/k/l>` resize keys need Option to act as Alt:
- Ghostty: `macos-option-as-alt = true`
- Kitty: `macos_option_as_alt yes`
- iTerm2: Profiles → Keys → Left Option = Esc+
- WezTerm: `send_composed_key_when_left_alt_is_pressed = false`

### Zellij

Install it on the server (`cargo install --locked zellij`, or a binary from the
[releases page](https://github.com/zellij-org/zellij/releases)). Then:

1. **Avoid key clashes with Neovim**: choose the **"Unlock-First (non-colliding)"** keybinding preset.
   Zellij offers it on first start, and you can change it later from its configuration screen. In this
   mode Zellij ignores your keys until you press `Ctrl g`, so Neovim gets all of its shortcuts.
2. **Seamless `Ctrl-h/j/k/l` between Zellij panes and Neovim splits**: add the
   [vim-zellij-navigator](https://github.com/hiasr/vim-zellij-navigator) plugin to
   `~/.config/zellij/config.kdl`. Pin the URL to a version from its releases page.

   ```kdl
   keybinds {
       shared_among "normal" "locked" {
           bind "Ctrl h" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "move_focus_or_tab"; payload "left"; move_mod "ctrl"; }; }
           bind "Ctrl j" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "move_focus"; payload "down"; move_mod "ctrl"; }; }
           bind "Ctrl k" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "move_focus"; payload "up"; move_mod "ctrl"; }; }
           bind "Ctrl l" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "move_focus_or_tab"; payload "right"; move_mod "ctrl"; }; }
           bind "Alt h" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "resize"; payload "left"; resize_mod "alt"; }; }
           bind "Alt j" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "resize"; payload "down"; resize_mod "alt"; }; }
           bind "Alt k" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "resize"; payload "up"; resize_mod "alt"; }; }
           bind "Alt l" { MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm" { name "resize"; payload "right"; resize_mod "alt"; }; }
       }
   }
   ```

   In a Neovim pane the keys go to smart-splits.nvim, which moves between splits and hands off to Zellij
   at the edge. In other panes Zellij moves focus itself.
3. **Everyday Zellij**: `zellij -s work` starts a named session, `zellij attach work` reattaches, and
   `zellij ls` lists sessions. Inside, `Ctrl g` unlocks Zellij's keys and the hint bar at the bottom
   shows what's available (new pane, tab, floating pane, ...).

Prefer tmux? The Neovim side works unchanged (smart-splits auto-detects tmux). Add
[smart-splits' tmux snippet](https://github.com/mrjones2014/smart-splits.nvim#tmux) to `~/.tmux.conf`.

## Learning Vim

### The one idea: modes

Vim is **modal**. Most of the time you are in **Normal mode**, where every key is a *command*, not text.

| Mode | How to enter | What it's for |
|---|---|---|
| Normal | `<Esc>`, `<C-[>` or `jk` from any mode | moving and editing with commands (home base) |
| Insert | `i` before cursor, `a` after, `o` new line below, `O` above, `I` line start, `A` line end | typing text |
| Visual | `v` characters, `V` lines, `<C-v>` block | selecting, then acting on the selection |
| Command | `:` | `:w` save, `:q` quit, `:%s/old/new/g` replace, `:help topic` |

Yes, `i` enters Insert mode, and you'll press it hundreds of times a day. So will you press `<Esc>` to get
back. Since `<Esc>` is far from the home row, this config gives you `jk`, and `<C-[>` works everywhere
without any setup. Even better, remap **Caps Lock to Esc when tapped and Ctrl when held**. That works in
every app on every OS: [kanata](https://github.com/jtroo/kanata) (macOS, Linux, Windows), or your
keyboard's firmware (QMK/ZMK/VIA). You'll use Ctrl constantly too (`<C-d>`, `<C-o>`, `<C-w>`), so it pays off twice.

### The grammar: verb + count + noun

Normal-mode commands combine like a language: an **operator** (verb), an optional **count**, and a
**motion or text object** (noun).

| Verbs | | Nouns (motions) | | Nouns (text objects) | |
|---|---|---|---|---|---|
| `d` | delete | `w` / `b` / `e` | next word / back / end | `iw` / `aw` | inner / a word |
| `c` | change (delete + insert) | `0` / `^` / `$` | line start / first char / end | `i"` / `a"` | inside / around quotes |
| `y` | yank (copy) | `f{c}` / `t{c}` | find / till char on line | `i(` / `a(` | inside / around parens |
| `>` / `<` | indent | `gg` / `G` | file start / end | `ip` | inner paragraph |
| `gc` | comment | `}` / `{` | next / previous paragraph | `it` | inside an HTML/XML tag |
| `gU` / `gu` | upper / lower case | `/text` | search | `if` / `af` | function (treesitter) |
| `=` | auto-indent | `%` | matching bracket | `ia` / `aa` | argument (treesitter) |

So `ciw` means "change inner word", `d3w` deletes three words, `yi(` copies everything inside the
parentheses, `gcap` comments a paragraph, `dif` empties a function body, and `cia` rewrites one
argument. Doubling the verb acts on the whole line: `dd`, `cc`, `yy`, `>>`, `gcc`.

Then **`.` repeats your last change**. This is Vim's superpower: `ciw` + new word, then `n` + `.` to do the same at the next match.

Other essentials: `u` undo, `<C-r>` redo, `p`/`P` paste after/before, `x` delete a character, `r`
replace a character, `*` search for the word under the cursor, `;`/`,` repeat `f`/`t` forward/back,
`<C-o>`/`<C-i>` jump back/forward, `q{a-z}`…`q` record a macro and `@{a-z}` play it.

### A 4-week plan

1. **Week 1 – survive.** Run `:Tutor` (the dashboard has a shortcut: `t`) twice. Use only `hjkl`,
   `w b e`, `0 $`, `gg G`, `i a o`, `x dd yy p`, `u <C-r>`, `:w :q`. Turn off the mouse in your head.
2. **Week 2 – speak the grammar.** Use `ciw`, `di(`, `ya"`, `dap`, `f`/`t` + `;`, counts (`5j`, using the
   relative numbers), `.` repeat, `V` + `>`, `*`, and `s` (flash) to jump. Whenever you hold `j` or `l`, stop and find a better motion.
3. **Week 3 – work like an IDE.** Use `<Space><Space>`, `<Space>/`, `<Space>,`, `gd` + `<C-o>`, `grr`, `K`,
   `gra`, `grn`, `]d`, `<Space>e`, splits with `<Space>|` and `<C-h/l>`. Do all your real work in Neovim this week.
4. **Week 4 – power tools.** Learn macros (`qa…q`, `10@a`), `:%s/x/y/gc` (with live preview), the
   quickfix workflow (grep → `<C-q>` → `:cdo s/x/y/` → `:wa`), registers (`"ay`, `"ap`), lazygit
   (`<Space>gg`), the debugger (`<Space>db`, `<Space>dc`) and tests (`<Space>tt`).

After that, **learn one new thing per week**. When you do something clumsy three times, look up the better way (`<Space>sh` searches `:help`).

### Drills and resources

- `:Tutor`, then `:help user-manual`: the built-in manual is excellent.
- [vim-be-good](https://github.com/ThePrimeagen/vim-be-good): motion drills as a game.
- [hardtime.nvim](https://github.com/m4xshen/hardtime.nvim): blocks bad habits like holding `j` and hints better motions.
- [precognition.nvim](https://github.com/tris203/precognition.nvim): shows where motions would take you.
- *Practical Vim* by Drew Neil: the best book on thinking in Vim.
- [Vimcasts](http://vimcasts.org), and TJ DeVries and ThePrimeagen on YouTube.
- `:help lua-guide`, for when you start customizing this config.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Boxes/question marks instead of icons | Install a Nerd Font and select it in your terminal |
| Something errors on start | `:messages`, `:checkhealth`, `:Lazy` (shows plugin errors and logs) |
| LSP not attaching / wrong server | `:checkhealth vim.lsp`, `:Mason` (is it installed?), `:lua =vim.lsp.get_clients()` |
| clangd can't find headers | `<Space>mg` in a CMake project (or `bear -- make`) to create `compile_commands.json` |
| "Unknown argument" errors in `.cu` files | run `:CudaClangdSetup`, then restart Neovim |
| No syntax colors | `:checkhealth nvim-treesitter`; is `tree-sitter` installed (`:Mason`)? Restart after the first install |
| Format on save does nothing | `:ConformInfo`; for C/C++ add a `.clang-format`; check `<Space>uf` |
| Yank doesn't reach laptop over SSH | terminal must allow OSC 52 (see [Remote](#remote-development-and-zellij)) |
| `<A-h>` types a symbol on macOS | set Option as Alt in your terminal |
| `<C-/>` does nothing | your terminal may send `<C-_>`, which is mapped too; otherwise use `:lua Snacks.terminal()` |
| Fully broken after an update | `:Lazy restore` (back to lockfile) or the reset command in [Update](#update-reset-uninstall) |

## More plugins worth knowing

Not installed, to keep things lean. Add them once the basics feel natural.

- **AI**:
  - [claudecode.nvim](https://github.com/coder/claudecode.nvim): Claude Code integration
  - [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim): chat and inline edits with any LLM
  - [copilot.lua](https://github.com/zbirenbaum/copilot.lua) + [blink-copilot](https://github.com/fang2hou/blink-copilot)
- **Files**: [oil.nvim](https://github.com/stevearc/oil.nvim), which lets you edit a directory like a text buffer (bulk renames).
- **Bookmarks**: [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) or
  [grapple.nvim](https://github.com/cbochs/grapple.nvim), for instant jumps between 4–5 key files.
- **Search & replace across files**: [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim).
- **Markdown**: [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim).
- **UI**: [noice.nvim](https://github.com/folke/noice.nvim), which replaces the command line and messages UI.
- **Built-in plugin manager**: Neovim 0.12 ships `vim.pack`. lazy.nvim is kept here for lazy-loading
  and the lockfile UI, but `vim.pack` is worth watching.

## What changed in the 2026 rewrite

The previous config was audited. Fixed:
- **Startup error**: `vim.lsp.buf.signature_help()` ran at startup with no server attached, and the
  signature handler override used a key that doesn't exist. Signature help was also defined three times;
  it's now handled by blink (`<C-k>`).
- **`<Space>e` was mapped twice** (file tree and diagnostics). The buffer-local one won, so the tree never opened in code files.
- **Prefix collisions added a pause before mappings fired**: `<Space>w` vs `<Space>wa`, `<Space>f`
  vs `<Space>ff`, and `gr` vs Neovim's built-in `grn`/`gra`/`grr`. `gi` also shadowed a useful built-in.
- **`<Esc>` was remapped in every terminal**, which broke Esc inside fzf, lazygit and yazi.
- **Dead files** (`config/dropbar.lua`, `config/toggleterm.lua`) required modules that didn't exist.
- **Two different colorscheme calls** fought each other.
- **Hard-coded paths and deprecated APIs**: the `/home/user/.cargo/bin` PATH was hardcoded, and
  `vim.diagnostic.goto_*` is deprecated.
- **`,` was used as the local leader**, which disabled its built-in "repeat `f`/`t` backwards" motion.
- **Duplicate and unused tools were consolidated**:
  - Telescope (pinned to a 2024 release, with 9 extensions installed and never loaded) and fzf-lua → fzf-lua.
  - Neo-tree, yazi and netrw → snacks explorer.
  - toggleterm → snacks terminal.
  - lspsaga → Neovim's native LSP UI.
  - Mason was declared twice.
- **Added** treesitter, formatting, git signs, statusline, debugger, tests, sessions, OSC 52
  clipboard, multiplexer-aware splits, and sane defaults (persistent undo, fixed sign column,
  `inccommand`, rounded borders, and more).
- **`lazy-lock.json` is now committed** (it was gitignored), so setups are reproducible.
