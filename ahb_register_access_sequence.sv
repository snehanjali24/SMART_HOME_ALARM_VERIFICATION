
import alarm_pkg::*;

class ahb_register_access_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_register_access_sequence)

  function new(string name = "ahb_register_access_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_read_sequence read_seq;

    // STATUS
    read_seq = ahb_read_sequence::type_id::create("read_status");
    read_seq.read_addr = ADDR_STATUS;
    read_seq.start(m_sequencer);
    `uvm_info("REG_ACCESS",
      $sformatf("STATUS = %0h", read_seq.read_data), UVM_LOW)

    // ENTRY_DELAY
    read_seq = ahb_read_sequence::type_id::create("read_entry_delay");
    read_seq.read_addr = ADDR_ENTRY_DELAY;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== DEF_ENTRY_DELAY)
      `uvm_error("REG_ACCESS",
        $sformatf("ENTRY_DELAY mismatch: expected=%0h actual=%0h",
                  DEF_ENTRY_DELAY, read_seq.read_data))
    else
      `uvm_info("REG_ACCESS", "ENTRY_DELAY PASSED", UVM_LOW)

    // EXIT_DELAY
    read_seq = ahb_read_sequence::type_id::create("read_exit_delay");
    read_seq.read_addr = ADDR_EXIT_DELAY;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== DEF_EXIT_DELAY)
      `uvm_error("REG_ACCESS",
        $sformatf("EXIT_DELAY mismatch: expected=%0h actual=%0h",
                  DEF_EXIT_DELAY, read_seq.read_data))
    else
      `uvm_info("REG_ACCESS", "EXIT_DELAY PASSED", UVM_LOW)

    // ALARM_DURATION
    read_seq = ahb_read_sequence::type_id::create("read_alarm_duration");
    read_seq.read_addr = ADDR_ALARM_DURATION;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== DEF_ALARM_DUR)
      `uvm_error("REG_ACCESS",
        $sformatf("ALARM_DURATION mismatch: expected=%0h actual=%0h",
                  DEF_ALARM_DUR, read_seq.read_data))
    else
      `uvm_info("REG_ACCESS", "ALARM_DURATION PASSED", UVM_LOW)

    // ZONE_ENABLE: reset/default value is checked here
    read_seq = ahb_read_sequence::type_id::create("read_zone_enable");
    read_seq.read_addr = ADDR_ZONE_ENABLE;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== '0)
      `uvm_error("REG_ACCESS",
        $sformatf("ZONE_ENABLE mismatch: expected=0 actual=%0h",
                  read_seq.read_data))
    else
      `uvm_info("REG_ACCESS", "ZONE_ENABLE PASSED", UVM_LOW)

    // IRQ_STATUS
    read_seq = ahb_read_sequence::type_id::create("read_irq_status");
    read_seq.read_addr = ADDR_IRQ_STATUS;
    read_seq.start(m_sequencer);

    if (read_seq.read_data !== '0)
      `uvm_error("REG_ACCESS",
        $sformatf("IRQ_STATUS mismatch: expected=0 actual=%0h",
                  read_seq.read_data))
    else
      `uvm_info("REG_ACCESS", "IRQ_STATUS PASSED", UVM_LOW)

  endtask

endclass
