
import alarm_pkg::*;

`uvm_analysis_imp_decl(_sensor_ahb)

class sensor_checker extends uvm_component;

  `uvm_component_utils(sensor_checker)

  //==================================================
  // ANALYSIS IMPLEMENTATIONS
  //==================================================

  uvm_analysis_imp #(sensor_seq_item, sensor_checker) sensor_imp;

  uvm_analysis_imp_sensor_ahb #(ahb_seq_item, sensor_checker) ahb_imp;

  // Reference model
  alarm_reference_model ref_model;

  //==================================================
  // TEST-SPECIFIC CHECK ENABLES
  //==================================================

  bit check_reset;
  bit check_basic;
  bit check_debounce;
  bit check_fault;
  bit check_multi_zone;

  //==================================================
  // RESET TEST RESULT TRACKING
  //==================================================

  bit reset_check_seen;
  bit reset_check_pass;

  //==================================================
  // DEBOUNCE TEST RESULT TRACKING
  //==================================================

  // These flags retain the result of all debounce checks.
  bit debounce_check_seen;
  bit debounce_check_failed;

  //==================================================
  // CONSTRUCTOR
  //==================================================

  function new(string name = "sensor_checker",
               uvm_component parent = null);

    super.new(name, parent);

    sensor_imp = new("sensor_imp", this);
    ahb_imp    = new("ahb_imp", this);

    check_reset      = 1'b0;
    check_basic      = 1'b0;
    check_debounce   = 1'b0;
    check_fault      = 1'b0;
    check_multi_zone = 1'b0;

    reset_check_seen = 1'b0;
    reset_check_pass = 1'b0;

    debounce_check_seen   = 1'b0;
    debounce_check_failed = 1'b0;

  endfunction

  //==================================================
  // RESET DEBOUNCE RESULT BEFORE EACH TEST
  //==================================================

  function void reset_debounce_result();

    debounce_check_seen   = 1'b0;
    debounce_check_failed = 1'b0;

  endfunction

  //==================================================
  // SENSOR MONITOR -> REFERENCE MODEL CHECKS
  //==================================================

  function void write(sensor_seq_item item);

    if (ref_model == null) begin
      `uvm_error("SENSOR_CHECKER",
                 "Reference model handle is null")
      return;
    end

    if (check_reset) begin
      `uvm_info("SENSOR_RESET",
        $sformatf(
          "SENSOR SAMPLE | Input=%08h | Expected Zone Level=%08h",
          item.sensor_in,
          ref_model.exp_zone_level
        ),
        UVM_NONE)
    end

    if (check_basic) begin
      `uvm_info("SENSOR_BASIC",
        $sformatf(
          "SENSOR SAMPLE | Input=%08h | Expected Zone Level=%08h",
          item.sensor_in,
          ref_model.exp_zone_level
        ),
        UVM_LOW)
    end

    if (check_debounce) begin
      `uvm_info("SENSOR_DEBOUNCE",
        $sformatf(
          "DEBOUNCE SAMPLE | Raw Input=%08h | Expected Qualified Level=%08h",
          item.sensor_in,
          ref_model.exp_zone_level
        ),
        UVM_LOW)
    end

    if (check_fault) begin
      `uvm_info("SENSOR_FAULT",
        $sformatf(
          "SENSOR SAMPLE | Input=%08h | Expected Fault=%08h",
          item.sensor_in,
          ref_model.exp_zone_fault
        ),
        UVM_LOW)
    end

    if (check_multi_zone) begin
      `uvm_info("SENSOR_MULTI_ZONE",
        $sformatf(
          "SENSOR SAMPLE | Input=%08h | Expected Zone Level=%08h",
          item.sensor_in,
          ref_model.exp_zone_level
        ),
        UVM_LOW)
    end

  endfunction

  //==================================================
  // AHB MONITOR -> ACTUAL DUT ZONE STATUS
  //==================================================

  function void write_sensor_ahb(ahb_seq_item item);

    bit [7:0] expected_zone_level;
    bit [7:0] actual_zone_level;

    // Log received AHB transaction
    `uvm_info("SENSOR_AHB_DEBUG",
      $sformatf(
        "AHB TRANSACTION | ADDR=%08h | WRITE=%0b | RDATA=%08h | RESP=%0b",
        item.addr,
        item.write,
        item.rdata,
        item.resp
      ),
      UVM_LOW)

    // Check only successful reads of ZONE_STATUS.
    if (item.write ||
        (item.addr != ADDR_ZONE_STATUS) ||
        (item.resp != 1'b0))
      return;

    if (ref_model == null) begin
      `uvm_error("SENSOR_CHECKER",
                 "Cannot check ZONE_STATUS: reference model is null")
      return;
    end

    actual_zone_level = item.rdata[7:0];

    //================================================
    // RESET CHECK
    //================================================

    if (check_reset) begin

      reset_check_seen = 1'b1;
      expected_zone_level = 8'h00;

      `uvm_info("SENSOR_RESET",
        $sformatf(
          "ZONE_STATUS RESET CHECK | TIME=%0t | EXPECTED=%02h | ACTUAL=%02h",
          $time,
          expected_zone_level,
          actual_zone_level
        ),
        UVM_NONE)

      if (actual_zone_level !== expected_zone_level) begin

        reset_check_pass = 1'b0;

        `uvm_error("SENSOR_RESET",
          $sformatf(
            "RESET CHECK FAILED | EXPECTED=%02h | ACTUAL=%02h",
            expected_zone_level,
            actual_zone_level
          ))

      end
      else begin

        reset_check_pass = 1'b1;

        `uvm_info("SENSOR_RESET",
          "RESET CHECK PASSED | ZONE_STATUS is zero",
          UVM_NONE)

      end

    end

    //================================================
    // BASIC SENSOR CHECK
    //================================================

    if (check_basic) begin

      expected_zone_level = ref_model.exp_zone_level[7:0];

      `uvm_info("SENSOR_BASIC_CHECK",
        $sformatf(
          "ZONE_STATUS CHECK | TIME=%0t | EXPECTED=%02h | ACTUAL=%02h",
          $time,
          expected_zone_level,
          actual_zone_level
        ),
        UVM_NONE)

      if (actual_zone_level !== expected_zone_level) begin

        `uvm_error("SENSOR_BASIC_CHECK",
          $sformatf(
            "BASIC SENSOR CHECK FAILED | EXPECTED=%02h | ACTUAL=%02h",
            expected_zone_level,
            actual_zone_level
          ))

      end
      else begin

        `uvm_info("SENSOR_BASIC_CHECK",
          $sformatf(
            "BASIC SENSOR CHECK PASSED | VALUE=%02h",
            actual_zone_level
          ),
          UVM_NONE)

      end

    end

    //================================================
    // DEBOUNCE CHECK
    //================================================

    if (check_debounce) begin

      debounce_check_seen = 1'b1;
      expected_zone_level = ref_model.exp_zone_level[7:0];

      `uvm_info("SENSOR_DEBOUNCE",
        $sformatf(
          "DEBOUNCE CHECK | TIME=%0t | ADDRESS=%08h | EXPECTED=%02h | ACTUAL=%02h",
          $time,
          item.addr,
          expected_zone_level,
          actual_zone_level
        ),
        UVM_NONE)

      if (actual_zone_level !== expected_zone_level) begin

        // Sticky failure: a later matching read cannot clear this.
        debounce_check_failed = 1'b1;

        `uvm_error("SENSOR_DEBOUNCE",
          $sformatf(
            "DEBOUNCE CHECK FAILED | TIME=%0t | EXPECTED=%02h | ACTUAL=%02h | FAILURE_RECORDED=1",
            $time,
            expected_zone_level,
            actual_zone_level
          ))

      end
      else begin

        `uvm_info("SENSOR_DEBOUNCE",
          $sformatf(
            "DEBOUNCE COMPARISON PASSED | EXPECTED=%02h | ACTUAL=%02h | EARLIER_FAILURE=%0b",
            expected_zone_level,
            actual_zone_level,
            debounce_check_failed
          ),
          UVM_NONE)

      end

    end

    //================================================
    // MULTI-ZONE CHECK
    //================================================

    if (check_multi_zone) begin

      expected_zone_level = ref_model.exp_zone_level[7:0];

      `uvm_info("SENSOR_MULTI_ZONE",
        $sformatf(
          "MULTI-ZONE CHECK | TIME=%0t | EXPECTED=%02h | ACTUAL=%02h",
          $time,
          expected_zone_level,
          actual_zone_level
        ),
        UVM_NONE)

      if (actual_zone_level !== expected_zone_level) begin

        `uvm_error("SENSOR_MULTI_ZONE",
          $sformatf(
            "MULTI-ZONE CHECK FAILED | EXPECTED=%02h | ACTUAL=%02h",
            expected_zone_level,
            actual_zone_level
          ))

      end
      else begin

        `uvm_info("SENSOR_MULTI_ZONE",
          "MULTI-ZONE COMPARISON PASSED",
          UVM_NONE)

      end

    end

  endfunction

endclass
