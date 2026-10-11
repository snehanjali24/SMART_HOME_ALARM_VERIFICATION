class pin_valid_test extends base_test;

  `uvm_component_utils(pin_valid_test)

  function new(string name = "pin_valid_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    pin_valid_sequence pin_seq;

    phase.raise_objection(this);

    // Wait for DUT reset to complete
    #50ns;

    // Enable valid PIN checking
    alarm_env_h.keypad_chk.check_valid = 1'b1;

    // Start checking for the actual DUT response
    fork
      alarm_env_h.keypad_chk.check_actual_pin_ok();
    join_none

    // Send valid PIN stimulus
    pin_seq =
      pin_valid_sequence::type_id::create("pin_seq");

    pin_seq.start(
      alarm_env_h.keypad_agent_h.keypad_sequencer_h
    );

    // Allow the checker to finish its response window
    wait fork;

    alarm_env_h.keypad_chk.check_valid = 1'b0;

    `uvm_info("PIN_VALID_TEST",
      "Completed valid PIN test",
      UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass