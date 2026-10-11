interface alarm_output_if(input logic sys_clk);

  logic siren;
  logic strobe;
  logic alarm_active;

  clocking mon_cb @(posedge sys_clk);
    input siren;
    input strobe;
    input alarm_active;
  endclocking

endinterface