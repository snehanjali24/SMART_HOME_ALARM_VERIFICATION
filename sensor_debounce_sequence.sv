class sensor_debounce_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_debounce_sequence)

  function new(string name = "sensor_debounce_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // Start with all sensors inactive
    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    // ------------------------------------------------
    // Case 1: Short pulse - should be rejected
    // ------------------------------------------------

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1'b1;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

    // ------------------------------------------------
    // Case 2: Stable activation
    // ------------------------------------------------

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1'b1;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1'b1;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1'b1;
    finish_item(req);

    req = sensor_seq_item::type_id::create("req");
    start_item(req);
    req.sensor_in = 1'b1;
    finish_item(req);

  endtask

endclass