# VeribleFilelist

Scan source directories and automatically generate the VCS filelist from the
module instantiation/import dependency graph. You should **never write or edit
`filelist/*.f` by hand** — it is generated on every compile.

## Requirements

- Linux (the `initial.sh` script downloads a Linux static build of verible)
- Python 3 + `pip install anytree`
- `verible-verilog-syntax` at `./verible/bin/verible-verilog-syntax`
  (run `bash initial.sh` once)

## Usage

Normally called through `tool/VCS/Makefile` (`make filelist` / `make compile`):

```bash
python3 main.py -t <top_module> -s <dir1> <dir2> ... -d "<+define+A +define+B>"
```

| Option | Meaning |
|---|---|
| `-t/--topmodule` | Top **module name** (not file name / path) |
| `-s/--search-paths` | Directories scanned recursively (required) |
| `-d/--defines` | Compile-time defines; pass the same string used for VCS |
| `-b/--build-database` | Rebuild the cache database from scratch |
| `-c/--clean-filelist` | Delete generated `.f` files |
| `-p/--path-save` | Custom output directory (default `../VCS/filelist`) |

## What it does

1. Recursively scans each `-s` directory:
   - files under a directory named exactly `testbench` are classified as testbenches;
   - directories named `abandon` are pruned entirely;
   - `.svh` files are collected as include directories (`+incdir+`);
   - other `.v/.sv` files are treated as design sources.
2. Preprocesses `` `define``/`` `ifdef`` with the given defines, then parses with
   verible to extract module/interface names, instantiations (`reference`),
   imports and includes.
3. Builds a `module -> file` + `module -> references` graph and performs a
   post-order DFS from `-t`: dependencies come first, the top file last.
   Only reachable modules are included — a small tb does not compile the whole SoC.
4. Writes `filelist/<top>.f` (absolute paths, plus `+incdir+` lines).
5. Caches the parsed database in `./cache/*.pkl` (mtime-based incremental update).

## Notes / known limitations

- The cache **does not store the defines**: after changing `` `ifdef`` structure or
  `-d`, rebuild with `-b` (or `rm -rf cache`) or the filelist may follow old branches.
- If `-t` is wrong, it still writes a (nearly empty) `.f` and prints
  `!!! Filelist generated failed` — check the log.
- Duplicate module names silently overwrite each other (`module -> file` is a dict).
- One module per file is strongly recommended (the tool warns but does not fail).
- `-s` paths are resolved relative to this tool's directory; the Makefile paths
  (`../../src`, `../../lib`) are written for `tool/VCS`, which has the same depth.
