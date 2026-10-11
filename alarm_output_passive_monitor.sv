class alarm_output_transaction extends uvm_sequence_item;

  `uvm_object_utils(alarm_output_transaction)

  bit siren;
  bit strobe;
  bit alarm_active;

  function new(string name = "alarm_output_transaction");
    super.new(name);
  endfunction

endclass


class alarm_output_passive_monitor extends uvm_monitor;

  `uvm_component_utils(alarm_output_passive_monitor)

  virtual alarm_output_if vif;

  // Analysis port
  uvm_analysis_port #(alarm_output_transaction) analysis_port;

  bit prev_siren;
  bit prev_strobe;
  bit prev_alarm_active;


  function new(string name = "alarm_output_passive_monitor",
               uvm_component parent = null);

    super.new(name, parent);

    analysis_port = new("analysis_port", this);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual alarm_output_if)::get(
          this,
          "",
          "alarm_output_vif",
          vif))
      `uvm_fatal("NOVIF",
                 "alarm_output_vif not found")

  endfunction


  task run_phase(uvm_phase phase);

    alarm_output_transaction tr;

    prev_siren        = 1'b0;
    prev_strobe       = 1'b0;
    prev_alarm_active = 1'b0;

    forever begin

      @(vif.mon_cb);

      //==================================================
      // DEBUG: Print every sampled alarm output
      //==================================================

      `uvm_info("ALARM_DEBUG",
        $sformatf(
          "siren=%0b strobe=%0b alarm_active=%0b",
          vif.mon_cb.siren,
          vif.mon_cb.strobe,
          vif.mon_cb.alarm_active
        ),
        UVM_LOW)


      //==================================================
      // Report only when an alarm output changes
      //==================================================

      if ((vif.mon_cb.siren        != prev_siren) ||
          (vif.mon_cb.strobe       != prev_strobe) ||
          (vif.mon_cb.alarm_active != prev_alarm_active)) begin

        `uvm_info("ALARM_OUT",
          $sformatf(
            "Alarm output changed: siren=%0b, strobe=%0b, alarm_active=%0b",
            vif.mon_cb.siren,
            vif.mon_cb.strobe,
            vif.mon_cb.alarm_active
          ),
          UVM_LOW)


        //================================================
        // Create transaction
        //================================================

        tr = alarm_output_transaction::type_id::create("tr");

        tr.siren        = vif.mon_cb.siren;
        tr.strobe       = vif.mon_cb.strobe;
        tr.alarm_active = vif.mon_cb.alarm_active;


        //================================================
        // Send observation to checker
        //================================================

        analysis_port.write(tr);

      end


      //==================================================
      // Store current values
      //==================================================

      prev_siren        = vif.mon_cb.siren;
      prev_strobe       = vif.mon_cb.strobe;
      prev_alarm_active = vif.mon_cb.alarm_active;

    end

  endtask

endclass