import alarm_pkg::*;

class ahb_reset_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_reset_sequence)

  function new(string name = "ahb_reset_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_seq_item req;

    // STATUS
    req = ahb_seq_item::type_id::create("status_req");

    start_item(req);
    req.addr = ADDR_STATUS;
    req.write = 1'b0;
    req.data = '0;
    finish_item(req);

    `uvm_info("AHB_RESET",
      $sformatf("STATUS = %0h RESP = %0b",
                req.rdata, req.resp), UVM_LOW)


    // ZONE_STATUS
    req = ahb_seq_item::type_id::create("zone_status_req");

    start_item(req);
    req.addr = ADDR_ZONE_STATUS;
    req.write = 1'b0;
    req.data = '0;
    finish_item(req);

    `uvm_info("AHB_RESET",
      $sformatf("ZONE_STATUS = %0h RESP = %0b",
                req.rdata, req.resp), UVM_LOW)


    // ALARM_STATUS
    req = ahb_seq_item::type_id::create("alarm_status_req");

    start_item(req);
    req.addr = ADDR_ALARM_STATUS;
    req.write = 1'b0;
    req.data = '0;
    finish_item(req);

    `uvm_info("AHB_RESET",
      $sformatf("ALARM_STATUS = %0h RESP = %0b",
                req.rdata, req.resp), UVM_LOW)

  endtask

endclass