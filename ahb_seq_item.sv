class ahb_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ahb_seq_item)

  rand bit [31:0] addr;
  rand bit        write;
  rand bit [31:0] data;

  bit [31:0] rdata;
  bit        resp;

  // AHB protocol information
  bit [2:0]  hsize;
  bit [1:0]  htrans;
  bit        hready;
  bit        hreadyout;

  function new(string name = "ahb_seq_item");
    super.new(name);
  endfunction

endclass