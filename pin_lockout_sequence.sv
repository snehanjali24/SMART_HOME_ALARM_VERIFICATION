import alarm_pkg::*;

class pin_lockout_sequence extends uvm_sequence #(keypad_seq_item);

  `uvm_object_utils(pin_lockout_sequence)

  function new(string name = "pin_lockout_sequence");
    super.new(name);
  endfunction

  task body();

    keypad_seq_item req;

    //========================================
    // Attempt 1 - LOW
    //========================================
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 0;
    req.pin_code  = '0;
    finish_item(req);

    //========================================
    // Attempt 1 - WRONG PIN
    //========================================
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1;
    req.pin_code  = 16'h9999;
    finish_item(req);

    // LOW
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 0;
    req.pin_code  = '0;
    finish_item(req);


    //========================================
    // Attempt 2 - WRONG PIN
    //========================================
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1;
    req.pin_code  = 16'h9999;
    finish_item(req);

    // LOW
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 0;
    req.pin_code  = '0;
    finish_item(req);


    //========================================
    // Attempt 3 - WRONG PIN
    //========================================
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1;
    req.pin_code  = 16'h9999;
    finish_item(req);

    // LOW
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 0;
    req.pin_code  = '0;
    finish_item(req);

    `uvm_info("PIN_LOCKOUT_SEQ",
              "3 INVALID PIN attempts sent",
              UVM_LOW)

  endtask

endclass