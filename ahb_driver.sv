
class ahb_driver extends uvm_driver #(ahb_seq_item);

  `uvm_component_utils(ahb_driver)

  virtual ahb_if vif;

  function new(string name = "ahb_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual ahb_if)::get(
          this, "", "ahb_vif", vif))
      `uvm_fatal("NOVIF",
        {"Virtual interface ahb_vif not set for ",
         get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);

    ahb_seq_item req;

    // Default bus values
    vif.HSEL   = 1'b0;
    vif.HTRANS = 2'b00;
    vif.HWRITE = 1'b0;
    vif.HADDR  = '0;
    vif.HWDATA = '0;
    vif.HSIZE  = 3'b010;
    vif.HREADY = 1'b1;

    forever begin

      seq_item_port.get_next_item(req);

      // --------------------------------------------
      // ADDRESS PHASE
      // --------------------------------------------
      @(negedge vif.HCLK);

      vif.HSEL   = 1'b1;
      vif.HTRANS = 2'b10;
      vif.HADDR  = req.addr;
      vif.HWRITE = req.write;
      vif.HSIZE  = 3'b010;

      // Address phase sampled at rising edge
      @(posedge vif.HCLK);

      // --------------------------------------------
      // DATA PHASE
      // --------------------------------------------
      @(negedge vif.HCLK);

      // Deassert address-phase controls
      vif.HSEL   = 1'b0;
      vif.HTRANS = 2'b00;
      vif.HWRITE = 1'b0;
      vif.HADDR  = '0;

      // Drive write data
      if (req.write)
        vif.HWDATA = req.data;
      else
        vif.HWDATA = '0;

      // Wait for transfer completion
      do begin
        @(posedge vif.HCLK);
      end while (!(vif.HREADY && vif.HREADYOUT));

      // Capture response
      req.resp = vif.HRESP;

      if (!req.write)
        req.rdata = vif.HRDATA;

      // --------------------------------------------
      // CLEANUP
      // --------------------------------------------
      @(negedge vif.HCLK);

      vif.HSEL   = 1'b0;
      vif.HTRANS = 2'b00;
      vif.HWRITE = 1'b0;
      vif.HADDR  = '0;
      vif.HWDATA = '0;

      seq_item_port.item_done();

    end

  endtask

endclass
