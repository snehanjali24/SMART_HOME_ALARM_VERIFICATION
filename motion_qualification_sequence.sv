import alarm_pkg::*;

class motion_qualification_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(motion_qualification_sequence)

  function new(string name = "motion_qualification_sequence");
    super.new(name);
  endfunction


  task body();

    ahb_write_sequence write_seq;


    //==================================================
    // Configure Zone 0 as MOTION
    //==================================================

    write_seq =
      ahb_write_sequence::type_id::create("write_zone_type");

    write_seq.write_addr = ADDR_ZONE_TYPE;

    write_seq.write_data = '0;
    write_seq.write_data[2:0] = ZT_MOTION;

    write_seq.start(m_sequencer);


    //==================================================
    // Enable Zone 0
    //==================================================

    write_seq =
      ahb_write_sequence::type_id::create("enable_zone0");

    write_seq.write_addr = ADDR_ZONE_ENABLE;

    write_seq.write_data = '0;
    write_seq.write_data[0] = 1'b1;

    write_seq.start(m_sequencer);

  endtask

endclass