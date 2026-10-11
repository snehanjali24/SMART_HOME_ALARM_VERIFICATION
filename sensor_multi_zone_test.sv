class sensor_multi_zone_test extends base_test;

  `uvm_component_utils(sensor_multi_zone_test)

  function new(string name = "sensor_multi_zone_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    sensor_multiple_sequence   multiple_seq;
    sensor_each_zone_sequence  each_zone_seq;
    sensor_activation_sequence activation_seq;
    ahb_zone_status_sequence   zone_status_seq;

    phase.raise_objection(this);

    // Enable multi-zone checking
    alarm_env_h.sensor_chk.check_multi_zone = 1'b1;

    // Multiple zone stimulus
    multiple_seq =
      sensor_multiple_sequence::type_id::create("multiple_seq");

    multiple_seq.start(
      alarm_env_h.sensor_agent_h.sensor_sequencer_h
    );

    #50ns;

    zone_status_seq =
      ahb_zone_status_sequence::type_id::create("zone_status_multi");

    zone_status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );


    // Each zone stimulus
    each_zone_seq =
      sensor_each_zone_sequence::type_id::create("each_zone_seq");

    each_zone_seq.start(
      alarm_env_h.sensor_agent_h.sensor_sequencer_h
    );

    #50ns;

    zone_status_seq =
      ahb_zone_status_sequence::type_id::create("zone_status_each");

    zone_status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );


    // Basic activation
    activation_seq =
      sensor_activation_sequence::type_id::create("activation_seq");

    activation_seq.start(
      alarm_env_h.sensor_agent_h.sensor_sequencer_h
    );

    #50ns;

    zone_status_seq =
      ahb_zone_status_sequence::type_id::create("zone_status_activation");

    zone_status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    phase.drop_objection(this);

  endtask

endclass