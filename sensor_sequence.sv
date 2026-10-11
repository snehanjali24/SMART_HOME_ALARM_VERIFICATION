class sensor_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_sequence)

  function new(string name = "sensor_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    req = sensor_seq_item::type_id::create("req");

    start_item(req);

    assert(req.randomize() with {
      sensor_reset_n == 1;
    });

    finish_item(req);

  endtask

endclass