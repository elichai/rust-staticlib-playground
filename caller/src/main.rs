unsafe extern "C" {
    fn rustlib_add(left: u64, right: u64) -> u64;
}


fn main() {
    let result = unsafe { rustlib_add(2, 3) };
    println!("Hello, world!, 2 + 3 = {}", result);
}
