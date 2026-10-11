
class alarm_env extends uvm_env;

  `uvm_component_utils(alarm_env)

  sensor_agent                  sensor_agent_h;
  keypad_agent                  keypad_agent_h;
  ahb_agent                     ahb_agent_h;

  alarm_output_passive_monitor  alarm_output_mon;

  scoreboard                    scoreboard_h;
  sensor_checker                sensor_chk;
  keypad_checker                keypad_chk;
  ahb_checker                   ahb_chk;
  motion_checker                motion_chk;
  alarm_reference_model         ref_model;


  function new(string name = "alarm_env",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction


  //==================================================
  // BUILD
  //==================================================

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    sensor_agent_h =
      sensor_agent::type_id::create(
        "sensor_agent", this);

    keypad_agent_h =
      keypad_agent::type_id::create(
        "keypad_agent", this);

    ahb_agent_h =
      ahb_agent::type_id::create(
        "ahb_agent", this);

    alarm_output_mon =
      alarm_output_passive_monitor::type_id::create(
        "alarm_output_mon", this);

    //==================================================
    // SCOREBOARD
    //==================================================

    scoreboard_h =
      scoreboard::type_id::create(
        "scoreboard", this);

    //==================================================
    // SENSOR CHECKER
    //==================================================

    sensor_chk =
      sensor_checker::type_id::create(
        "sensor_chk", this);

    //==================================================
    // KEYPAD CHECKER
    //==================================================

    keypad_chk =
      keypad_checker::type_id::create(
        "keypad_chk", this);

    //==================================================
    // AHB CHECKER
    //==================================================

    ahb_chk =
      ahb_checker::type_id::create(
        "ahb_chk", this);

    //==================================================
    // MOTION QUALIFICATION CHECKER
    //==================================================

    motion_chk =
      motion_checker::type_id::create(
        "motion_chk", this);

    //==================================================
    // REFERENCE MODEL
    //==================================================

    ref_model =
      alarm_reference_model::type_id::create(
        "ref_model", this);

  endfunction


  //==================================================
  // CONNECT
  //==================================================

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);


    //==================================================
    // SENSOR
    //==================================================

    // Sensor monitor → Reference model
    sensor_agent_h.sensor_monitor_h.analysis_port.connect(
      ref_model.sensor_imp
    );

    // Sensor monitor → Sensor checker
    sensor_agent_h.sensor_monitor_h.analysis_port.connect(
      sensor_chk.sensor_imp
    );

    // AHB monitor → Sensor checker
    ahb_agent_h.ahb_monitor_h.analysis_port.connect(
      sensor_chk.ahb_imp
    );

    // Reference model → Sensor checker
    sensor_chk.ref_model = ref_model;


    //==================================================
    // KEYPAD
    //==================================================

    // Keypad monitor → Reference model
    keypad_agent_h.keypad_monitor_h.analysis_port.connect(
      ref_model.keypad_imp
    );

    // Keypad monitor → Keypad checker
    keypad_agent_h.keypad_monitor_h.analysis_port.connect(
      keypad_chk.keypad_imp
    );

    // AHB monitor → Keypad checker
    ahb_agent_h.ahb_monitor_h.analysis_port.connect(
      keypad_chk.ahb_imp
    );

    // Reference model → Keypad checker
    keypad_chk.ref_model = ref_model;


    //==================================================
    // AHB CHECKER
    //==================================================

    // AHB monitor → AHB checker
    ahb_agent_h.ahb_monitor_h.analysis_port.connect(
      ahb_chk.ahb_imp
    );

    // AHB monitor → Reference model
    ahb_agent_h.ahb_monitor_h.analysis_port.connect(
      ref_model.ahb_imp
    );


    //==================================================
    // SCOREBOARD
    //==================================================

    // AHB monitor → Scoreboard
    ahb_agent_h.ahb_monitor_h.analysis_port.connect(
      scoreboard_h.ahb_imp
    );

    // Reference model → Scoreboard
    scoreboard_h.ref_model = ref_model;


    //==================================================
    // MOTION QUALIFICATION CHECKER
    //==================================================

    // Alarm output monitor → Motion checker
    alarm_output_mon.analysis_port.connect(
      motion_chk.alarm_imp
    );

  endfunction

endclass
