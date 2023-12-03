(module
  (import "log" "string" (func $log_string (param i32 i32)))
  (import "log" "bytes" (func $log_bytes (param i32 i32)))
  (import "js" "mem" (memory 1)) ;; 1 page (64KB)

  (func $get_source_data_offset (result i32)
    i32.const 0
    i32.load
    return)

  (func $get_source_data_size (result i32)
    i32.const 4
    i32.load
    return)

  (func $main
    call $get_source_data_offset
    call $get_source_data_size

    call $log_string
  
  )
  (start $main)
)
