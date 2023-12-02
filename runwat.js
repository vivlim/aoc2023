
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

    // Collect imports
    const moduleImports = {
        console: {
            log(offset, length) {
                const bytes = new Uint8Array(memory.buffer, offset, length);
                const string = new TextDecoder("utf8").decode(bytes);
                console.log(string);
            },
        },
        js: {
            mem: memory,
        },
    };

    // Read the data and load it into memory.
    const data = await fs.readFile(datafile, "utf8");
    const bytes = new TextEncoder("utf8").encode(data);
    
    // Load data into memory.
    // The offset where data has been loaded.
    const offset = 2;
    memory.buffer[0] = offset;
    // The size of the loaded data.
    memory.buffer[1] = bytes.length;

    // Actually load it.
    for (let i = 0; i < bytes.length; i++){
        memory.buffer[offset+i] = bytes[i];
    }

    // Load module
    const wasmBuffer = await fs.readFile(wasmfile);
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, moduleImports);

    wasmModule.instance.exports.writeHi();

})();

