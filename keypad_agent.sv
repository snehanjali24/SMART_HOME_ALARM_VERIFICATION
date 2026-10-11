class keypad_agent extends uvm_agent;
  `uvm_component_utils(keypad_agent)

  keypad_sequencer keypad_sequencer_h;
  keypad_driver    keypad_driver_h;
  keypad_monitor   keypad_monitor_h;

  function new(string name = "keypad_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    keypad_sequencer_h = keypad_sequencer::type_id::create("keypad_sequencer", this);    
    keypad_driver_h    = keypad_driver   ::type_id::create("keypad_driver",    this);
    keypad_monitor_h   = keypad_monitor  ::type_id::create("keypad_monitor",   this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    keypad_driver_h.seq_item_port.connect(keypad_sequencer_h.seq_item_export);
  endfunction
endclass