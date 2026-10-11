class sensor_reset_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_reset_sequence)

  function new(string name = "sensor_reset_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    req = sensor_seq_item::type_id::create("req");

    start_item(req);

    req.sensor_in = '0;

    finish_item(req);

  endtask

endclass