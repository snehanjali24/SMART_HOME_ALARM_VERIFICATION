import alarm_pkg::*;

class ahb_write_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_write_sequence)

  rand bit [31:0] write_addr;
  rand bit [31:0] write_data;

  function new(string name = "ahb_write_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_seq_item req;

    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    req.addr  = write_addr;
    req.write = 1'b1;
    req.data  = write_data;

    finish_item(req);

    `uvm_info("AHB_WRITE",
      $sformatf("WRITE ADDR=%08h DATA=%08h RESP=%0b",
                req.addr, req.data, req.resp),
      UVM_LOW)

  endtask

endclass