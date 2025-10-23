## Project Structure

This playground demonstrates linking a Rust static library built with one Rust version
into a binary built with a different Rust version.

To get the static library for linux x86-64 run:
```bash
docker build --platform=linux/amd64 --no-cache --progress=plain --target=export --output=. .
```

To reproduce the error, run:
```bash
docker build --platform=linux/amd64 --no-cache --progress=plain .
```

### Components

**rustlib** - A static library (`crate-type = ["staticlib"]`) that provides a
`hello_from_rust()` function.

**caller** - A binary crate that links against `rustlib` using a custom `build.rs` script.

**build.rs** - The build script for `caller` that:
- Uses `CARGO_MANIFEST_DIR` to locate the workspace root
- Constructs the path to the target directory based on the build profile
- Links the static library via `cargo:rustc-link-search` and `cargo:rustc-link-lib`

### Docker Multi-Stage Build

The Dockerfile demonstrates cross-version linking with three stages:

**Stage 1 (builder)**:
- Rust 1.87 compiles `rustlib` into `librustlib.a`
- Optionally runs `strip.sh` to strip symbols (if `STRIP=true`)
  - Uses `objcopy` to keep only symbols matching `rustlib_*`
  - Removes all other symbols to reduce library size

**Stage 2 (export)**:
- A `scratch` stage that contains only the static library
- Used to extract the library via `--target=export --output=.`

**Stage 3 (default)**:
- Rust 1.90 builds the `caller` binary
- Copies the static library from the export stage
- `build.rs` finds and links against the library from Stage 1

**Build Arguments**: (Used via `--build-arg=ARG=VAL`)
- `RELEASE=true` (default) - Release mode with optimizations
- `RELEASE=false` - Debug mode
- `STRIP=true` - Strip all symbols except `rustlib_*` from the static library
- `STRIP=false` (default) - Keep all symbols in the static library
