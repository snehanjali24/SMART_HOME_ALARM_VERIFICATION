class ahb_read_write_test extends uvm_test;

  `uvm_component_utils(ahb_read_write_test)

  alarm_env env;

  function new(string name = "ahb_read_write_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = alarm_env::type_id::create("alarm_env", this);

  endfunction


  task run_phase(uvm_phase phase);

    ahb_read_write_sequence seq;

    phase.raise_objection(this);

    seq = ahb_read_write_sequence::type_id::create("seq");

    seq.start(env.ahb_agent_h.ahb_sequencer_h);

    phase.drop_objection(this);

  endtask

endclass