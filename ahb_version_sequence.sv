import alarm_pkg::*;

class ahb_version_sequence extends uvm_sequence #(ahb_seq_item);

  `uvm_object_utils(ahb_version_sequence)

  function new(string name = "ahb_version_sequence");
    super.new(name);
  endfunction

  task body();

    ahb_read_sequence read_seq;

    read_seq = ahb_read_sequence::type_id::create("read_version");

    read_seq.read_addr = ADDR_VERSION;

    read_seq.start(m_sequencer);

  endtask

endclass