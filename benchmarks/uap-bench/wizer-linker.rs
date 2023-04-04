use wizer::Linker;
use wizer::HostState;

pub fn create(e: &wasmtime::Engine) -> anyhow::Result<Linker> {
    let mut linker = Linker::new(e);

    /*wasmtime_wasi::add_to_linker(&mut linker, |ctx: &mut Option<HostState>| {
        ctx.as_mut().unwrap().wasi.as_mut().unwrap()
    })?;*/
    /*wasmtime_wasi_nn::add_to_linker(&mut linker, |ctx: &mut Option<HostState>| {
        ctx.as_mut().unwrap().wasi_nn.as_mut().unwrap()
    })?;*/

    Ok(linker)
}
