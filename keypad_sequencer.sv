class keypad_sequencer extends uvm_sequencer #(keypad_seq_item);

  `uvm_component_utils(keypad_sequencer)

  function new(string name = "keypad_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass