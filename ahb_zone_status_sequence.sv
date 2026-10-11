
import alarm_pkg::*;

class ahb_zone_status_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_zone_status_sequence)

  function new(string name = "ahb_zone_status_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_seq_item req;

    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    req.addr  = ADDR_ZONE_STATUS;
    req.write = 1'b0;
    req.data  = '0;

    finish_item(req);

    `uvm_info("AHB_ZONE_STATUS",
      $sformatf(
        "ZONE_STATUS READ | TIME=%0t | ADDR=%08h | RDATA=%08h | RESP=%0b",
        $time,
        req.addr,
        req.rdata,
        req.resp
      ),
      UVM_NONE)

  endtask

endclass
