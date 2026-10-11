import alarm_pkg::*;

class ahb_status_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_status_sequence)

  function new(string name = "ahb_status_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_seq_item req;

    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    req.write = 1'b0;
    req.addr  = ADDR_STATUS;
    req.data  = '0;

    finish_item(req);

    `uvm_info("AHB_STATUS",
      $sformatf(
        "STATUS read: addr=%0h rdata=%0h resp=%0b",
        req.addr,
        req.rdata,
        req.resp
      ),
      UVM_LOW)

  endtask

endclass