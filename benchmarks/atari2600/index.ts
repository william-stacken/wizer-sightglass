import { CPU } from "./cpu";
import StatusRegister from "./statusRegister";
import Memory from "./memory";
import TIA from "./tia";

@external("bench", "start")
declare function benchStart(): void

@external("bench", "end")
declare function benchEnd(): void

let memory: Memory;
let cpu: CPU;
let tia: TIA;

let _is_initialized: bool = false

export function stubTrace(message: string): void {}

export function wizerInitialize(): void {
    memory = new Memory();
    cpu = new CPU(memory);
    tia = new TIA(memory, cpu);
    _is_initialized = true;
}

export function _start(): void {
    benchStart();
    if (!_is_initialized) {
        wizerInitialize();
    }
    benchEnd();

    
}

export { tia, cpu, memory as consoleMemory, CPU, StatusRegister, Memory, TIA };
