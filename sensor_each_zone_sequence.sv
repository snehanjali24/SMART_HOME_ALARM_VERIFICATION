class sensor_each_zone_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_each_zone_sequence)

  localparam int NUM_ZONES       = 8;
  localparam int DEBOUNCE_CYCLES = 4;

  function new(string name = "sensor_each_zone_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    //==================================================
    // All sensors OFF
    //==================================================

    req = sensor_seq_item::type_id::create("req");

    start_item(req);
    req.sensor_in = '0;
    finish_item(req);


    //==================================================
    // Activate each zone individually
    //==================================================

    for (int i = 0; i < NUM_ZONES; i++) begin

      // Hold zone ACTIVE for debounce period
      repeat (DEBOUNCE_CYCLES) begin

        req = sensor_seq_item::type_id::create("req");

        start_item(req);
        req.sensor_in = (1 << i);
        finish_item(req);

      end

      // Deactivate zone
      req = sensor_seq_item::type_id::create("req");

      start_item(req);
      req.sensor_in = '0;
      finish_item(req);

    end

  endtask

endclass