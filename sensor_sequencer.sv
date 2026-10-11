class sensor_sequencer extends uvm_sequencer #(sensor_seq_item);

  `uvm_component_utils(sensor_sequencer)

  function new(string name = "sensor_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass