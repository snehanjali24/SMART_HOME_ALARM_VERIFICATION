class sensor_toggle_fault_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_toggle_fault_sequence)

  function new(string name = "sensor_toggle_fault_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // Start with sensor inactive
    req = sensor_seq_item::type_id::create("req");

    start_item(req);
    req.sensor_in = '0;
    finish_item(req);


    // Rapidly toggle Zone 0
    repeat (4) begin

      // Sensor ACTIVE
      req = sensor_seq_item::type_id::create("req");

      start_item(req);
      req.sensor_in = 8'b0000_0001;
      finish_item(req);


      // Sensor INACTIVE
      req = sensor_seq_item::type_id::create("req");

      start_item(req);
      req.sensor_in = '0;
      finish_item(req);

    end

  endtask

endclass