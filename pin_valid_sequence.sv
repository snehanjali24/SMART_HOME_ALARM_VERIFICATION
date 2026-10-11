import alarm_pkg::*;

class pin_valid_sequence extends uvm_sequence #(keypad_seq_item);

  `uvm_object_utils(pin_valid_sequence)

  function new(string name = "pin_valid_sequence");
    super.new(name);
  endfunction

  task body();

    keypad_seq_item req;

    `uvm_info("PIN_VALID_SEQ",
      "START: Single valid PIN test", UVM_MEDIUM)

    // Initial idle
    req = keypad_seq_item::type_id::create("idle_start");

    start_item(req);
    req.pin_valid = 1'b0;
    req.pin_code  = '0;
    finish_item(req);

    // Send valid PIN once
    req = keypad_seq_item::type_id::create("valid_pin");

    start_item(req);
    req.pin_valid = 1'b1;
    req.pin_code  = DEF_PIN;
    finish_item(req);

    `uvm_info("PIN_VALID_SEQ",
      $sformatf("Valid PIN attempt: PIN=%04h", DEF_PIN),
      UVM_MEDIUM)

    // Return to idle
    req = keypad_seq_item::type_id::create("idle_end");

    start_item(req);
    req.pin_valid = 1'b0;
    req.pin_code  = '0;
    finish_item(req);

    `uvm_info("PIN_VALID_SEQ",
      "END: Single valid PIN stimulus completed",
      UVM_MEDIUM)

  endtask

endclass