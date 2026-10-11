import alarm_pkg::*;

class sensor_zone_sequence extends uvm_sequence #(sensor_seq_item);

  `uvm_object_utils(sensor_zone_sequence)

  // Zone to be controlled
  int zone_index;

  // 1 = active, 0 = inactive
  bit active;

  // Verification-side debounce value.
  // Matches the value used by the reference model.
  localparam int DEBOUNCE_CYCLES = 4;

  function new(string name = "sensor_zone_sequence");
    super.new(name);
  endfunction


  task body();

    sensor_seq_item req;

    // Send the required number of stable samples
    repeat (DEBOUNCE_CYCLES) begin

      req =
        sensor_seq_item::type_id::create("req");

      start_item(req);

      req.sensor_in = '0;

      if (active)
        req.sensor_in[zone_index] = 1'b1;

      finish_item(req);

    end

  endtask

endclass