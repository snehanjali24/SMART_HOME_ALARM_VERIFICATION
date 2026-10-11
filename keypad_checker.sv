
import alarm_pkg::*;

`uvm_analysis_imp_decl(_keypad_ahb)

class keypad_checker extends uvm_component;

  `uvm_component_utils(keypad_checker)

  //==================================================
  // ANALYSIS IMPLEMENTATIONS
  //==================================================

  uvm_analysis_imp #(keypad_seq_item,
                     keypad_checker) keypad_imp;

  uvm_analysis_imp_keypad_ahb #(ahb_seq_item,
                                keypad_checker) ahb_imp;

  // Reference model
  alarm_reference_model ref_model;

  //==================================================
  // TEST-SPECIFIC CHECK ENABLES
  //==================================================

  bit check_reset;
  bit check_valid;
  bit check_invalid;
  bit check_lockout;
  bit check_recovery;

  //==================================================
  // ACTUAL DUT RESPONSE FLAGS
  //==================================================

  logic dut_pin_ok;
  logic dut_pin_bad;

  //==================================================
  // STATUS REGISTER BIT
  //==================================================

  localparam int STATUS_LOCKED_BIT = 6;

  //==================================================
  // CONSTRUCTOR
  //==================================================

  function new(string name = "keypad_checker",
               uvm_component parent = null);

    super.new(name, parent);

    keypad_imp = new("keypad_imp", this);
    ahb_imp    = new("ahb_imp", this);

    check_reset    = 1'b0;
    check_valid    = 1'b0;
    check_invalid  = 1'b0;
    check_lockout  = 1'b0;
    check_recovery = 1'b0;

    dut_pin_ok  = 1'b0;
    dut_pin_bad = 1'b0;
    ref_model   = null;

  endfunction

  //==================================================
  // KEYPAD MONITOR
  //==================================================

  function void write(keypad_seq_item item);

    // VALID PIN STIMULUS
    if (check_valid &&
        item.pin_valid &&
        (item.pin_code == DEF_PIN)) begin

      `uvm_info("KEYPAD_VALID",
        $sformatf(
          "Valid PIN stimulus observed: PIN=%0h",
          item.pin_code
        ),
        UVM_LOW)

    end

    // INVALID PIN STIMULUS
    if (check_invalid &&
        item.pin_valid &&
        (item.pin_code != DEF_PIN)) begin

      `uvm_info("KEYPAD_INVALID",
        $sformatf(
          "Invalid PIN stimulus observed: PIN=%0h",
          item.pin_code
        ),
        UVM_LOW)

    end

    // RECOVERY STIMULUS
    if (check_recovery &&
        item.pin_valid &&
        (item.pin_code == DEF_PIN)) begin

      `uvm_info("KEYPAD_RECOVERY",
        $sformatf(
          "Recovery PIN stimulus observed: PIN=%0h",
          item.pin_code
        ),
        UVM_LOW)

    end

  endfunction

  //==================================================
  // ACTUAL DUT VALID PIN CHECK
  //==================================================

  task automatic check_actual_pin_ok();

    bit pin_accepted;

    pin_accepted = 1'b0;

    `uvm_info("KEYPAD_VALID",
      "Waiting for actual DUT pin_ok response",
      UVM_LOW)

    fork : wait_for_pin_ok

      begin
        @(posedge tb_top.dut.u_core.u_pin.pin_ok);
        pin_accepted = 1'b1;
      end

      begin
        #100ns;
      end

    join_any

    disable wait_for_pin_ok;

    if (pin_accepted) begin

      dut_pin_ok = 1'b1;

      `uvm_info("KEYPAD_VALID",
        "Actual DUT pin_ok=1",
        UVM_LOW)

      `uvm_info("KEYPAD_VALID",
        "PASS: DUT accepted the valid PIN",
        UVM_LOW)

    end
    else begin

      dut_pin_ok = 1'b0;

      `uvm_error("KEYPAD_VALID",
        "FAIL: DUT did not assert pin_ok within 100ns")

    end

  endtask

  //==================================================
  // ACTUAL DUT INVALID PIN CHECK
  // Checks each invalid PIN response separately.
  //==================================================

  task automatic check_actual_pin_bad(
    int unsigned expected_attempts = 3
  );

    bit pin_rejected;

    for (int i = 0; i < expected_attempts; i++) begin

      pin_rejected = 1'b0;

      `uvm_info("KEYPAD_INVALID",
        $sformatf(
          "Waiting for pin_bad response for attempt %0d/%0d",
          i + 1, expected_attempts
        ),
        UVM_LOW)

      fork : wait_for_pin_bad

        begin
          @(posedge tb_top.dut.u_core.u_pin.pin_bad);
          pin_rejected = 1'b1;
        end

        begin
          #100ns;
        end

      join_any

      disable wait_for_pin_bad;

      if (pin_rejected) begin

        dut_pin_bad = 1'b1;

        `uvm_info("KEYPAD_INVALID",
          $sformatf(
            "Actual DUT pin_bad=1 for attempt %0d",
            i + 1
          ),
          UVM_LOW)

        `uvm_info("KEYPAD_INVALID",
          $sformatf(
            "PASS: DUT rejected invalid PIN attempt %0d/%0d",
            i + 1, expected_attempts
          ),
          UVM_LOW)

      end
      else begin

        dut_pin_bad = 1'b0;

        `uvm_error("KEYPAD_INVALID",
          $sformatf(
            "FAIL: DUT did not assert pin_bad for attempt %0d within 100ns",
            i + 1
          ))

      end

    end

  endtask

  //==================================================
  // AHB MONITOR -> ACTUAL DUT STATUS
  //==================================================

  function void write_keypad_ahb(ahb_seq_item item);

    if (!item.write &&
        (item.addr == ADDR_STATUS) &&
        (item.resp == 1'b0)) begin

      // RESET CHECK
      if (check_reset) begin

        `uvm_info("KEYPAD_RESET",
          $sformatf(
            "Expected locked=0 | Actual STATUS[%0d]=%0b",
            STATUS_LOCKED_BIT,
            item.rdata[STATUS_LOCKED_BIT]
          ),
          UVM_LOW)

        if (item.rdata[STATUS_LOCKED_BIT] === 1'b0) begin

          `uvm_info("KEYPAD_RESET",
            "PASS: Keypad is unlocked after reset",
            UVM_LOW)

        end
        else begin

          `uvm_error("KEYPAD_RESET",
            $sformatf(
              "FAIL: Expected locked=0 | Actual locked=%0b",
              item.rdata[STATUS_LOCKED_BIT]
            ))

        end

      end

      // LOCKOUT CHECK
      if (check_lockout) begin

        if (ref_model == null) begin

          `uvm_error("KEYPAD_LOCKOUT",
            "Reference model handle is null")

        end
        else begin

          `uvm_info("KEYPAD_LOCKOUT",
            $sformatf(
              "Expected locked=%0b | Actual STATUS[%0d]=%0b",
              ref_model.expected_locked,
              STATUS_LOCKED_BIT,
              item.rdata[STATUS_LOCKED_BIT]
            ),
            UVM_LOW)

          if (ref_model.expected_locked === 1'b1 &&
              item.rdata[STATUS_LOCKED_BIT] === 1'b1) begin

            `uvm_info("KEYPAD_LOCKOUT",
              "PASS: DUT entered keypad lockout",
              UVM_LOW)

          end
          else if (ref_model.expected_locked === 1'b1 &&
                   item.rdata[STATUS_LOCKED_BIT] !== 1'b1) begin

            `uvm_error("KEYPAD_LOCKOUT",
              $sformatf(
                "FAIL: Expected lockout=1 | Actual STATUS[%0d]=%0b",
                STATUS_LOCKED_BIT,
                item.rdata[STATUS_LOCKED_BIT]
              ))

          end
          else begin

            `uvm_info("KEYPAD_LOCKOUT",
              "Lockout is not expected by the reference model at this read",
              UVM_LOW)

          end

        end

      end

      // RECOVERY CHECK
      if (check_recovery) begin

        `uvm_info("KEYPAD_RECOVERY",
          $sformatf(
            "Expected locked=0 | Actual STATUS[%0d]=%0b",
            STATUS_LOCKED_BIT,
            item.rdata[STATUS_LOCKED_BIT]
          ),
          UVM_LOW)

        if (item.rdata[STATUS_LOCKED_BIT] === 1'b0) begin

          `uvm_info("KEYPAD_RECOVERY",
            "PASS: Keypad is unlocked",
            UVM_LOW)

        end
        else begin

          `uvm_error("KEYPAD_RECOVERY",
            $sformatf(
              "FAIL: Expected locked=0 | Actual locked=%0b",
              item.rdata[STATUS_LOCKED_BIT]
            ))

        end

      end

    end

  endfunction

endclass
