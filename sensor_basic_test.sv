import uvm_pkg::*;
import alarm_pkg::*;

class sensor_basic_test extends uvm_test;

  `uvm_component_utils(sensor_basic_test)

  alarm_env env;

  function new(string name = "sensor_basic_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //==================================================
  // BUILD PHASE
  //==================================================
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = alarm_env::type_id::create("alarm_env", this);
  endfunction

  //==================================================
  // RUN PHASE
  //==================================================
  task run_phase(uvm_phase phase);

    sensor_activation_sequence sensor_seq;
    ahb_read_sequence read_seq;

    phase.raise_objection(this);

    // Wait for reset to complete.
    #50ns;

    `uvm_info("SENSOR_BASIC",
              "Starting basic sensor test",
              UVM_MEDIUM)

    // Activate and deactivate Zone 0.
    sensor_seq =
      sensor_activation_sequence::type_id::create("sensor_seq");

    sensor_seq.start(env.sensor_agent_h.sensor_sequencer_h);

    // Allow sensor synchronization and debounce to complete.
    #100ns;

    // Read the zone status register.
    read_seq =
      ahb_read_sequence::type_id::create("read_zone_status");

    read_seq.read_addr = ADDR_ZONE_STATUS;
    read_seq.start(env.ahb_agent_h.ahb_sequencer_h);

    `uvm_info("SENSOR_BASIC",
              "Basic sensor test completed",
              UVM_MEDIUM)

    phase.drop_objection(this);

  endtask

endclass