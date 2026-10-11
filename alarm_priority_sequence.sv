import alarm_pkg::*;

class alarm_priority_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(alarm_priority_sequence)

  function new(string name = "alarm_priority_sequence");
    super.new(name);
  endfunction


  task body();

    ahb_write_sequence write_seq;


    // ==================================================
    // Zone 0 = PERIMETER
    // ==================================================

    write_seq =
      ahb_write_sequence::type_id::create("zone0_type");

    write_seq.write_addr = ADDR_ZONE_TYPE;
    write_seq.write_data = '0;
    write_seq.write_data[2:0] = ZT_PERIMETER;

    write_seq.start(m_sequencer);


    // ==================================================
    // Zone 1 = PERIMETER
    // ==================================================

    write_seq =
      ahb_write_sequence::type_id::create("zone1_type");

    write_seq.write_addr = ADDR_ZONE_TYPE;
    write_seq.write_data = '0;
    write_seq.write_data[5:3] = ZT_PERIMETER;

    write_seq.start(m_sequencer);


    // ==================================================
    // Enable Zone 0 and Zone 1
    // ==================================================

    write_seq =
      ahb_write_sequence::type_id::create("enable_zones");

    write_seq.write_addr = ADDR_ZONE_ENABLE;
    write_seq.write_data = '0;
    write_seq.write_data[1:0] = 2'b11;

    write_seq.start(m_sequencer);

  endtask

endclass   
