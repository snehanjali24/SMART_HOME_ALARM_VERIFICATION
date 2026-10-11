
class ahb_reset_test extends uvm_test;

  `uvm_component_utils(ahb_reset_test)

  alarm_env env;

  virtual alarm_output_if alarm_output_vif;


  function new(string name = "ahb_reset_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  //==================================================
  // BUILD PHASE
  //==================================================

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = alarm_env::type_id::create("alarm_env", this);

    if (!uvm_config_db#(virtual alarm_output_if)::get(
          this,
          "alarm_env",
          "alarm_output_vif",
          alarm_output_vif))
      `uvm_fatal("RESET_TEST",
                 "Failed to get alarm_output_vif")

  endfunction


  //==================================================
  // RUN PHASE
  //==================================================

  task run_phase(uvm_phase phase);

    ahb_reset_sequence seq;

    phase.raise_objection(this);

    seq = ahb_reset_sequence::type_id::create("seq");

    seq.start(env.ahb_agent_h.ahb_sequencer_h);


    //========================================
    // Wait for system clock
    //========================================

    @(posedge alarm_output_vif.sys_clk);


    //========================================
    // SIREN CHECK
    //========================================

    if (alarm_output_vif.siren !== 1'b0)

      `uvm_error("RESET_CHECK",
        $sformatf("SIREN is active after reset: %0b",
                  alarm_output_vif.siren))

    else

      `uvm_info("RESET_CHECK",
        "SIREN = 0",
        UVM_LOW)


    //========================================
    // STROBE CHECK
    //========================================

    if (alarm_output_vif.strobe !== 1'b0)

      `uvm_error("RESET_CHECK",
        $sformatf("STROBE is active after reset: %0b",
                  alarm_output_vif.strobe))

    else

      `uvm_info("RESET_CHECK",
        "STROBE = 0",
        UVM_LOW)


    //========================================
    // ALARM ACTIVE CHECK
    //========================================

    if (alarm_output_vif.alarm_active !== 1'b0)

      `uvm_error("RESET_CHECK",
        $sformatf("ALARM_ACTIVE is active after reset: %0b",
                  alarm_output_vif.alarm_active))

    else

      `uvm_info("RESET_CHECK",
        "ALARM_ACTIVE = 0",
        UVM_LOW)


    phase.drop_objection(this);

  endtask

endclass