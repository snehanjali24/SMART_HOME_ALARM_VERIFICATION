class sensor_reset_test extends base_test;

  `uvm_component_utils(sensor_reset_test)

  function new(string name = "sensor_reset_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    sensor_reset_sequence sensor_seq;
    ahb_zone_status_sequence zone_status_seq;

    phase.raise_objection(this);

    //==================================================
    // ENABLE ONLY SENSOR RESET CHECKING
    //==================================================

    alarm_env_h.sensor_chk.check_reset      = 1'b1;
    alarm_env_h.sensor_chk.check_basic      = 1'b0;
    alarm_env_h.sensor_chk.check_debounce   = 1'b0;
    alarm_env_h.sensor_chk.check_fault      = 1'b0;
    alarm_env_h.sensor_chk.check_multi_zone = 1'b0;

    // Initialize reset test result tracking
    alarm_env_h.sensor_chk.reset_check_seen = 1'b0;
    alarm_env_h.sensor_chk.reset_check_pass = 1'b0;

    `uvm_info("SENSOR_RESET_TEST",
      "========== SENSOR RESET TEST STARTED ==========",
      UVM_NONE)

    //==================================================
    // RESET SENSOR INPUTS
    //==================================================

    `uvm_info("SENSOR_RESET_TEST",
      "STEP 1: Applying reset sensor sequence",
      UVM_NONE)

    sensor_seq =
      sensor_reset_sequence::type_id::create("sensor_seq");

    sensor_seq.start(
      alarm_env_h.sensor_agent_h.sensor_sequencer_h
    );

    //==================================================
    // WAIT FOR SENSOR PROCESSING
    //==================================================

    #50ns;

    //==================================================
    // READ DUT ZONE_STATUS
    //==================================================

    `uvm_info("SENSOR_RESET_TEST",
      "STEP 2: Reading DUT ZONE_STATUS through AHB",
      UVM_NONE)

    zone_status_seq =
      ahb_zone_status_sequence::type_id::create(
        "zone_status_seq"
      );

    zone_status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    // Allow the monitor and checker to process the
    // completed AHB transaction before checking results.
    #1ns;

    //==================================================
    // FINAL TEST RESULT
    //==================================================

    if (!alarm_env_h.sensor_chk.reset_check_seen) begin

      `uvm_error("SENSOR_RESET_TEST",
        "========== SENSOR RESET TEST FAILED: NO ZONE_STATUS CHECK ==========")

    end
    else if (alarm_env_h.sensor_chk.reset_check_pass) begin

      `uvm_info("SENSOR_RESET_TEST",
        "========== SENSOR RESET TEST PASSED ==========",
        UVM_NONE)

    end
    else begin

      `uvm_error("SENSOR_RESET_TEST",
        "========== SENSOR RESET TEST FAILED ==========")

    end

    phase.drop_objection(this);

  endtask

endclass