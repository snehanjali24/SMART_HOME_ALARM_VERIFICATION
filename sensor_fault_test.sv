class sensor_fault_test extends base_test;

  `uvm_component_utils(sensor_fault_test)

  function new(string name = "sensor_fault_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

  sensor_toggle_fault_sequence seq;

  phase.raise_objection(this);

  #50ns;

  alarm_env_h.sensor_chk.check_fault = 1'b1;

  seq = sensor_toggle_fault_sequence::type_id::create("seq");

  seq.start(
    alarm_env_h.sensor_agent_h.sensor_sequencer_h
  );

  #100ns;

  phase.drop_objection(this);

endtask

endclass