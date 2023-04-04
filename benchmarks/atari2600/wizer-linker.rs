use wizer::Linker;

pub fn create(e: &wasmtime::Engine) -> anyhow::Result<Linker> {
    let mut linker = Linker::new(e);

    linker.func_wrap("env", "abort", |message: i32, file_name: i32, line: i32, column: i32| {
        //let mem = caller.get_export("memory")?.into_memory()?;
        println!("abort: {} {} {} {}", message, file_name, line, column);
    })?;
    linker.func_wrap("env", "trace", |_message: i32, _n: i32, _a0: f64, _a1: f64, _a2: f64, _a3: f64, _a4: f64| {
    })?;

    Ok(linker)
}
