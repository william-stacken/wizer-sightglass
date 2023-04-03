use regex::Regex;
use sightglass_api as bench;

/// A regex that matches numbers that start with "1".
static mut REGEX: Option<Regex> = None;

#[export_name = "wizer.initialize"]
pub extern "C" fn init() {
    unsafe {
        REGEX = Some(Regex::new(r"^1\d*$").unwrap());
    }
}

#[export_name = "run"]
pub extern "C" fn run(ptr: *const u8, len: usize) -> i32 {
    bench::start();
    unsafe {
        if REGEX.is_none() {
            init();
        }
    }
    bench::end();

    let s = unsafe {
        let slice = std::slice::from_raw_parts(ptr, len);
        std::str::from_utf8(slice).unwrap()
    };
    let regex = unsafe { REGEX.as_ref().unwrap() };
    regex.is_match(&s) as u8 as i32
}

#[export_name = "_start"]
pub extern "C" fn main() {
    let expr = "123456".as_bytes();
    println!("{}", run(expr.as_ptr(), expr.len()));
}
