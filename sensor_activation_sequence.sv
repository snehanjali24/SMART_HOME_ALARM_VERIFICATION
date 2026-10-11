
class sensor_activation_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_activation_sequence)

  function new(string name = "sensor_activation_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // Initially, all sensors are inactive
    req = sensor_seq_item::type_id::create("all_inactive");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    // Activate each of the 8 zones individually
    for (int i = 0; i < 8; i++) begin

      req = sensor_seq_item::type_id::create(
        $sformatf("activate_zone_%0d", i)
      );

      start_item(req);
      req.sensor_in = (1 << i);
      finish_item(req);

      `uvm_info("SENSOR_SEQ",
        $sformatf(
          "Activating Zone %0d: sensor_in=%b",
          i, (1 << i)
        ),
        UVM_MEDIUM)

      // Deactivate all sensors before the next zone
      req = sensor_seq_item::type_id::create(
        $sformatf("deactivate_zone_%0d", i)
      );

      start_item(req);
      req.sensor_in = '0;
      finish_item(req);

    end

  endtask

endclass
