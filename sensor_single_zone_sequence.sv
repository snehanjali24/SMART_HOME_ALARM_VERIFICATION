class sensor_single_zone_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_single_zone_sequence)

  localparam int DEBOUNCE_CYCLES = 4;

  int zone_id;

  function new(string name = "sensor_single_zone_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // Make sure all zones are OFF first
    req = sensor_seq_item::type_id::create("req");

    start_item(req);
    req.sensor_in = '0;
    finish_item(req);


    // Hold selected zone ACTIVE
    // for the required debounce period
    repeat (DEBOUNCE_CYCLES) begin

      req = sensor_seq_item::type_id::create("req");

      start_item(req);
      req.sensor_in = (1 << zone_id);
      finish_item(req);

    end

  endtask

endclass