import alarm_pkg::*;

class ahb_zone_config_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_zone_config_sequence)

  function new(string name = "ahb_zone_config_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_write_sequence write_seq;
    ahb_read_sequence  read_seq;

    // ------------------------------------------------
    // 1. ZONE_ENABLE
    // ------------------------------------------------
    write_seq = ahb_write_sequence::type_id::create("write_zone_enable");

    write_seq.write_addr = ADDR_ZONE_ENABLE;
    write_seq.write_data = 32'h000000FF;

    write_seq.start(m_sequencer);


    read_seq = ahb_read_sequence::type_id::create("read_zone_enable");

    read_seq.read_addr = ADDR_ZONE_ENABLE;

    read_seq.start(m_sequencer);


    // ------------------------------------------------
    // 2. ZONE_BYPASS
    // ------------------------------------------------
    write_seq = ahb_write_sequence::type_id::create("write_zone_bypass");

    write_seq.write_addr = ADDR_ZONE_BYPASS;
    write_seq.write_data = '1;

    write_seq.start(m_sequencer);


    read_seq = ahb_read_sequence::type_id::create("read_zone_bypass");

    read_seq.read_addr = ADDR_ZONE_BYPASS;

    read_seq.start(m_sequencer);


    // ------------------------------------------------
    // 3. ZONE_TYPE
    // ------------------------------------------------
    write_seq = ahb_write_sequence::type_id::create("write_zone_type");

    write_seq.write_addr = ADDR_ZONE_TYPE;

    // Zone 0 = ENTRY
    // Zone 1 = PERIMETER
    // Zone 2 = MOTION
    // Zone 3 = FIRE

    write_seq.write_data = {
      16'h0,
      4'(ZT_FIRE),
      4'(ZT_MOTION),
      4'(ZT_PERIMETER),
      4'(ZT_ENTRY)
    };

    write_seq.start(m_sequencer);


    read_seq = ahb_read_sequence::type_id::create("read_zone_type");

    read_seq.read_addr = ADDR_ZONE_TYPE;

    read_seq.start(m_sequencer);

  endtask

endclass