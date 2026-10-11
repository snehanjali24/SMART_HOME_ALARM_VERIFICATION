class keypad_seq_item #(int PIN_WIDTH = 16) extends uvm_sequence_item;

  `uvm_object_param_utils(keypad_seq_item #(PIN_WIDTH))

  logic                 pin_valid;
  logic [PIN_WIDTH-1:0] pin_code;

  function new(string name = "keypad_seq_item");
    super.new(name);
  endfunction

endclass