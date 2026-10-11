
class sensor_driver extends uvm_driver #(sensor_seq_item);

  `uvm_component_utils(sensor_driver)

  virtual sensor_if vif;

  function new(string name = "sensor_driver",
               uvm_component parent = null);
    super.new(name, parent);
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

    sensor_seq_item req;

    forever begin

      seq_item_port.get_next_item(req);

      // Drive sensor value on the sensor clock
      @(vif.drv_cb);
      vif.drv_cb.sensor_in <= req.sensor_in;

      // Hold an active sensor for four clock cycles
      if (req.sensor_in != '0) begin
        repeat (3) @(vif.drv_cb);
      end

      seq_item_port.item_done();

    end

  endtask

endclass
