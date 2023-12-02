(module
  (import "log" "string" (func $log_string (param i32 i32)))
  (import "log" "bytes" (func $log_bytes (param i32 i32)))
  (import "js" "mem" (memory 1)) ;; 1 page (64KB)

  (func $get_source_data_offset (result i32)
    i32.const 0
    i32.load
    return)

  (func $get_source_data_size (result i32)
    i32.const 1
    i32.load
    return)

  (func $main
    call $get_source_data_offset
    i32.const 5

    call $log_bytes
  
  )
  (start $main)
)
