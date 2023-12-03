
(async function main() {
    const fs = require('fs').promises;
    const path = require('path');

    const wasmfile = process.argv[2];
    const datafile = process.argv[3];
    const resultfile = process.argv[4];

    if (!wasmfile.endsWith(".wasm"))
        throw new Error(`${wasmfile} isn't a .wasm file`)

    const basename = path.basename(wasmfile, ".wasm");
    console.log(`=== ${basename} ===`);

    // Make sure it and the input data exist
    await fs.stat(wasmfile);
    await fs.stat(datafile);

    // Allocate linear memory
    const memory = new WebAssembly.Memory({ initial: 1 });

    const exportedData = [];
    // Collect imports
    const moduleImports = {
        log: {
            string(offset, length) {
                const bytes = new Uint8Array(memory.buffer, offset, length);
                const string = new TextDecoder("utf8").decode(bytes);
                console.log(`string(${offset}, ${length}): ${string}`);
            },
            bytes(offset, length) {
                const bytes = new Uint8Array(memory.buffer, offset, length);
                console.log(`bytes(${offset}, ${length}): ${bytes}`);
            },
            error(offset) {
                console.error(`encountered error at offset ${offset}`)
            },
            num(offset) {
                console.log(`num ${offset}`)
            }
        },
        export: {
            i32array(offset, length) {
                const data = new Int32Array(memory.buffer, offset, length);
                exportedData.push(data);
                console.log(`exported data: ${data}`)
                const sum = data.reduce((a, b) => a + b, 0);
                console.log(`sum: ${sum}`)
            }
        },
        js: {
            mem: memory,
        },
    };

    // Read the data and load it into memory.
    const data = await fs.readFile(datafile, "utf8");
    const bytes = new TextEncoder("utf8").encode(data);
    
    // Load data into memory.
    let bufferi32 = new Int32Array(memory.buffer);
    // The offset where data has been loaded, in bytes
    const offset = 8;
    bufferi32[0] = offset;
    // The size of the loaded data in bytes
    bufferi32[1] = bytes.length;

    // Actually load it.
    let bufferBytes = new Uint8Array(memory.buffer);
    for (let i = 0; i < bytes.length; i++){
        bufferBytes[offset+i] = bytes[i];
    }

    // Load module
    const wasmBuffer = await fs.readFile(wasmfile);
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, moduleImports);

    //wasmModule.instance.exports.writeHi();

})();

