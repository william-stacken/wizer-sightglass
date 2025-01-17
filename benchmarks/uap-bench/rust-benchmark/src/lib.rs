use regex::RegexSet;
use regex::RegexSetBuilder;
use serde::Deserialize;
use sightglass_api as bench;

static mut UA_REGEX_SET: Option<RegexSet> = None;

#[derive(Deserialize)]
struct UserAgentParsers {
    user_agent_parsers: Vec<UserAgentParserEntry>,
}

#[derive(Deserialize)]
struct UserAgentParserEntry {
    regex: String,
    // family_replacement: Option<String>,
    // brand_replacement: Option<String>,
    // model_replacement: Option<String>,
    // os_replacement: Option<String>,
    // v1_replacement: Option<String>,
    // v2_replacement: Option<String>,
    // os_v1_replacement: Option<String>,
    // os_v2_replacement: Option<String>,
    // os_v3_replacement: Option<String>,
}

#[export_name = "wizer.initialize"]
pub extern "C" fn init() {
    let uap_yaml = include_str!("../uap-core/regexes.yaml");
    let parsers: UserAgentParsers = serde_yaml::from_str(uap_yaml).unwrap();
    let regex_set = RegexSetBuilder::new(
        parsers
            .user_agent_parsers
            .iter()
            .map(|e| e.regex.replace("\\/", "/").replace("\\!", "!")),
    ).size_limit(20485760)
    .build()
    .unwrap();
    unsafe {
        assert!(UA_REGEX_SET.is_none());
        UA_REGEX_SET = Some(regex_set);
    }
}

#[export_name = "_start"]
pub extern "C" fn main() {
    let ua = "Mozilla/5.0 (X11; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0".as_bytes();
    println!("{}", run(ua.as_ptr(), ua.len()));
}

#[export_name = "run"]
pub extern "C" fn run(ptr: *const u8, len: usize) -> i32 {
    bench::start();
    unsafe {
        if UA_REGEX_SET.is_none() {
            init();
        }
    }
    bench::end();

    let s = unsafe {
        let slice = std::slice::from_raw_parts(ptr, len);
        std::str::from_utf8(slice).unwrap()
    };
    let regex_set = unsafe { UA_REGEX_SET.as_ref().unwrap() };
    regex_set.is_match(&s) as u8 as i32
}

#[export_name = "alloc"]
pub extern "C" fn alloc(size: usize, align: usize) -> *mut u8 {
    let layout = std::alloc::Layout::from_size_align(size, align).unwrap();
    unsafe { std::alloc::alloc(layout) }
}

#[export_name = "dealloc"]
pub extern "C" fn dealloc(ptr: *mut u8, size: usize, align: usize) {
    let layout = std::alloc::Layout::from_size_align(size, align).unwrap();
    unsafe {
        std::alloc::dealloc(ptr, layout);
    }
}
