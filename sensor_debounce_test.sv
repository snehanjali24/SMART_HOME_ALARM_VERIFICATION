
class sensor_debounce_test extends base_test;

  `uvm_component_utils(sensor_debounce_test)

  function new(string name = "sensor_debounce_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);

    sensor_debounce_sequence sensor_seq;
    ahb_zone_status_sequence zone_status_seq;

    phase.raise_objection(this);

    // Enable debounce checking
    alarm_env_h.sensor_chk.check_debounce = 1'b1;

    // Apply sensor debounce stimulus
    sensor_seq =
      sensor_debounce_sequence::type_id::create("sensor_seq");

    sensor_seq.start(
      alarm_env_h.sensor_agent_h.sensor_sequencer_h
    );

    // Read status at several checkpoints
    repeat (3) begin

      @(posedge tb_top.sys_clk);

      zone_status_seq =
        ahb_zone_status_sequence::type_id::create(
          "zone_status_seq");

      zone_status_seq.start(
        alarm_env_h.ahb_agent_h.ahb_sequencer_h
      );

    end

    phase.drop_objection(this);

  endtask

endclass