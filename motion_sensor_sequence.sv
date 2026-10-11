import alarm_pkg::*;

class motion_sensor_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(motion_sensor_sequence)

  // Number of consecutive active samples required
  int unsigned debounce_cycles;

  function new(string name = "motion_sensor_sequence");
    super.new(name);
  endfunction

  task body();

    sensor_seq_item req;

    // Sensor inactive
    req = sensor_seq_item::type_id::create("inactive");

    start_item(req);
    req.sensor_in = '0;
    finish_item(req);


    // Zone 0 active
    // Number of samples is provided by the test.
    repeat (debounce_cycles) begin

      req = sensor_seq_item::type_id::create("motion_active");

      start_item(req);
      req.sensor_in = '0;
      req.sensor_in[0] = 1'b1;
      finish_item(req);

    end


    // Sensor inactive
    req = sensor_seq_item::type_id::create("inactive_after_motion");

    start_item(req);
    req.sensor_in = '0;
    finish_item(req);

  endtask

endclass