import { CPU } from "./cpu";
import StatusRegister from "./statusRegister";
import Memory from "./memory";
import TIA from "./tia";

@external("bench", "start")
declare function benchStart(): void

@external("bench", "stop")
declare function benchStop(): void

declare function trace(log: string): void

//const memory = new Memory();
//const cpu = new CPU(memory);
//const tia = new TIA(memory, cpu);

let memory: Memory;
let cpu: CPU;
let tia: TIA;

let _is_initialized: bool = false

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
    benchStop();
}

export { tia, cpu, memory as consoleMemory, CPU, StatusRegister, Memory, TIA };
