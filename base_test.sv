class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  alarm_env alarm_env_h;

  function new(string name = "base_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    alarm_env_h = alarm_env::type_id::create("alarm_env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    #10ns;

    phase.drop_objection(this);
  endtask

endclass