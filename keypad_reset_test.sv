
class keypad_reset_test extends base_test;

  `uvm_component_utils(keypad_reset_test)

  function new(string name = "keypad_reset_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb_status_sequence status_seq;
    pin_invalid_sequence invalid_seq;

    phase.raise_objection(this);

    `uvm_info("KEYPAD_RESET_TEST",
      "========== KEYPAD RESET TEST STARTED ==========",
      UVM_NONE)

    // Enable checker flags
    alarm_env_h.keypad_chk.check_reset    = 1'b0;
    alarm_env_h.keypad_chk.check_invalid  = 1'b1;
    alarm_env_h.keypad_chk.check_valid    = 1'b0;
    alarm_env_h.keypad_chk.check_lockout  = 1'b0;
    alarm_env_h.keypad_chk.check_recovery = 1'b0;

    // Wait for initial reset release
    #100;

    // STEP 1: Check initial keypad status
    status_seq =
      ahb_status_sequence::type_id::create("status_initial");

    status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    // STEP 2: Two invalid attempts before reset
    invalid_seq =
      pin_invalid_sequence::type_id::create("invalid_before_reset");

    invalid_seq.num_attempts = 2;

    invalid_seq.start(
      alarm_env_h.keypad_agent_h.keypad_sequencer_h
    );

    #20;

    // Check status before reset
    status_seq =
      ahb_status_sequence::type_id::create("status_before_reset");

    status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    // STEP 3: Assert system reset
    @(negedge tb_top.sys_clk);
    tb_top.sys_reset_override_en = 1'b1;
    tb_top.sys_reset_override_n  = 1'b0;

    // Reset the reference model's keypad state
    alarm_env_h.ref_model.reset_keypad_model();

    `uvm_info("KEYPAD_RESET_TEST",
      "System reset asserted",
      UVM_LOW)

    repeat (4) @(negedge tb_top.sys_clk);

    // STEP 4: Release system reset
    tb_top.sys_reset_override_n = 1'b1;

    repeat (5) @(posedge tb_top.sys_clk);
    #1;

    `uvm_info("KEYPAD_RESET_TEST",
      "System reset released",
      UVM_LOW)

    // Check keypad unlocked after reset
    alarm_env_h.keypad_chk.check_reset = 1'b1;

    status_seq =
      ahb_status_sequence::type_id::create("status_after_reset");

    status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    // Disable reset checking for subsequent status reads
    alarm_env_h.keypad_chk.check_reset = 1'b0;

    // STEP 5: Two invalid attempts after reset
    invalid_seq =
      pin_invalid_sequence::type_id::create("invalid_after_reset");

    invalid_seq.num_attempts = 2;

    invalid_seq.start(
      alarm_env_h.keypad_agent_h.keypad_sequencer_h
    );

    #20;

    // Observe status after invalid attempts.
    // Lockout verification belongs in keypad_lockout_test.
    status_seq =
      ahb_status_sequence::type_id::create("status_after_failures");

    status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    // Restore normal reset generation
    @(negedge tb_top.sys_clk);
    tb_top.sys_reset_override_en = 1'b0;

    `uvm_info("KEYPAD_RESET_TEST",
      "========== KEYPAD RESET TEST COMPLETED ==========",
      UVM_NONE)

    phase.drop_objection(this);

  endtask

endclass
