use std::env;
use std::path::PathBuf;

fn main() {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR")
        .expect("CARGO_MANIFEST_DIR not set");

    let profile = env::var("PROFILE").unwrap_or_else(|_| "debug".to_string());
    // let profile = "release";

    // Navigate from the caller's manifest dir to the workspace target dir
    let lib_path = PathBuf::from(manifest_dir)
        .parent()  // Go up to workspace root
        .expect("Failed to get workspace root")
        .join("target")
        .join(&profile);

    println!("cargo:rustc-link-search=native={}", lib_path.display());
    println!("cargo:rustc-link-lib=static=rustlib");

    // Rerun if the library changes
    println!("cargo:rerun-if-changed={}", lib_path.join("librustlib.a").display());
}