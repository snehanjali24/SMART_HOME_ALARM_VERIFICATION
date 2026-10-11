class sensor_rapid_transition_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_rapid_transition_sequence)

  function new(string name = "sensor_rapid_transition_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // Start with all sensors OFF
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    // Rapid sensor transitions
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    // Finish in inactive state
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

  endtask

endclass