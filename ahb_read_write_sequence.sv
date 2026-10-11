
import alarm_pkg::*;

class ahb_read_write_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_read_write_sequence)

  // Distinct test values to detect ENTRY/EXIT register swap
  localparam logic [31:0] TEST_ENTRY_DELAY = 32'd10;
  localparam logic [31:0] TEST_EXIT_DELAY  = 32'd20;

  function new(string name = "ahb_read_write_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_write_sequence write_seq;
    ahb_read_sequence  read_seq;

    bit [31:0] expected_data;
    bit [31:0] zone_mask;

    // ==========================================
    // 1. ENTRY_DELAY
    // ==========================================
    expected_data = TEST_ENTRY_DELAY;

    write_seq = ahb_write_sequence::type_id::create("write_entry_delay");
    write_seq.write_addr = ADDR_ENTRY_DELAY;
    write_seq.write_data = expected_data;
    write_seq.start(m_sequencer);

    read_seq = ahb_read_sequence::type_id::create("read_entry_delay");
    read_seq.read_addr = ADDR_ENTRY_DELAY;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== expected_data)
      `uvm_error("AHB_READ_WRITE",
        $sformatf("ENTRY_DELAY FAILED: Expected=%0h Actual=%0h",
                  expected_data, read_seq.read_data))
    else
      `uvm_info("AHB_READ_WRITE", "ENTRY_DELAY PASSED", UVM_LOW)


    // ==========================================
    // 2. EXIT_DELAY
    // ==========================================
    expected_data = TEST_EXIT_DELAY;

    write_seq = ahb_write_sequence::type_id::create("write_exit_delay");
    write_seq.write_addr = ADDR_EXIT_DELAY;
    write_seq.write_data = expected_data;
    write_seq.start(m_sequencer);

    read_seq = ahb_read_sequence::type_id::create("read_exit_delay");
    read_seq.read_addr = ADDR_EXIT_DELAY;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== expected_data)
      `uvm_error("AHB_READ_WRITE",
        $sformatf("EXIT_DELAY FAILED: Expected=%0h Actual=%0h",
                  expected_data, read_seq.read_data))
    else
      `uvm_info("AHB_READ_WRITE", "EXIT_DELAY PASSED", UVM_LOW)


    // ==========================================
    // 3. ALARM_DURATION
    // ==========================================
    expected_data = DEF_ALARM_DUR;

    write_seq = ahb_write_sequence::type_id::create("write_alarm_duration");
    write_seq.write_addr = ADDR_ALARM_DURATION;
    write_seq.write_data = expected_data;
    write_seq.start(m_sequencer);

    read_seq = ahb_read_sequence::type_id::create("read_alarm_duration");
    read_seq.read_addr = ADDR_ALARM_DURATION;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== expected_data)
      `uvm_error("AHB_READ_WRITE",
        $sformatf("ALARM_DURATION FAILED: Expected=%0h Actual=%0h",
                  expected_data, read_seq.read_data))
    else
      `uvm_info("AHB_READ_WRITE", "ALARM_DURATION PASSED", UVM_LOW)


    // ==========================================
    // 4. PIN_CONFIG
    // ==========================================
    expected_data = DEF_PIN;

    write_seq = ahb_write_sequence::type_id::create("write_pin_config");
    write_seq.write_addr = ADDR_PIN_CONFIG;
    write_seq.write_data = expected_data;
    write_seq.start(m_sequencer);

    read_seq = ahb_read_sequence::type_id::create("read_pin_config");
    read_seq.read_addr = ADDR_PIN_CONFIG;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== expected_data)
      `uvm_error("AHB_READ_WRITE",
        $sformatf("PIN_CONFIG FAILED: Expected=%0h Actual=%0h",
                  expected_data, read_seq.read_data))
    else
      `uvm_info("AHB_READ_WRITE", "PIN_CONFIG PASSED", UVM_LOW)


    // ==========================================
    // 5. ZONE_ENABLE
    // ==========================================
    zone_mask = {32{1'b1}} >> (32 - 8);
    expected_data = 32'hFFFF_FFFF;

    write_seq = ahb_write_sequence::type_id::create("write_zone_enable");
    write_seq.write_addr = ADDR_ZONE_ENABLE;
    write_seq.write_data = expected_data;
    write_seq.start(m_sequencer);

    read_seq = ahb_read_sequence::type_id::create("read_zone_enable");
    read_seq.read_addr = ADDR_ZONE_ENABLE;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== zone_mask)
      `uvm_error("AHB_READ_WRITE",
        $sformatf("ZONE_ENABLE FAILED: Expected=%0h Actual=%0h",
                  zone_mask, read_seq.read_data))
    else
      `uvm_info("AHB_READ_WRITE", "ZONE_ENABLE PASSED", UVM_LOW)


    // ==========================================
    // 6. ZONE_BYPASS
    // ==========================================
    expected_data = '0;

    write_seq = ahb_write_sequence::type_id::create("write_zone_bypass");
    write_seq.write_addr = ADDR_ZONE_BYPASS;
    write_seq.write_data = expected_data;
    write_seq.start(m_sequencer);

    read_seq = ahb_read_sequence::type_id::create("read_zone_bypass");
    read_seq.read_addr = ADDR_ZONE_BYPASS;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== expected_data)
      `uvm_error("AHB_READ_WRITE",
        $sformatf("ZONE_BYPASS FAILED: Expected=%0h Actual=%0h",
                  expected_data, read_seq.read_data))
    else
      `uvm_info("AHB_READ_WRITE", "ZONE_BYPASS PASSED", UVM_LOW)

  endtask

endclass
