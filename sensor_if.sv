interface sensor_if #(parameter int NUM_ZONES = 8)
                     (input logic sensor_clk,
                      input logic sensor_reset_n);

  logic [NUM_ZONES-1:0] sensor_in;   // asynchronous physical sensor inputs

  clocking drv_cb @(posedge sensor_clk);
    output sensor_in;
  endclocking

  clocking mon_cb @(posedge sensor_clk);
    input sensor_in;
  endclocking

endinterface