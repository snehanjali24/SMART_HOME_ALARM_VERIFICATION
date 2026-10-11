import alarm_pkg::*;

class ahb_delay_config_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_delay_config_sequence)

  function new(string name = "ahb_delay_config_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_write_sequence write_seq;
    ahb_read_sequence  read_seq;

    // Write ENTRY_DELAY = DEF_ENTRY_DELAY + 10
    write_seq = ahb_write_sequence::type_id::create("write_entry");

    write_seq.write_addr = ADDR_ENTRY_DELAY;
    write_seq.write_data = DEF_ENTRY_DELAY + 10;

    write_seq.start(m_sequencer);


    // Read ENTRY_DELAY
    read_seq = ahb_read_sequence::type_id::create("read_entry");

    read_seq.read_addr = ADDR_ENTRY_DELAY;

    read_seq.start(m_sequencer);


    // Read EXIT_DELAY
    read_seq = ahb_read_sequence::type_id::create("read_exit");

    read_seq.read_addr = ADDR_EXIT_DELAY;

    read_seq.start(m_sequencer);


    // Write EXIT_DELAY = DEF_EXIT_DELAY + 20
    write_seq = ahb_write_sequence::type_id::create("write_exit");

    write_seq.write_addr = ADDR_EXIT_DELAY;
    write_seq.write_data = DEF_EXIT_DELAY + 20;

    write_seq.start(m_sequencer);


    // Read ENTRY_DELAY again
    read_seq = ahb_read_sequence::type_id::create("read_entry_again");

    read_seq.read_addr = ADDR_ENTRY_DELAY;

    read_seq.start(m_sequencer);


    // Read EXIT_DELAY again
    read_seq = ahb_read_sequence::type_id::create("read_exit_again");

    read_seq.read_addr = ADDR_EXIT_DELAY;

    read_seq.start(m_sequencer);

  endtask

endclass