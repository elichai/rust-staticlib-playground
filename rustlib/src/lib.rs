#[unsafe(no_mangle)]
pub extern "C" fn rustlib_add(left: u64, right: u64) -> u64 {
    left + right
}
