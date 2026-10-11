class keypad_driver extends uvm_driver #(keypad_seq_item);

  `uvm_component_utils(keypad_driver)

  virtual keypad_if vif;

  function new(string name = "keypad_driver",
               uvm_component parent = null);
    super.new(name, parent);
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

    keypad_seq_item req;

    // Initial keypad state
    vif.drv_cb.pin_valid <= 1'b0;
    vif.drv_cb.pin_code  <= '0;

    forever begin

      seq_item_port.get_next_item(req);

      // Drive PIN transaction
      @(vif.drv_cb);

      vif.drv_cb.pin_valid <= req.pin_valid;
      vif.drv_cb.pin_code  <= req.pin_code;

      // Hold transaction for one clock
      @(vif.drv_cb);

      // Return to idle
      vif.drv_cb.pin_valid <= 1'b0;
      vif.drv_cb.pin_code  <= '0;

      seq_item_port.item_done();

    end

  endtask

endclass