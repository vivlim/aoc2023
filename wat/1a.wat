(module
  (import "log" "string" (func $log_string (param i32 i32)))
  (import "log" "bytes" (func $log_bytes (param i32 i32)))
  (import "log" "error" (func $log_error (param i32)))
  (import "log" "num" (func $log_num (param i32)))
  (import "export" "i32array" (func $export_i32array (param i32 i32)))
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
    ;; declare locals
    (local $i i32) ;; index in mem
    (local $end i32) ;; end of source data
    (local $result_start_offset i32) ;; where we're storing the result
    (local $result_pos i32) ;; where we are in the result
    (local $cur_byte i32) ;; current byte

    (local $cur_line_leftmost_digit i32)
    (local $cur_line_rightmost_digit i32)
    (local $is_end i32)


    ;; set those locals
    call $get_source_data_offset
    local.tee $i
    call $get_source_data_size
    i32.add
    local.tee $end
    local.get $i
    i32.add ;; start to store the result after the source data
    local.set $result_start_offset

    ;; align it to i32 indices
    i32.const 4
    local.get $result_start_offset
    i32.const 4
    i32.rem_u
    i32.sub
    local.get $result_start_offset
    i32.add
    local.tee $result_start_offset

    local.set $result_pos

    i32.const -1
    local.set $cur_line_leftmost_digit
    i32.const -1
    local.set $cur_line_rightmost_digit

    (block $exit
      (loop $scan_input
        (block $handle_byte
          local.get $i
          i32.const 1
          call $log_string
          local.get $i
          i32.load8_u ;; load the byte
          local.tee $cur_byte

          ;; if >= 128, msb is set, which means this character is more than 1 byte long. hopefully don't need to handle that
          i32.const 128
          i32.ge_u
          (if
            (then
              local.get $i
              call $log_error
              unreachable
            )
          )

          ;; check if the current byte is a newline or null
          i32.const 0
          local.set $is_end
          local.get $cur_byte
          i32.const 10
          i32.eq ;; == 10 ('\n')
          local.tee $is_end
          local.get $cur_byte
          i32.const 0
          i32.eq ;; == 10 (null)
          i32.add ;; add the results of the two equality checks
          local.tee $is_end
          (if
            (then
              ;; make sure we have actually encountered a number
              local.get $cur_line_leftmost_digit
              i32.const 0
              i32.lt_s
              br_if $handle_byte

              ;; push the address to store to onto the stack
              local.get $result_pos
              local.get $result_pos
              call $log_num

              local.get $cur_line_leftmost_digit
              call $log_num
              ;; convert leftmost digit from character code to number and *10
              local.get $cur_line_leftmost_digit
              i32.const 48
              i32.sub
              i32.const 10
              i32.mul
              ;; stack now contains the leftmost digit's contribution.

              local.get $cur_line_rightmost_digit
              call $log_num
              local.get $cur_line_rightmost_digit
              i32.const 48
              i32.sub
              ;; stack contains left and right digits, add them
              i32.add

              ;; now the stack just contains the address to store to, and the combined digits; write it
              i32.store

              ;; increment result pos
              local.get $result_pos
              i32.const 4 ;; 4 bytes since we're writing i32s
              i32.add
              local.set $result_pos

              ;; reset the current line state  
              i32.const -1
              local.set $cur_line_leftmost_digit
              i32.const -1
              local.set $cur_line_rightmost_digit
              br $handle_byte ;; move on to the next byte.
            )
          )

          ;; check if the current byte is a digit.
          local.get $cur_byte
          i32.const 48
          i32.lt_u ;; < 48 ('0')
          br_if $handle_byte ;; if it's too low, move onto the next byte

          local.get $cur_byte
          i32.const 57
          i32.gt_u ;; > 57 ('9')
          br_if $handle_byte ;; if it's too high, move onto the next byte.

          local.get $i
          i32.const 1
          call $log_string

          ;; only set leftmost digit if it hasn't been set already.
          local.get $cur_line_leftmost_digit
          i32.const 0
          i32.lt_s
          (if
            (then
              local.get $cur_byte
              local.set $cur_line_leftmost_digit
            )
          )
          ;; always set the rightmost digit.
          local.get $cur_byte
          local.set $cur_line_rightmost_digit
        )
        local.get $i
        i32.const 1
        i32.add
        local.tee $i

        local.get $end
        i32.gt_u
        br_if $exit
        br $scan_input
      )
    )


    local.get $result_start_offset

    ;; length in i32s
    local.get $result_pos
    local.get $result_start_offset
    i32.sub
    i32.const 4
    i32.div_u

    call $export_i32array 
    ;;call $log_string
  
  )
  (start $main)
)
