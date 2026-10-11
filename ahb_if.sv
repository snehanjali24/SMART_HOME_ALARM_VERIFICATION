interface ahb_if (input logic HCLK,
                  input logic HRESETn);

  // Inputs to the slave
  logic        HSEL;
  logic [31:0] HADDR;
  logic [1:0]  HTRANS;
  logic        HWRITE;
  logic [2:0]  HSIZE;
  logic [31:0] HWDATA;
  logic        HREADY;

  // Outputs from the slave
  logic [31:0] HRDATA;
  logic        HREADYOUT;
  logic        HRESP;


  //==================================================
  // DRIVER CLOCKING BLOCK
  //==================================================
  clocking drv_cb @(posedge HCLK);
    output HSEL;
    output HADDR;
    output HTRANS;
    output HWRITE;
    output HSIZE;
    output HWDATA;
    output HREADY;

    input HRDATA;
    input HREADYOUT;
    input HRESP;
  endclocking


  //==================================================
  // MONITOR CLOCKING BLOCK
  //==================================================
  clocking mon_cb @(posedge HCLK);
    input HSEL;
    input HADDR;
    input HTRANS;
    input HWRITE;
    input HSIZE;
    input HWDATA;
    input HREADY;

    input HRDATA;
    input HREADYOUT;
    input HRESP;
  endclocking

endinterface