# Neovim cheat sheet

Everyday operations for this config on one page. `<Space>` is the leader; `<C-x>` means Ctrl-x,
`<S-x>` Shift-x, `<A-x>` Alt/Option-x. Forgot a key? Press `<Space>` and wait, or search them all with
`<Space>sk`. The full reference is in the [README](README.md#keymaps).

- [Daily workflow (any language)](#daily-workflow-any-language)
- [Survival](#survival)
- [How do I…?](#how-do-i) (copy all, select all, duplicate a line, ...)
- [Copy, cut and paste](#copy-cut-and-paste)
- [Undo and redo](#undo-and-redo)
- [Moving around](#moving-around)
- [Editing](#editing)
- [Autocomplete](#autocomplete)
- [Selecting (visual mode)](#selecting-visual-mode)
- [Search and replace](#search-and-replace)
- [Files and buffers](#files-and-buffers)
- [Windows, splits and tabs](#windows-splits-and-tabs)
- [Terminal](#terminal)
- [Code (LSP)](#code-lsp)
- [Formatting](#formatting)
- [Run, test, debug](#run-test-debug)
- [Add a language](#add-a-language)
- [Git](#git)
- [Folds, macros, marks](#folds-macros-marks)
- [Getting help](#getting-help)

## Daily workflow (any language)

| Step | Keys |
|---|---|
| Open the project | `cd project && nvim`, then `s` on the dashboard (or `<Space>qs`) to restore the last session |
| Find a file / text | `<Space><Space>` / `<Space>/` |
| Read code | `gd` definition, `grr` references, `K` docs, `<C-o>` back |
| Edit | `<Tab>` accepts completion, `grn` rename, `gra` quick fix, `]d` next error |
| Run | `<Space>rf` this file, `<Space>rr` a project task |
| Test | `<Space>tt` nearest, `<Space>tf` file |
| Debug | `<Space>db` breakpoint, `<Space>dc` start |
| Format | on save, or `<Space>cf` |
| Shell | `<Space>ft` |
| Commit | `<Space>gg` (lazygit: `space` stage, `c` commit, `P` push) |

## Survival

| Do this | Keys |
|---|---|
| Back to normal mode | `<Esc>`, `jk` or `<C-[>` |
| Start typing | `i` before cursor, `a` after, `o` new line below, `O` above, `A` end of line, `I` start |
| Save | `<C-s>` (any mode) or `:w` |
| Save all | `:wa` |
| Quit window | `:q` (`:q!` discards changes) |
| Save and quit | `:wq` or `ZZ` |
| Quit everything | `<Space>qq` (`:qa!` discards all changes) |
| Cancel a half-typed command | `<Esc>` |

## How do I…?

| Task | Keys |
|---|---|
| **Select all** | `ggVG` |
| **Copy all** (whole file to the clipboard) | `:%y` or `ggyG` |
| **Cut all** | `:%d` or `ggdG` |
| **Replace the whole file with the clipboard** | `ggVGp` |
| **Delete all** without touching the clipboard | `:%d _` |
| Copy the current line | `yy` |
| Copy lines 10–20 | `:10,20y` |
| Duplicate the line | `yyp` (or `:t.`) |
| Move the line down / up | `:m+1` / `:m-2`, or `V` then `J` / `K` |
| Copy the file's path | `:let @+ = expand("%")` (relative) or `expand("%:p")` (absolute) |
| Show the file name and position | `<C-g>` |
| Go to line 42 | `42G` or `:42` |
| Re-indent the whole file | `gg=G` (or format with `<Space>cf`) |
| Sort lines | `V`, select, `:sort` (`:sort u` also removes duplicates) |
| Remove trailing whitespace | `:%s/\s\+$//e` |
| Count matches of a word | `:%s/word//gn` |
| Join the next line onto this one | `J` |
| Uppercase / lowercase a word | `gUiw` / `guiw` (`~` toggles one character) |
| Add / subtract 1 from a number | `<C-a>` / `<C-x>` (`5<C-a>` adds 5) |
| Comment a line / selection | `gcc` / `gc` in visual mode |
| Wrap a word in quotes | `ysiw"` (`ds"` removes them, `cs"'` changes them) |
| Discard unsaved changes | `:e!` |
| Reload a file changed on disk | `:e` (happens automatically on focus) |
| Open the URL / file under the cursor | `gx` / `gf` |
| Toggle line wrap / spell check | `<Space>uw` / `<Space>us` |
| Start a new empty file | `<Space>fn` |
| Rename the current file | `<Space>cR` (also updates imports) |

## Copy, cut and paste

The clipboard is shared with your OS (`clipboard=unnamedplus`): `y` copies straight to it and `p`
pastes from it. Over SSH, yanks reach your laptop's clipboard through OSC 52 (see the
[README](README.md#remote-development-and-zellij)).

| Do this | Keys |
|---|---|
| Copy (yank) | `y{motion}`: `yiw` word, `yy` line, `y$` to end of line, `yap` paragraph, `yaf` function |
| Copy a selection | `v` / `V` / `<C-v>`, select, then `y` |
| Cut | `d{motion}` (`dd` line, `diw` word) or select + `d`. `x` cuts one character |
| Paste after / before the cursor | `p` / `P` |
| Paste over a selection, keep what you copied | select, then `P` (lower-case `p` swaps them) |
| Paste the last thing you **yanked** (not deleted) | `"0p` |
| Delete without overwriting the clipboard | `"_d{motion}`, e.g. `"_dd` |
| Paste in insert mode | `<C-r>+` (or `<C-r>0` for the last yank) |
| Paste in the command line (`:`, `/`) | `<C-r>+`; `<C-r><C-w>` inserts the word under the cursor |
| Paste from your **laptop** while on SSH | your terminal's paste key (`Cmd-V` / `Ctrl-Shift-V`) in insert mode |
| Browse everything you copied/deleted | `<Space>sR` (registers) |
| Copy into / paste from a named register | `"ayy` / `"ap` (`"Ayy` appends to `a`) |

> **Heads-up:** `d`, `c` and `x` also put the deleted text on the clipboard, replacing what you
> copied. Use `"_d` (black hole) when you only want to delete, or `"0p` to get your last yank back.

## Undo and redo

| Do this | Keys |
|---|---|
| Undo / redo | `u` / `<C-r>` |
| Repeat the last change | `.` |
| Go back in time | `:earlier 5m` / `:later 5m` |
| Jump to the last change | `` `. `` (and `g;` / `g,` to walk through older changes) |

Undo history is saved to disk, so it survives closing the file.

## Moving around

| Do this | Keys |
|---|---|
| Left / down / up / right | `h` `j` `k` `l` (counts: `5j`, using the relative numbers) |
| Next word / back / end of word | `w` / `b` / `e` (`W` `B` `E` skip punctuation) |
| Line start / first character / end | `0` / `^` / `$` |
| File start / end | `gg` / `G` |
| Half page down / up | `<C-d>` / `<C-u>` |
| Top / middle / bottom of the screen | `H` / `M` / `L` |
| Center / top / bottom the current line | `zz` / `zt` / `zb` |
| Next / previous paragraph | `}` / `{` |
| Matching bracket | `%` |
| Find a character on the line | `f{c}` / `t{c}` (`F` `T` backwards; `;` `,` repeat) |
| **Jump anywhere on screen** | `s` + 2 characters + the label (flash) |
| Next / previous function | `]f` / `[f` (`]C` / `[C` classes) |
| Jump back / forward | `<C-o>` / `<C-i>` |

## Editing

| Do this | Keys |
|---|---|
| Change (delete and type) | `c{motion}`: `ciw` word, `ci"` inside quotes, `ci(` inside parens, `cc` line, `C` to end |
| Delete | `d{motion}`: `dw`, `dd`, `D` to end of line, `dif` function body |
| Replace one character | `r{c}` |
| Substitute one character | `cl` (`s` is the flash jump in this config) |
| Indent / unindent | `>>` / `<<`, or `>` / `<` in visual mode (the selection stays) |
| Auto-indent | `=ip` paragraph, `gg=G` whole file |
| Change one function argument | `cia` (`daa` deletes it, with the comma) |
| Surround | `ys{motion}{char}` add, `cs{old}{new}` change, `ds{char}` delete, `S{char}` in visual |

## Autocomplete

The menu opens by itself as you type (insert mode).

| Do this | Keys |
|---|---|
| **Accept the suggestion** | `<Tab>` (takes the first one if you haven't picked) or `<C-y>` |
| Pick the next / previous suggestion | `<C-n>` / `<C-p>` or `<Down>` / `<Up>` |
| Close the menu | `<C-e>` |
| Open the menu yourself | `<C-space>` (press again to toggle the docs) |
| Scroll the docs window | `<C-b>` / `<C-f>` |
| Next / previous snippet placeholder | `<Tab>` / `<S-Tab>` (when no menu is open) |
| Insert a real tab while the menu is open | `<C-e>` then `<Tab>`, or `<C-v><Tab>` |
| Show the function's parameters | `<C-k>` |
| Complete a file path | type `./` or `/` and pick from the menu |

## Selecting (visual mode)

| Do this | Keys |
|---|---|
| Select characters / lines / a block | `v` / `V` / `<C-v>` |
| Select a word / paragraph / function | `viw` / `vip` / `vaf` |
| Select inside quotes / brackets | `vi"` / `vi(` / `vi{` |
| Select a syntax node | `S` then a label (flash treesitter) |
| Reselect the last selection | `gv` |
| Jump to the other end of the selection | `o` |
| Move the selected lines down / up | `J` / `K` |
| Type on many lines at once | `<C-v>`, select lines, `I` (or `$A`), type, `<Esc>` |
| Run a command on the selection | `:` (shows `:'<,'>`), e.g. `:s/a/b/g` or `:sort` |

## Search and replace

| Do this | Keys |
|---|---|
| Search forward / backward | `/text` / `?text`, then `n` / `N` |
| Search the word under the cursor | `*` (forward) / `#` (backward) |
| Clear the highlight | `<Esc>` |
| Replace in the file | `:%s/old/new/g` (live preview as you type) |
| …and confirm each one | `:%s/old/new/gc` (`y`/`n`/`a` all/`q` quit) |
| Replace whole words only | `:%s/\<old\>/new/g` |
| Replace in a selection | select, then `:s/old/new/g` |
| Change one match, then repeat | `*`, `cgn`, type the new word, `<Esc>`, then `.` for each next match |
| **Search the whole project** | `<Space>/` (or `<Space>sw` for the word under the cursor) |
| Search in this file (fuzzy) | `<Space>sb` |
| **Replace across the project** | `<Space>/`, search, `<C-q>` (sends results to quickfix), then `:cdo s/old/new/g \| update` |
| Reopen the last search | `<Space>sr` |

## Files and buffers

A *buffer* is an open file. Splits and tabs only show buffers.

| Do this | Keys |
|---|---|
| Find a file | `<Space><Space>` |
| Recent files | `<Space>fr` |
| Switch between open files | `<Space>,` or `<S-h>` / `<S-l>` |
| Go back to the previous file | `<Space>bb` (or `<C-^>`) |
| File explorer | `<Space>e` (`a` add, `r` rename, `d` delete, `c` copy, `m` move, `?` help) |
| Close the file | `<Space>bd` (`<Space>bo` closes all others) |
| Save as | `:saveas newname` |
| Open a config file | `<Space>fc` |
| Restore the last session for this folder | `<Space>qs` |

## Windows, splits and tabs

| Do this | Keys |
|---|---|
| Split below / right | `<Space>-` / `<Space>\|` |
| Move between splits (and Zellij/tmux panes) | `<C-h>` `<C-j>` `<C-k>` `<C-l>` |
| Resize | `<A-h>` `<A-j>` `<A-k>` `<A-l>` |
| Make all splits equal | `<Space>w=` |
| Close this split / all other splits | `<Space>wq` / `<Space>wo` |
| Maximize a split for a while | `<Space>uz` (zen mode) |
| New tab / next / previous | `:tabnew` / `gt` / `gT` |

`<Space>w` accepts every `<C-w>` window command.

## Terminal

| Do this | Keys |
|---|---|
| **Open / hide the terminal** | `<Space>ft` (always works) or `<C-/>` (if your terminal sends it) |
| Leave terminal mode | `<Esc><Esc>` (or `<C-\><C-n>`) |
| Hide it from normal mode | `q` |
| Type into it again | `i` or `a` |
| A second terminal | `2<Space>ft` |
| Copy terminal output | `<Esc><Esc>`, then `v` … `y` like any buffer |
| Paste into the shell | your terminal's paste key, or `<Esc><Esc>` then `p` |
| Close it for good | `exit` in the shell |
| Git UI in a floating terminal | `<Space>gg` (lazygit) |

`<C-/>` doing nothing? See [Terminal in the README](README.md#terminal).

## Code (LSP)

| Do this | Keys |
|---|---|
| Go to definition / back | `gd` / `<C-o>` |
| List references | `grr` |
| Documentation | `K` (twice to enter the window) |
| Code action (quick fix) | `gra` or `<Space>ca` |
| Rename symbol | `grn` or `<Space>cr` |
| Format the file / selection | `<Space>cf` (see [Formatting](#formatting)) |
| Next / previous error | `]d` / `[d` (`<Space>cd` shows the full message) |
| All problems in the project | `<Space>xx` |
| Symbols in this file | `<Space>ss` (`gO` for an outline) |
| Signature help while typing | `<C-k>` (insert mode) |
| C/C++: header ↔ source | `<Space>ch` |

## Formatting

| Do this | Keys |
|---|---|
| Format the file | `<Space>cf` (works in C/C++ without a `.clang-format`, using LLVM style) |
| Format a selection | select, then `<Space>cf` |
| Format a paragraph / motion with the formatter | `gqip` / `gq{motion}` |
| Turn format-on-save off / on | `<Space>uf` |
| See which formatter this file uses (or why none) | `:ConformInfo` |
| Save without formatting, just this once | `:noautocmd w` |
| Give a C/C++ project a style | `:!clang-format -style=llvm -dump-config > .clang-format` |

Formatted on save: C/C++/CUDA (only with a `.clang-format`), Python (ruff), Rust, Lua, shell, TOML,
and JSON/YAML/Markdown when `npm` is installed. Details in the [README](README.md#formatting).

## Run, test, debug

| Do this | Keys |
|---|---|
| **Run the current file** | `<Space>rf` (Python, JS/TS, Go, shell, Lua, Ruby, a single C/C++/CUDA file, `cargo run`) |
| Run a project task (make, npm scripts, cargo, just, `tasks.json`) | `<Space>rr` |
| Run any command as a task | `<Space>rr`, pick `shell`, type it (`go test ./...`, `npm test`, ...) |
| Task list / restart or stop a task | `<Space>rt` / `<Space>ra` |
| Run the nearest test / the file's tests / all | `<Space>tt` / `<Space>tf` / `<Space>tT` |
| Test summary / output | `<Space>ts` / `<Space>to` |
| Debug the nearest test | `<Space>td` |
| Toggle a breakpoint | `<Space>db` or `F9` |
| Start / continue debugging | `<Space>dc` or `F5` |
| Step over / into / out | `<Space>do` / `<Space>di` / `<Space>dO` (or `F10` / `F11` / `F12`) |
| Inspect a value | `<Space>de` (works on a selection) |
| Stop debugging | `<Space>dt` |
| CMake: configure / build / run / debug | `<Space>mg` / `<Space>mb` / `<Space>mr` / `<Space>md` |

Tests run with pytest, cargo test and GoogleTest; debugging works for Python, C/C++/CUDA and Rust, and
for any language whose project has a `.vscode/launch.json`.

## Add a language

| Do this | How |
|---|---|
| Highlighting | just open a file: the parser installs itself (or `:TSInstall go`) |
| Completion, `gd`, `K`, errors | `:LspInstall` in a file of that language, pick a server |
| Make it permanent everywhere | add the server to `ensure_installed` in `lua/plugins/lsp.lua` |
| Formatting | usually free through the language server; check with `:ConformInfo` |
| `<Space>rf` support | add a line to `runners` in `lua/config/keymaps.lua` |

Full checklist in the [README](README.md#adding-a-language).

## Git

| Do this | Keys |
|---|---|
| Lazygit (commit, push, branches, ...) | `<Space>gg` |
| Next / previous change | `]h` / `[h` |
| Preview the change | `<Space>ghp` |
| Stage / undo the change | `<Space>ghs` / `<Space>ghr` |
| Blame this line / file | `<Space>gb` / `<Space>gA` |
| Side-by-side diff / close | `<Space>gd` / `<Space>gD` |
| File history | `<Space>gF` |
| Open the file on GitHub | `<Space>gB` |

## Folds, macros, marks

| Do this | Keys |
|---|---|
| Toggle a fold / open all / close all | `za` / `zR` / `zM` |
| Record a macro / stop / play | `qa` / `q` / `@a` (`@@` repeats, `10@a` plays 10 times) |
| Set a mark / jump to it | `ma` / `` `a `` (capital letters work across files) |
| List marks | `<Space>sm` |

## Getting help

| Do this | Keys |
|---|---|
| See what keys come next | press `<Space>` (or `g`, `]`, `z`, ...) and wait |
| Search all keymaps | `<Space>sk` |
| Keymaps for this buffer | `<Space>?` |
| Search the help pages | `<Space>sh`, or `:help topic` |
| The interactive tutorial | `:Tutor` |
| Something is broken | `:checkhealth`, `:messages`, `:Lazy` |
