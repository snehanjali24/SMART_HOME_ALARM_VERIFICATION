class ahb_monitor extends uvm_monitor;

  `uvm_component_utils(ahb_monitor)

  virtual ahb_if vif;

  uvm_analysis_port #(ahb_seq_item) analysis_port;

  function new(string name = "ahb_monitor",
               uvm_component parent = null);

    super.new(name, parent);

    analysis_port = new("analysis_port", this);

  endfunction

  //==================================================
  // BUILD PHASE
  //==================================================

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual ahb_if)::get(
          this, "", "ahb_vif", vif)) begin

      `uvm_fatal("NOVIF",
        {"Virtual interface ahb_vif not set for ",
         get_full_name()})

    end

  endfunction

  //==================================================
  // RUN PHASE
  //==================================================

  task run_phase(uvm_phase phase);

    ahb_seq_item item;

    forever begin

      //==============================================
      // ADDRESS PHASE
      //==============================================

      @(vif.mon_cb);

      if ((vif.mon_cb.HSEL === 1'b1) &&
          (vif.mon_cb.HTRANS[1] === 1'b1) &&
          (vif.mon_cb.HREADY === 1'b1)) begin

        item = ahb_seq_item::type_id::create("item");

        item.addr   = vif.mon_cb.HADDR;
        item.write  = vif.mon_cb.HWRITE;
        item.hsize  = vif.mon_cb.HSIZE;
        item.htrans = vif.mon_cb.HTRANS;
        item.hready = vif.mon_cb.HREADY;

        `uvm_info("AHB_ADDRESS",
          $sformatf(
            "Address captured: ADDR=%08h WRITE=%0b HTRANS=%0b",
            item.addr, item.write, item.htrans
          ),
          UVM_NONE)

        //============================================
        // DATA PHASE / TRANSFER COMPLETION
        //============================================

        // Wait for the data phase and sample away
        // from the active clock edge.
        @(negedge vif.HCLK);

        // Wait for the slave and bus to be ready.
        // This also allows for wait states.
        while (!((vif.HREADY === 1'b1) &&
                 (vif.HREADYOUT === 1'b1))) begin
          @(negedge vif.HCLK);
        end

        // Capture completed transaction information.
        item.hreadyout = vif.HREADYOUT;
        item.resp      = vif.HRESP;

        if (item.write) begin
          item.data  = vif.HWDATA;
          item.rdata = '0;
        end
        else begin
          item.data  = '0;
          item.rdata = vif.HRDATA;
        end

        //============================================
        // TRANSACTION DEBUG
        //============================================

        `uvm_info("AHB_MON",
          $sformatf(
            "AHB %s ADDR=%08h WDATA=%08h RDATA=%08h HREADY=%0b HREADYOUT=%0b RESP=%0b",
            item.write ? "WRITE" : "READ",
            item.addr,
            item.data,
            item.rdata,
            vif.HREADY,
            item.hreadyout,
            item.resp
          ),
          UVM_NONE)

        //============================================
        // PUBLISH TRANSACTION TO ALL CONNECTED CHECKERS
        //============================================

        `uvm_info("AHB_PUBLISH_DEBUG",
          $sformatf(
            "Publishing transaction: ADDR=%08h WRITE=%0b RDATA=%08h",
            item.addr, item.write, item.rdata
          ),
          UVM_NONE)

        analysis_port.write(item);

      end

    end

  endtask

endclass