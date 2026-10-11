
class pin_lockout_test extends base_test;

  `uvm_component_utils(pin_lockout_test)

  function new(string name = "pin_lockout_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    pin_lockout_sequence pin_seq;
    ahb_status_sequence  status_seq;

    phase.raise_objection(this);

    // Enable keypad lockout checking
    alarm_env_h.keypad_chk.check_lockout = 1'b1;

    `uvm_info("PIN_LOCKOUT_TEST",
              "Starting PIN lockout test",
              UVM_LOW)

    // Generate repeated invalid PIN attempts
    pin_seq =
      pin_lockout_sequence::type_id::create("pin_seq");

    pin_seq.start(
      alarm_env_h.keypad_agent_h.keypad_sequencer_h
    );

    // Allow the DUT to process the invalid PIN attempts
    #100;

    // Read STATUS register to check lockout
    status_seq =
      ahb_status_sequence::type_id::create("status_seq");

    status_seq.start(
      alarm_env_h.ahb_agent_h.ahb_sequencer_h
    );

    `uvm_info("PIN_LOCKOUT_TEST",
              "Completed PIN lockout test",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass
