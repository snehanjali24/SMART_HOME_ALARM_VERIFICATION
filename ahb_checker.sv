import alarm_pkg::*;

class ahb_checker extends uvm_component;

  `uvm_component_utils(ahb_checker)

  uvm_analysis_imp #(ahb_seq_item, ahb_checker) ahb_imp;


  //==================================================
  // EXPECTED REGISTER VALUES
  //==================================================

  bit [31:0] expected_entry_delay;
  bit [31:0] expected_exit_delay;
  bit [31:0] expected_alarm_duration;
  bit [31:0] expected_version;

  // NUM_ZONES = 8 as defined by the project specification
  bit [7:0] expected_zone_enable;
  bit [7:0] expected_zone_bypass;

  bit [31:0] expected_zone_type;
  bit [IRQ_NUM-1:0] expected_irq_enable;


  //==================================================
  // CONSTRUCTOR
  //==================================================

  function new(string name = "ahb_checker",
               uvm_component parent = null);

    super.new(name, parent);

    ahb_imp = new("ahb_imp", this);

    expected_entry_delay    = DEF_ENTRY_DELAY;
    expected_exit_delay     = DEF_EXIT_DELAY;
    expected_alarm_duration = DEF_ALARM_DUR;

   expected_version = {VERSION_MINOR, VERSION_MAJOR, 16'd8};

    expected_zone_enable    = '0;
    expected_zone_bypass    = '0;
    expected_zone_type      = '0;
    expected_irq_enable     = '0;

  endfunction


  //==================================================
  // AHB TRANSACTION CHECKER
  //==================================================

  function void write(ahb_seq_item item);


    //================================================
    // 1. HTRANS CHECK
    //================================================

    if (item.htrans != 2'b10) begin

      `uvm_error("AHB_CHECK",
        $sformatf(
          "Invalid HTRANS: HTRANS=%0b ADDR=%08h",
          item.htrans,
          item.addr
        ))

    end


    //================================================
    // 2. TRANSFER SIZE CHECK
    //================================================

    if (item.hsize != 3'b010) begin

      `uvm_error("AHB_CHECK",
        $sformatf(
          "Unsupported HSIZE: HSIZE=%0b ADDR=%08h",
          item.hsize,
          item.addr
        ))

    end


    //================================================
    // 3. ADDRESS ALIGNMENT CHECK
    //================================================

    if (item.hsize == 3'b010) begin

      if (item.addr[1:0] != 2'b00) begin

        `uvm_error("AHB_CHECK",
          $sformatf(
            "Misaligned 32-bit transfer: ADDR=%08h",
            item.addr
          ))

      end

    end


    //================================================
    // 4. HRESP CHECK
    //================================================

    if (item.resp === 1'bx) begin

      `uvm_error("AHB_CHECK",
        $sformatf(
          "HRESP is X: ADDR=%08h",
          item.addr
        ))

    end


    //================================================
    // 5. HREADYOUT CHECK
    //================================================

    if (item.hreadyout === 1'bx) begin

      `uvm_error("AHB_CHECK",
        $sformatf(
          "HREADYOUT is X: ADDR=%08h",
          item.addr
        ))

    end


    //================================================
    // 6. HREADY CHECK
    //================================================

    if (item.hready === 1'bx) begin

      `uvm_error("AHB_CHECK",
        $sformatf(
          "HREADY is X: ADDR=%08h",
          item.addr
        ))

    end


    //================================================
    // 7. REGISTER FUNCTIONAL CHECK
    //================================================

    if (!item.write && item.resp == 1'b0) begin

      case (item.addr)

        //============================================
        // STATUS
        //============================================

        ADDR_STATUS: begin

          // STATUS can change during operation (for example, lockout).
          // Do not assume the complete STATUS register must always be zero.
          // Check status bits in the dedicated functional checker.
          `uvm_info("AHB_CHECK",
            $sformatf(
              "STATUS READ: ACTUAL=%08h; status validation delegated to dedicated checker",
              item.rdata
            ),
            UVM_LOW);

        end


        //============================================
        // ENTRY_DELAY
        //============================================

        ADDR_ENTRY_DELAY: begin

          if (item.rdata !== expected_entry_delay)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "ENTRY_DELAY mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_entry_delay,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "ENTRY_DELAY MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // EXIT_DELAY
        //============================================

        ADDR_EXIT_DELAY: begin

          if (item.rdata !== expected_exit_delay)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "EXIT_DELAY mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_exit_delay,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "EXIT_DELAY MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // ALARM_DURATION
        //============================================

        ADDR_ALARM_DURATION: begin

          if (item.rdata !== expected_alarm_duration)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "ALARM_DURATION mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_alarm_duration,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "ALARM_DURATION MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // ZONE_ENABLE
        //============================================

        ADDR_ZONE_ENABLE: begin

          if (item.rdata[7:0] !== expected_zone_enable)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "ZONE_ENABLE mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_zone_enable,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "ZONE_ENABLE MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // ZONE_BYPASS
        //============================================

        ADDR_ZONE_BYPASS: begin

          if (item.rdata[7:0] !== expected_zone_bypass)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "ZONE_BYPASS mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_zone_bypass,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "ZONE_BYPASS MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // ZONE_TYPE
        //============================================

        ADDR_ZONE_TYPE: begin

          if (item.rdata !== expected_zone_type)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "ZONE_TYPE mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_zone_type,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "ZONE_TYPE MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // IRQ_STATUS
        //============================================

        ADDR_IRQ_STATUS: begin

          if (item.rdata !== 32'h0)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "IRQ_STATUS mismatch: EXPECTED=%08h ACTUAL=%08h",
                32'h0,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "IRQ_STATUS MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // IRQ_ENABLE
        //============================================

        ADDR_IRQ_ENABLE: begin

          if (item.rdata[IRQ_NUM-1:0] !== expected_irq_enable)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "IRQ_ENABLE mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_irq_enable,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "IRQ_ENABLE MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end


        //============================================
        // VERSION
        //============================================

        ADDR_VERSION: begin

          if (item.rdata !== expected_version)

            `uvm_error("AHB_CHECK",
              $sformatf(
                "VERSION mismatch: EXPECTED=%08h ACTUAL=%08h",
                expected_version,
                item.rdata
              ))

          else

            `uvm_info("AHB_CHECK",
              $sformatf(
                "VERSION MATCH: VALUE=%08h",
                item.rdata
              ),
              UVM_LOW);

        end

      endcase

    end


    //================================================
    // 8. UPDATE EXPECTED VALUES AFTER SUCCESSFUL WRITE
    //================================================

    if (item.write && item.resp == 1'b0) begin

      case (item.addr)

        ADDR_ENTRY_DELAY:
          expected_entry_delay = item.data[23:0];

        ADDR_EXIT_DELAY:
          expected_exit_delay = item.data[23:0];

        ADDR_ALARM_DURATION:
          expected_alarm_duration = item.data[23:0];

        ADDR_ZONE_ENABLE:
          expected_zone_enable = item.data[7:0];

        ADDR_ZONE_BYPASS:
          expected_zone_bypass = item.data[7:0];

        ADDR_ZONE_TYPE:
          expected_zone_type = item.data;

        ADDR_IRQ_ENABLE:
          expected_irq_enable = item.data[IRQ_NUM-1:0];

      endcase

    end


    //================================================
    // 9. RESULT
    //================================================

    `uvm_info("AHB_CHECK",
      $sformatf(
        "Checked AHB %s: ADDR=%08h HTRANS=%0b HSIZE=%0b RESP=%0b HREADYOUT=%0b",
        item.write ? "WRITE" : "READ",
        item.addr,
        item.htrans,
        item.hsize,
        item.resp,
        item.hreadyout
      ),
      UVM_LOW)

  endfunction

endclass