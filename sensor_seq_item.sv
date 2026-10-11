class sensor_seq_item extends uvm_sequence_item;

  `uvm_object_utils(sensor_seq_item)

  localparam int NUM_ZONES = 8;

  rand bit [NUM_ZONES-1:0] sensor_in;

  function new(string name = "sensor_seq_item");
    super.new(name);
  endfunction

endclass