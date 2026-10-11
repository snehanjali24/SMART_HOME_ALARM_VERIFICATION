import alarm_pkg::*;

class pin_recovery_sequence extends uvm_sequence #(keypad_seq_item);

  `uvm_object_utils(pin_recovery_sequence)

  function new(string name = "pin_recovery_sequence");
    super.new(name);
  endfunction

  task body();

    keypad_seq_item req;

    // Idle
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1'b0;
    req.pin_code = '0;
    finish_item(req);

    // Wrong PIN
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1'b1;
    req.pin_code = ~DEF_PIN;
    finish_item(req);

    // Back to idle
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1'b0;
    req.pin_code = '0;
    finish_item(req);

    // Correct PIN
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1'b1;
    req.pin_code = DEF_PIN;
    finish_item(req);

    // Return to idle
    req = keypad_seq_item#()::type_id::create("req");
    start_item(req);
    req.pin_valid = 1'b0;
    req.pin_code = '0;
    finish_item(req);

  endtask

endclass