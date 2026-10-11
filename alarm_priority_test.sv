class alarm_priority_test extends uvm_test;

  `uvm_component_utils(alarm_priority_test)

  alarm_env env;

  // ==================================================
  // Priority order
  // Highest -> Lowest
  // ==================================================

  function string get_priority_order();
    return "FIRE > PANIC > PERIMETER > MOTION > ENTRY_TIMEOUT > NONE";
  endfunction


  function new(string name = "alarm_priority_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = alarm_env::type_id::create("alarm_env", this);
  endfunction


  task run_phase(uvm_phase phase);

    alarm_priority_sequence config_seq;
    ahb_write_sequence      arm_seq;
    ahb_read_sequence       read_seq;

    sensor_zone_sequence    zone0_active_seq;
    sensor_zone_sequence    zone0_clear_seq;
    sensor_zone_sequence    zone1_active_seq;


    phase.raise_objection(this);


    // ==================================================
    // 1. Configure two equal-priority PERIMETER zones
    //
    // Zone 0 = PERIMETER
    // Zone 1 = PERIMETER
    // ==================================================

    config_seq =
      alarm_priority_sequence::type_id::create("config_seq");

    config_seq.start(
      env.ahb_agent_h.ahb_sequencer_h
    );


    // ==================================================
    // 2. ARM AWAY
    // ==================================================

    arm_seq =
      ahb_write_sequence::type_id::create("arm_away");

    arm_seq.write_addr = ADDR_CONTROL;
    arm_seq.write_data = (32'(1) << CTRL_ARM_AWAY);

    arm_seq.start(
      env.ahb_agent_h.ahb_sequencer_h
    );


    // ==================================================
    // 3. Wait for EXIT delay
    // ==================================================

    repeat (DEF_EXIT_DELAY)
      @(posedge tb_top.sys_clk);


    // ==================================================
    // 4. Activate Zone 0
    // ==================================================

    zone0_active_seq =
      sensor_zone_sequence::type_id::create("zone0_active_seq");

    zone0_active_seq.zone_index = 0;
    zone0_active_seq.active     = 1'b1;

    fork

      begin
        @env.ref_model.sensor_qualified;
      end

      begin
        zone0_active_seq.start(
          env.sensor_agent_h.sensor_sequencer_h
        );
      end

    join;


    // Give the sensor event time to propagate
    repeat (5)
      @(posedge tb_top.sys_clk);


    // ==================================================
    // 5. Check first alarm
    // ==================================================

    if (tb_top.alarm_out_if.alarm_active !== 1'b1) begin

      `uvm_error("PRIORITY_TEST",
        $sformatf(
          "FAIL: Zone 0 did not activate the alarm. Priority order: %s",
          get_priority_order()
        ));

      phase.drop_objection(this);
      return;

    end


    // ==================================================
    // 5A. Read first ALARM_STATUS
    //
    // Zone field = bits [12:5]
    // Expected Zone = 0
    // ==================================================

    read_seq =
      ahb_read_sequence::type_id::create("read_first_alarm_status");

    read_seq.read_addr = ADDR_ALARM_STATUS;

    read_seq.start(
      env.ahb_agent_h.ahb_sequencer_h
    );


    if (read_seq.read_data[12:5] != 8'b0) begin

      `uvm_error("PRIORITY_TEST",
        $sformatf(
          "FAIL: First alarm expected Zone=0, Actual ALARM_STATUS=%08h",
          read_seq.read_data
        ));

      phase.drop_objection(this);
      return;

    end
    else begin

      `uvm_info("PRIORITY_TEST",
        $sformatf(
          "PASS: First alarm activated by Zone 0. ALARM_STATUS=%08h",
          read_seq.read_data
        ),
        UVM_LOW);

    end


    // ==================================================
    // 6. Clear Zone 0 sensor
    //
    // Alarm should remain latched.
    // ==================================================

    zone0_clear_seq =
      sensor_zone_sequence::type_id::create("zone0_clear_seq");

    zone0_clear_seq.zone_index = 0;
    zone0_clear_seq.active     = 1'b0;

    fork

      begin
        @env.ref_model.sensor_qualified;
      end

      begin
        zone0_clear_seq.start(
          env.sensor_agent_h.sensor_sequencer_h
        );
      end

    join;


    // ==================================================
    // 7. Activate equal-priority Zone 1
    //
    // Zone 1 is also PERIMETER.
    // Therefore its priority is equal to Zone 0.
    // ==================================================

    zone1_active_seq =
      sensor_zone_sequence::type_id::create("zone1_active_seq");

    zone1_active_seq.zone_index = 1;
    zone1_active_seq.active     = 1'b1;

    fork

      begin
        @env.ref_model.sensor_qualified;
      end

      begin
        zone1_active_seq.start(
          env.sensor_agent_h.sensor_sequencer_h
        );
      end

    join;


    // Give Zone 1 event time to propagate
    repeat (5)
      @(posedge tb_top.sys_clk);


    // ==================================================
    // 8. Read ALARM_STATUS again
    //
    // Correct RTL:
    //     Zone remains 0
    //
    // Buggy RTL using >=:
    //     Zone changes to 1
    // ==================================================

    read_seq =
      ahb_read_sequence::type_id::create("read_second_alarm_status");

    read_seq.read_addr = ADDR_ALARM_STATUS;

    read_seq.start(
      env.ahb_agent_h.ahb_sequencer_h
    );


    // ==================================================
    // 9. Final priority check
    // ==================================================

    if (read_seq.read_data[12:5] != 8'b0) begin

      `uvm_error("PRIORITY_TEST",
        $sformatf(
          "FAIL: Equal-priority alarm escalated. Expected Zone=0, Actual ALARM_STATUS=%08h. Priority order: %s",
          read_seq.read_data,
          get_priority_order()
        ));

    end
    else begin

      `uvm_info("PRIORITY_TEST",
        $sformatf(
          "PASS: Equal-priority alarm did not escalate. Zone remained 0. ALARM_STATUS=%08h",
          read_seq.read_data
        ),
        UVM_LOW);

    end


    phase.drop_objection(this);

  endtask
endclass