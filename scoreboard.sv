import alarm_pkg::*;
class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(ahb_seq_item, scoreboard) ahb_imp;

  alarm_reference_model ref_model;


  function new(string name = "scoreboard",
               uvm_component parent = null);

    super.new(name, parent);

    ahb_imp = new("ahb_imp", this);

  endfunction


  //==================================================
  // AHB TRANSACTION RECEIVER
  //==================================================

  function void write(ahb_seq_item item);

    `uvm_info("SCOREBOARD",
      $sformatf(
        "AHB %s: ADDR=%08h DATA=%08h RDATA=%08h RESP=%0b",
        item.write ? "WRITE" : "READ",
        item.addr,
        item.data,
        item.rdata,
        item.resp
      ),
      UVM_LOW)

  endfunction

endclass