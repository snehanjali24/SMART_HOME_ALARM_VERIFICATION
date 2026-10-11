class keypad_monitor extends uvm_monitor;

  `uvm_component_utils(keypad_monitor)

  virtual keypad_if vif;

  uvm_analysis_port #(keypad_seq_item) analysis_port;

  function new(string name = "keypad_monitor",
               uvm_component parent = null);
    super.new(name, parent);

    analysis_port = new("analysis_port", this);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual keypad_if)::get(
          this,
          "",
          "keypad_vif",
          vif))
      `uvm_fatal("NOVIF",
        {"Virtual interface keypad_vif not set for ",
         get_full_name()})

  endfunction


  task run_phase(uvm_phase phase);

    keypad_seq_item item;

    forever begin

      @(vif.mon_cb);

      if (vif.mon_cb.pin_valid) begin

       item = keypad_seq_item#()::type_id::create("item");

        item.pin_valid = vif.mon_cb.pin_valid;
        item.pin_code  = vif.mon_cb.pin_code;

        `uvm_info("KEYPAD_MON",
          $sformatf(
            "Observed pin_valid=%0b pin_code=%0h",
            item.pin_valid,
            item.pin_code
          ),
          UVM_LOW)

        analysis_port.write(item);

      end

    end

  endtask

endclass