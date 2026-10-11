
module tb_top;

  import uvm_pkg::*;
  import alarm_pkg::*;

  localparam int NUM_ZONES = 8;
  localparam int PIN_WIDTH = 16;

  //==================================================
  // Three independent clocks
  //==================================================
  logic sensor_clk = 0;
  logic sys_clk    = 0;
  logic HCLK       = 0;

  logic sensor_reset_n;
  logic sys_reset_n;
  logic HRESETn;

  // ADDED: System reset override for keypad reset testing
  logic sys_reset_n_init;
  logic sys_reset_override_en = 1'b0;
  logic sys_reset_override_n  = 1'b1;

  always #7ns sensor_clk = ~sensor_clk;
  always #5ns sys_clk    = ~sys_clk;
  always #6ns HCLK       = ~HCLK;


  //==================================================
  // Reset generation
  //==================================================
  initial begin

    sensor_reset_n   = 1'b0;
    sys_reset_n_init = 1'b0;
    HRESETn          = 1'b0;

    // Keep all resets active for multiple clock cycles
    repeat (2) @(posedge sensor_clk);
    sensor_reset_n = 1'b1;

    repeat (2) @(posedge sys_clk);
    sys_reset_n_init = 1'b1;

    repeat (2) @(posedge HCLK);
    HRESETn = 1'b1;

  end

  // ADDED: Select normal reset or test-controlled reset
  assign sys_reset_n = sys_reset_override_en
                     ? sys_reset_override_n
                     : sys_reset_n_init;


  //==================================================
  // Interfaces
  //==================================================

  // Sensor interface
  sensor_if #(.NUM_ZONES(NUM_ZONES)) s_if (
    .sensor_clk     (sensor_clk),
    .sensor_reset_n (sensor_reset_n)
  );

  // Keypad interface
  keypad_if #(.PIN_WIDTH(PIN_WIDTH)) k_if (
    .sys_clk       (sys_clk),
    .sys_reset_n   (sys_reset_n)
  );

  // AHB interface
  ahb_if a_if (
    .HCLK    (HCLK),
    .HRESETn (HRESETn)
  );

  // Alarm output interface
  alarm_output_if alarm_out_if (
    .sys_clk(sys_clk)
  );


  //==================================================
  // DUT
  //==================================================

  smart_home_alarm_top #(
    .NUM_ZONES(NUM_ZONES),
    .PIN_WIDTH(PIN_WIDTH)
  ) dut (

    // -------------------------
    // Sensor domain
    // -------------------------
    .sensor_clk     (sensor_clk),
    .sensor_reset_n (sensor_reset_n),
    .sensor_in      (s_if.sensor_in),

    // -------------------------
    // System domain
    // -------------------------
    .sys_clk        (sys_clk),
    .sys_reset_n    (sys_reset_n),
    .pin_valid      (k_if.pin_valid),
    .pin_code       (k_if.pin_code),

    // -------------------------
    // Alarm outputs
    // -------------------------
    .siren          (alarm_out_if.siren),
    .strobe         (alarm_out_if.strobe),
    .alarm_active   (alarm_out_if.alarm_active),

    // -------------------------
    // AHB domain
    // -------------------------
    .HCLK           (HCLK),
    .HRESETn        (HRESETn),
    .HSEL           (a_if.HSEL),
    .HADDR          (a_if.HADDR),
    .HTRANS         (a_if.HTRANS),
    .HWRITE         (a_if.HWRITE),
    .HSIZE          (a_if.HSIZE),
    .HWDATA         (a_if.HWDATA),
    .HREADY         (a_if.HREADY),

    .HRDATA         (a_if.HRDATA),
    .HREADYOUT      (a_if.HREADYOUT),
    .HRESP          (a_if.HRESP)
  );


  //==================================================
  // UVM configuration
  //==================================================

  initial begin

    // Sensor virtual interface
    uvm_config_db#(virtual sensor_if)::set(
      null,
      "uvm_test_top.alarm_env.sensor_agent.*",
      "sensor_vif",
      s_if
    );

    // Keypad virtual interface
    uvm_config_db#(virtual keypad_if)::set(
      null,
      "uvm_test_top.alarm_env.keypad_agent.*",
      "keypad_vif",
      k_if
    );

    // AHB virtual interface
    uvm_config_db#(virtual ahb_if)::set(
      null,
      "uvm_test_top.alarm_env.ahb_agent.*",
      "ahb_vif",
      a_if
    );

    // Alarm output virtual interface
    uvm_config_db#(virtual alarm_output_if)::set(
      null,
      "uvm_test_top.alarm_env*",
      "alarm_output_vif",
      alarm_out_if
    );

    //================================================
    // Select test
    //================================================

    // Sensor tests
    //run_test("sensor_reset_test");
  //  run_test("sensor_basic_test");
    // run_test("sensor_debounce_test");
    // run_test("sensor_fault_test");
    // run_test("sensor_multi_zone_test");
     // run_test("motion_qualification_test");

    // Keypad tests
   // run_test("keypad_reset_test");
     run_test("pin_lockout_test");
    //run_test("pin_valid_test");
   // run_test("pin_invalid_test");

    // AHB tests
     //run_test("ahb_reset_test");
    // run_test("ahb_register_access_test");
 //  run_test("ahb_read_write_test");
    //run_test("ahb_delay_config_test");
   //  run_test("ahb_version_test");
    // run_test("ahb_zone_config_test");

    // run_test("alarm_priority_test");

  end

  //==================================================
  // Waveform dump
  //==================================================
  
  

   


endmodule
