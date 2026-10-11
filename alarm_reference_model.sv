`uvm_analysis_imp_decl(_keypad)
`uvm_analysis_imp_decl(_ahb)

import alarm_pkg::*;

class alarm_reference_model extends uvm_component;

  `uvm_component_utils(alarm_reference_model)


  //==================================================
  // PARAMETERS
  //==================================================

  localparam int NUM_ZONES       = 8;
  localparam int DEBOUNCE_CYCLES = 4;
  localparam int MAX_ATTEMPTS    = 3;


  //==================================================
  // SENSOR EXPECTED VALUES
  //==================================================

  bit [NUM_ZONES-1:0] exp_zone_level;
  bit [NUM_ZONES-1:0] exp_zone_event;
  bit [NUM_ZONES-1:0] exp_zone_fault;

  // Reference-model state for the DUT's two-stage sensor synchronizer.
  bit [NUM_ZONES-1:0] sync_stage1;
  bit [NUM_ZONES-1:0] sync_stage2;

  // Previous synchronized sample used by the debounce model.
  bit [NUM_ZONES-1:0] previous_input;

  int debounce_count[NUM_ZONES];

  // Event generated when sensor level is debounce-qualified
  event sensor_qualified;


  //==================================================
  // KEYPAD EXPECTED VALUES
  //==================================================

  int expected_fail_count;

  bit expected_pin_ok;
  bit expected_pin_bad;
  bit expected_locked;


  //==================================================
  // AHB EXPECTED REGISTER VALUES
  //==================================================

  bit [23:0] expected_entry_delay;
  bit [23:0] expected_exit_delay;
  bit [23:0] expected_alarm_duration;
  bit [23:0] expected_lockout_delay;

  bit [15:0] expected_pin_config;

  bit [NUM_ZONES-1:0] expected_zone_enable;
  bit [NUM_ZONES-1:0] expected_zone_bypass;

  bit [31:0] expected_zone_type;

  bit [5:0] expected_irq_enable;


  //==================================================
  // ANALYSIS IMPLEMENTATIONS
  //==================================================

  uvm_analysis_imp #(sensor_seq_item,
                     alarm_reference_model) sensor_imp;

  uvm_analysis_imp_keypad #(keypad_seq_item,
                            alarm_reference_model) keypad_imp;

  uvm_analysis_imp_ahb #(ahb_seq_item,
                         alarm_reference_model) ahb_imp;


  //==================================================
  // CONSTRUCTOR
  //==================================================

  function new(string name = "alarm_reference_model",
               uvm_component parent = null);

    super.new(name, parent);

    sensor_imp = new("sensor_imp", this);
    keypad_imp = new("keypad_imp", this);
    ahb_imp    = new("ahb_imp", this);

    reset_model();

  endfunction


  //==================================================
  // GET DEBOUNCE CYCLES
  //==================================================

  function int get_debounce_cycles();

    return DEBOUNCE_CYCLES;

  endfunction


  //==================================================
  // RESET MODEL
  //==================================================

  function void reset_model();

    //================================================
    // SENSOR
    //================================================

    exp_zone_level = '0;
    exp_zone_event = '0;
    exp_zone_fault = '0;

    // Model the DUT's two synchronizer stages.
    sync_stage1  = '0;
    sync_stage2  = '0;
    previous_input = '0;

    foreach (debounce_count[i])
      debounce_count[i] = 0;


    //================================================
    // KEYPAD
    //================================================

    expected_fail_count = 0;
    expected_pin_ok     = 1'b0;
    expected_pin_bad    = 1'b0;
    expected_locked     = 1'b0;


    //================================================
    // AHB REGISTER DEFAULTS
    //================================================

    expected_entry_delay    = DEF_ENTRY_DELAY;
    expected_exit_delay     = DEF_EXIT_DELAY;
    expected_alarm_duration = DEF_ALARM_DUR;
    expected_lockout_delay  = DEF_LOCKOUT;

    expected_pin_config     = DEF_PIN;

    expected_zone_enable    = '0;
    expected_zone_bypass    = '0;

    expected_zone_type      = '0;

    expected_irq_enable     = '0;

  endfunction


  //==================================================
  // RESET KEYPAD REFERENCE-MODEL STATE
  // Call this from the test when sys_reset_n is asserted.
  //==================================================

  function void reset_keypad_model();

    expected_fail_count = 0;
    expected_pin_ok     = 1'b0;
    expected_pin_bad    = 1'b0;
    expected_locked     = 1'b0;

    `uvm_info("REF_MODEL",
      "KEYPAD MODEL RESET: fail_count=0, locked=0",
      UVM_LOW)

  endfunction


  //==================================================
  // SENSOR REFERENCE MODEL
  //==================================================

  function void write(sensor_seq_item item);

    bit [NUM_ZONES-1:0] sync_sample;

    // Clear event pulse every sample.
    exp_zone_event = '0;

    // Use the OLD second-stage value for this cycle, matching
    // nonblocking-assignment behavior in the DUT synchronizer.
    sync_sample = sync_stage2;

    // Advance the modeled two-stage synchronizer.
    sync_stage2 = sync_stage1;
    sync_stage1 = item.sensor_in;

    // Debounce the synchronized sensor values, not the raw inputs.
    for (int i = 0; i < NUM_ZONES; i++) begin

      if (sync_sample[i] == previous_input[i]) begin
        if (debounce_count[i] < DEBOUNCE_CYCLES)
          debounce_count[i]++;
      end
      else begin
        debounce_count[i] = 1;
      end

      // Qualify after DEBOUNCE_CYCLES consecutive synchronized samples.
      if (debounce_count[i] >= DEBOUNCE_CYCLES) begin
        if (exp_zone_level[i] != sync_sample[i]) begin
          exp_zone_level[i] = sync_sample[i];
          exp_zone_event[i] = 1'b1;

          // Notify testbench that sensor qualification occurred.
          -> sensor_qualified;
        end
      end
    end

    previous_input = sync_sample;

    `uvm_info("REF_MODEL",
      $sformatf(
        "SENSOR: Raw Input=%b Sync Sample=%b Expected Zone Level=%b",
        item.sensor_in,
        sync_sample,
        exp_zone_level
      ),
      UVM_LOW)

  endfunction


  //==================================================
  // KEYPAD REFERENCE MODEL
  //==================================================

  function void write_keypad(keypad_seq_item item);

    // Default pulse outputs
    expected_pin_ok  = 1'b0;
    expected_pin_bad = 1'b0;


    //================================================
    // IGNORE INPUT WHILE LOCKED
    //================================================

    if (expected_locked) begin

      `uvm_info("REF_MODEL",
        $sformatf(
          "KEYPAD: Input ignored because keypad is locked, fail_count=%0d",
          expected_fail_count
        ),
        UVM_LOW)

      return;

    end


    //================================================
    // PROCESS PIN ATTEMPT
    //================================================

    if (item.pin_valid) begin


      //==============================================
      // VALID PIN
      //==============================================

      if (item.pin_code == DEF_PIN) begin

        expected_pin_ok = 1'b1;

        // Successful authentication clears failures
        expected_fail_count = 0;

        `uvm_info("REF_MODEL",
          $sformatf(
            "KEYPAD: VALID PIN expected, fail_count=%0d, locked=%0b",
            expected_fail_count,
            expected_locked
          ),
          UVM_LOW)

      end


      //==============================================
      // INVALID PIN
      //==============================================

      else begin

        expected_pin_bad = 1'b1;

        expected_fail_count++;


        //============================================
        // LOCKOUT
        //============================================

        if (expected_fail_count >= MAX_ATTEMPTS) begin

          expected_locked = 1'b1;

          `uvm_info("REF_MODEL",
            $sformatf(
              "KEYPAD: INVALID PIN expected, fail_count=%0d, LOCKOUT expected=1",
              expected_fail_count
            ),
            UVM_LOW)

        end


        //============================================
        // INVALID BUT NOT LOCKED
        //============================================

        else begin

          `uvm_info("REF_MODEL",
            $sformatf(
              "KEYPAD: INVALID PIN expected, fail_count=%0d, locked=%0b",
              expected_fail_count,
              expected_locked
            ),
            UVM_LOW)

        end

      end

    end

  endfunction


  //==================================================
  // AHB REFERENCE MODEL
  //==================================================

  function void write_ahb(ahb_seq_item item);

    //================================================
    // AHB WRITE
    //================================================

    if (item.write && item.resp == 1'b0) begin

      case (item.addr)


        //============================================
        // ENTRY DELAY
        //============================================

        ADDR_ENTRY_DELAY: begin

          expected_entry_delay =
            item.data[23:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: ENTRY_DELAY expected=%0d",
              expected_entry_delay
            ),
            UVM_LOW)

        end


        //============================================
        // EXIT DELAY
        //============================================

        ADDR_EXIT_DELAY: begin

          expected_exit_delay =
            item.data[23:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: EXIT_DELAY expected=%0d",
              expected_exit_delay
            ),
            UVM_LOW)

        end


        //============================================
        // ALARM DURATION
        //============================================

        ADDR_ALARM_DURATION: begin

          expected_alarm_duration =
            item.data[23:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: ALARM_DURATION expected=%0d",
              expected_alarm_duration
            ),
            UVM_LOW)

        end


        //============================================
        // LOCKOUT DELAY
        //============================================

        ADDR_LOCKOUT_DELAY: begin

          expected_lockout_delay =
            item.data[23:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: LOCKOUT_DELAY expected=%0d",
              expected_lockout_delay
            ),
            UVM_LOW)

        end


        //============================================
        // PIN CONFIG
        //============================================

        ADDR_PIN_CONFIG: begin

          expected_pin_config =
            item.data[15:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: PIN_CONFIG expected=%0h",
              expected_pin_config
            ),
            UVM_LOW)

        end


        //============================================
        // ZONE ENABLE
        //============================================

        ADDR_ZONE_ENABLE: begin

          expected_zone_enable =
            item.data[NUM_ZONES-1:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: ZONE_ENABLE expected=%0h",
              expected_zone_enable
            ),
            UVM_LOW)

        end


        //============================================
        // ZONE BYPASS
        //============================================

        ADDR_ZONE_BYPASS: begin

          expected_zone_bypass =
            item.data[NUM_ZONES-1:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: ZONE_BYPASS expected=%0h",
              expected_zone_bypass
            ),
            UVM_LOW)

        end


        //============================================
        // ZONE TYPE
        //============================================

        ADDR_ZONE_TYPE: begin

          expected_zone_type = item.data;

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: ZONE_TYPE expected=%0h",
              expected_zone_type
            ),
            UVM_LOW)

        end


        //============================================
        // IRQ ENABLE
        //============================================

        ADDR_IRQ_ENABLE: begin

          expected_irq_enable =
            item.data[5:0];

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: IRQ_ENABLE expected=%0h",
              expected_irq_enable
            ),
            UVM_LOW)

        end


        //============================================
        // OTHER WRITES
        //============================================

        default: begin

          `uvm_info("REF_MODEL",
            $sformatf(
              "AHB WRITE: ADDR=%0h DATA=%0h - no reference state update",
              item.addr,
              item.data
            ),
            UVM_LOW)

        end

      endcase

    end


    //================================================
    // AHB READ
    //================================================

    else if (!item.write && item.resp == 1'b0) begin

      `uvm_info("REF_MODEL",
        $sformatf(
          "AHB READ: ADDR=%0h RDATA=%0h",
          item.addr,
          item.rdata
        ),
        UVM_LOW)

    end

  endfunction

endclass