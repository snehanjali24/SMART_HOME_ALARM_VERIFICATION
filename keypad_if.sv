
interface keypad_if #(parameter int PIN_WIDTH = 16)
                     (input logic sys_clk,
                      input logic sys_reset_n);

  logic                 pin_valid;
  logic [PIN_WIDTH-1:0] pin_code;

  clocking drv_cb @(posedge sys_clk);
    output pin_valid, pin_code;
  endclocking

  clocking mon_cb @(posedge sys_clk);
    input pin_valid, pin_code;
  endclocking

endinterface
