
import alarm_pkg::*;

class pin_invalid_sequence extends uvm_sequence #(keypad_seq_item);

  `uvm_object_utils(pin_invalid_sequence)

  int unsigned num_attempts = 3;

  function new(string name = "pin_invalid_sequence");
    super.new(name);
  endfunction

  task body();
    keypad_seq_item req;
    bit [15:0] invalid_pins[3] = '{
      16'hEDCB,
      16'hA5A5,
      16'h5A5A
    };

    // Initial idle
    req = keypad_seq_item::type_id::create("idle_start");
    start_item(req);
    req.pin_valid = 1'b0;
    req.pin_code  = '0;
    finish_item(req);

    // Apply the requested number of invalid attempts
    for (int i = 0; i < num_attempts; i++) begin
      req = keypad_seq_item::type_id::create(
        $sformatf("invalid_pin_%0d", i+1)
      );

      start_item(req);
      req.pin_valid = 1'b1;
      req.pin_code  = invalid_pins[i % 3];
      finish_item(req);

      `uvm_info("PIN_INVALID_SEQ",
        $sformatf("Invalid attempt %0d/%0d: PIN=%04h",
                  i+1, num_attempts, invalid_pins[i % 3]),
        UVM_MEDIUM)

      req = keypad_seq_item::type_id::create(
        $sformatf("idle_%0d", i+1)
      );

      start_item(req);
      req.pin_valid = 1'b0;
      req.pin_code  = '0;
      finish_item(req);
    end
  endtask

endclass
