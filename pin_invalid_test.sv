class pin_invalid_test extends base_test;

  `uvm_component_utils(pin_invalid_test)

  function new(string name = "pin_invalid_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    pin_invalid_sequence seq;

    phase.raise_objection(this);

    // Wait for DUT reset to complete
    #50ns;

    // Enable INVALID PIN checking
    alarm_env_h.keypad_chk.check_invalid = 1'b1;

    // Create invalid PIN sequence
    seq = pin_invalid_sequence::type_id::create("seq");

    // Check actual DUT pin_bad and apply stimulus in parallel
    fork
      alarm_env_h.keypad_chk.check_actual_pin_bad();

      begin
        seq.start(
          alarm_env_h.keypad_agent_h.keypad_sequencer_h
        );
      end
    join

    // Allow remaining monitor/checker activity to complete
    #100ns;

    phase.drop_objection(this);

  endtask

endclass