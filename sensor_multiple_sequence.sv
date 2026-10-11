class sensor_multiple_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_multiple_sequence)

  function new(string name = "sensor_multiple_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // All sensors OFF
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    // Activate multiple sensors
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '1;
    finish_item(req);

    // Deactivate all sensors
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

  endtask

endclass