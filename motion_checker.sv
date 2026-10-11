class motion_checker extends uvm_component;

  `uvm_component_utils(motion_checker)

  uvm_analysis_imp #(alarm_output_transaction, motion_checker) alarm_imp;

  bit expected_alarm_active;

  function new(string name = "motion_checker",
               uvm_component parent = null);
    super.new(name, parent);
    alarm_imp = new("alarm_imp", this);
    expected_alarm_active = 1'b0;
  endfunction

  function void write(alarm_output_transaction tr);

    if (tr.alarm_active !== expected_alarm_active) begin

      `uvm_error("MOTION_CHECK",
        $sformatf(
          "FAIL: Expected alarm_active=%0b, Actual alarm_active=%0b",
          expected_alarm_active,
          tr.alarm_active
        ))

    end
    else begin

      `uvm_info("MOTION_CHECK",
        $sformatf(
          "PASS: Expected alarm_active=%0b, Actual alarm_active=%0b",
          expected_alarm_active,
          tr.alarm_active
        ),
        UVM_LOW)

    end

  endfunction

endclass