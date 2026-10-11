class sensor_monitor extends uvm_monitor;

  `uvm_component_utils(sensor_monitor)

  virtual sensor_if vif;

  uvm_analysis_port #(sensor_seq_item) analysis_port;

  function new(string name = "sensor_monitor",
               uvm_component parent = null);
    super.new(name, parent);

    analysis_port = new("analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual sensor_if)::get(
          this,
          "",
          "sensor_vif",
          vif))
      `uvm_fatal("NOVIF",
                 "Sensor virtual interface not found")

  endfunction

  task run_phase(uvm_phase phase);

    sensor_seq_item item;

    forever begin

      @(vif.mon_cb);

      item = sensor_seq_item::type_id::create("item");

      item.sensor_in = vif.mon_cb.sensor_in;

      `uvm_info("SENSOR_MON",
        $sformatf("Observed sensor_in = %b", item.sensor_in),
        UVM_LOW)

      analysis_port.write(item);

    end

  endtask

endclass