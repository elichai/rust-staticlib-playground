use std::os::raw::c_char;

unsafe extern "C" {
    fn rustlib_read_string_file(path: *const c_char) -> *mut c_char;
}

fn main() {
    let this_file = file!();
    let c_path = std::ffi::CString::new(this_file).expect("CString::new failed");
    let content_ptr = unsafe { rustlib_read_string_file(c_path.as_ptr()) };
    assert!(!content_ptr.is_null(), "Failed to read file");
    let content_cstr = unsafe { std::ffi::CStr::from_ptr(content_ptr) };
    let content_str = content_cstr.to_str().expect("Invalid UTF-8");
    println!("Content of {}:\n{}", this_file, content_str);

    assert_eq!(content_str, std::fs::read_to_string(this_file).unwrap());
    println!("File content matches!");
}
