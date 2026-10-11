

class motion_qualification_test extends uvm_test;

  `uvm_component_utils(motion_qualification_test)

  alarm_env env;

  function new(string name = "motion_qualification_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  //=========================================================
  // BUILD
  //=========================================================

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = alarm_env::type_id::create("alarm_env", this);

  endfunction


  //=========================================================
  // RUN
  //=========================================================

  task run_phase(uvm_phase phase);

    ahb_write_sequence arm_seq;
    ahb_write_sequence disarm_seq;

    motion_qualification_sequence config_seq;
    motion_sensor_sequence sensor_seq;


    phase.raise_objection(this);


    //=========================================================
    // 1. Configure Zone 0 as MOTION and enable Zone 0
    //=========================================================

    config_seq =
      motion_qualification_sequence::type_id::create("config_seq");

    config_seq.start(env.ahb_agent_h.ahb_sequencer_h);


    //=========================================================
    // 2. Initially alarm should be inactive
    //=========================================================

    env.motion_chk.expected_alarm_active = 1'b0;


    //=========================================================
    // 3. ARM STAY
    //=========================================================

    arm_seq =
      ahb_write_sequence::type_id::create("arm_stay");

    arm_seq.write_addr = ADDR_CONTROL;
    arm_seq.write_data = 32'h1;

    arm_seq.start(env.ahb_agent_h.ahb_sequencer_h);


    // Wait for EXIT_DELAY
    repeat (DEF_EXIT_DELAY)
      @(posedge tb_top.sys_clk);


    //=========================================================
    // 4. Apply motion while ARMED_STAY
    //=========================================================

    sensor_seq =
      motion_sensor_sequence::type_id::create("motion_stay");

    sensor_seq.debounce_cycles =
      env.ref_model.get_debounce_cycles();


    // Wait for sensor qualification and run sensor sequence
    fork

      begin
        @env.ref_model.sensor_qualified;
      end

      begin
        sensor_seq.start(
          env.sensor_agent_h.sensor_sequencer_h
        );
      end

    join


    //=========================================================
    // 5. Motion must NOT trigger alarm in ARMED_STAY
    //=========================================================

    if (tb_top.alarm_out_if.alarm_active !== 1'b0) begin

      `uvm_error("MOTION_TEST",
        "FAIL: Motion triggered alarm in ARMED_STAY")

    end
    else begin

      `uvm_info("MOTION_TEST",
        "PASS: Motion did not trigger alarm in ARMED_STAY",
        UVM_LOW)

    end


    //=========================================================
    // 6. DISARM
    //=========================================================

    disarm_seq =
      ahb_write_sequence::type_id::create("disarm");

    disarm_seq.write_addr = ADDR_CONTROL;
    disarm_seq.write_data = 32'h4;

    disarm_seq.start(env.ahb_agent_h.ahb_sequencer_h);


    //=========================================================
    // 7. ARM AWAY
    //=========================================================

    arm_seq =
      ahb_write_sequence::type_id::create("arm_away");

    arm_seq.write_addr = ADDR_CONTROL;
    arm_seq.write_data = 32'h2;

    arm_seq.start(env.ahb_agent_h.ahb_sequencer_h);


    // Wait for EXIT_DELAY
    repeat (DEF_EXIT_DELAY)
      @(posedge tb_top.sys_clk);


    //=========================================================
    // 8. Motion MUST trigger alarm in ARMED_AWAY
    //=========================================================

    env.motion_chk.expected_alarm_active = 1'b1;


    sensor_seq =
      motion_sensor_sequence::type_id::create("motion_away");

    sensor_seq.debounce_cycles =
      env.ref_model.get_debounce_cycles();


    // Wait for sensor qualification and run sensor sequence
    fork

      begin
        @env.ref_model.sensor_qualified;
      end

      begin
        sensor_seq.start(
          env.sensor_agent_h.sensor_sequencer_h
        );
      end

    join


    //=========================================================
    // 9. Explicit functional check
    //=========================================================

    if (tb_top.alarm_out_if.alarm_active !== 1'b1) begin

      `uvm_error("MOTION_TEST",
        $sformatf(
          "FAIL: Motion did NOT trigger alarm in ARMED_AWAY. Expected=1 Actual=%0b",
          tb_top.alarm_out_if.alarm_active
        ))

    end
    else begin

      `uvm_info("MOTION_TEST",
        "PASS: Motion triggered alarm in ARMED_AWAY",
        UVM_LOW)

    end


    //=========================================================
    // 10. Finish test
    //=========================================================

    phase.drop_objection(this);

  endtask

endclass