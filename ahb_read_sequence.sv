import alarm_pkg::*;

class ahb_read_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_read_sequence)

  rand bit [31:0] read_addr;

  bit [31:0] read_data;

  function new(string name = "ahb_read_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_seq_item req;

    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    req.addr  = read_addr;
    req.write = 1'b0;
    req.data  = '0;

    finish_item(req);

    read_data = req.rdata;

    `uvm_info("AHB_READ",
      $sformatf("READ ADDR=%08h RDATA=%08h RESP=%0b",
                req.addr, req.rdata, req.resp),
      UVM_LOW)

  endtask

endclass