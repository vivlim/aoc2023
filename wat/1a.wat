(module
  (import "console" "log" (func $log (param i32 i32)))
  (import "js" "mem" (memory 1)) ;; 1 page (64KB)
  (global $source_data_offset i32 (i32.const 0))
  (global $source_data_size i32 (i32.const 0))
  (i32.const 0)
  i32.load
  (global.set $source_data_offset)
  (i32.const 1)
  i32.load
  (global.set $source_data_size)

  ;;(data (i32.const 0) "Hi")
  (func $main
    global.get $source_data_offset
    i32.const 5
    call $log
  
  )
  (start $main)
)
