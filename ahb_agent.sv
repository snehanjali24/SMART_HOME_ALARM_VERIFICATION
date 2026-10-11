class ahb_agent extends uvm_agent;
  `uvm_component_utils(ahb_agent)

  ahb_sequencer ahb_sequencer_h;
  ahb_driver    ahb_driver_h;
  ahb_monitor   ahb_monitor_h;

  function new(string name = "ahb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_sequencer_h = ahb_sequencer::type_id::create("ahb_sequencer", this);
    ahb_driver_h    = ahb_driver   ::type_id::create("ahb_driver",    this);
    ahb_monitor_h   = ahb_monitor  ::type_id::create("ahb_monitor",   this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ahb_driver_h.seq_item_port.connect(ahb_sequencer_h.seq_item_export);
  endfunction
endclass