use std::{
    ffi::{CStr, CString, c_char},
    fs,
    panic::catch_unwind,
    ptr,
};

#[unsafe(no_mangle)]
pub extern "C" fn rustlib_read_string_file(path: *const c_char) -> *mut c_char {
    match catch_unwind(|| unsafe { read_c_string(path) }) {
        Ok(ptr) => ptr,
        Err(_) => {
            eprintln!("rustlib_read_string_file: caught panic");
            ptr::null_mut()
        }
    }
}

unsafe fn read_c_string(path: *const c_char) -> *mut c_char {
    let c_str = unsafe { CStr::from_ptr(path) };
    let path_str = match c_str.to_str() {
        Ok(s) => s,
        Err(e) => {
            eprintln!("rustlib_read_string_file: invalid UTF-8 path: {}", e);
            return ptr::null_mut();
        }
    };

    let content = match fs::read_to_string(path_str) {
        Ok(s) => s,
        Err(e) => {
            eprintln!(
                "rustlib_read_string_file: failed to read file {}: {}",
                path_str, e
            );
            return ptr::null_mut();
        }
    };

    let c_string = CString::new(content).expect("CString::new failed");
    c_string.into_raw()
}
