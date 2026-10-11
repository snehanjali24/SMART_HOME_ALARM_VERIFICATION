class sensor_agent extends uvm_agent;

  `uvm_component_utils(sensor_agent)

  sensor_sequencer sensor_sequencer_h;
  sensor_driver    sensor_driver_h;
  sensor_monitor   sensor_monitor_h;

  function new(string name = "sensor_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    sensor_sequencer_h =
      sensor_sequencer::type_id::create(
        "sensor_sequencer",
        this
      );

    sensor_driver_h =
      sensor_driver::type_id::create(
        "sensor_driver",
        this
      );

    sensor_monitor_h =
      sensor_monitor::type_id::create(
        "sensor_monitor",
        this
      );
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    sensor_driver_h.seq_item_port.connect(
      sensor_sequencer_h.seq_item_export
    );

  endfunction

endclass