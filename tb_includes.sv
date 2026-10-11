`include "uvm_macros.svh"

//==================================================
// Sensor
//==================================================
`include "sensor_seq_item.sv"
`include "sensor_sequencer.sv"
`include "sensor_driver.sv"
`include "sensor_monitor.sv"
`include "sensor_agent.sv"


//==================================================
// AHB
//==================================================
`include "ahb_seq_item.sv"
`include "ahb_read_sequence.sv"
`include "ahb_write_sequence.sv"
`include "ahb_sequencer.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"
`include "ahb_agent.sv"


//==================================================
// Keypad
//==================================================
`include "keypad_seq_item.sv"
`include "keypad_sequencer.sv"
`include "keypad_driver.sv"
`include "keypad_monitor.sv"
`include "keypad_agent.sv"


//==================================================
// Passive Monitors
//==================================================
`include "alarm_output_passive_monitor.sv"


//==================================================
// Reference Model
//==================================================
`include "alarm_reference_model.sv"


//==================================================
// Checking
//==================================================
`include "sensor_checker.sv"
`include "keypad_checker.sv"
`include "ahb_checker.sv"
`include "motion_checker.sv"

`include "scoreboard.sv"


//==================================================
// Environment
//==================================================
`include "alarm_env.sv"


//==================================================
// Sensor Sequences
//==================================================
`include "sensor_reset_sequence.sv"
`include "sensor_activation_sequence.sv"
`include "sensor_debounce_sequence.sv"
`include "sensor_toggle_fault_sequence.sv"
`include "sensor_multiple_sequence.sv"
`include "sensor_each_zone_sequence.sv"
`include "sensor_rapid_transition_sequence.sv"
`include "sensor_zone_sequence.sv"
`include "motion_sensor_sequence.sv"


//==================================================
// AHB Sequences
//==================================================
`include "ahb_zone_status_sequence.sv"
`include "ahb_status_sequence.sv"
`include "ahb_reset_sequence.sv"
`include "ahb_register_access_sequence.sv"
`include "ahb_read_write_sequence.sv"
`include "ahb_delay_config_sequence.sv"
`include "ahb_version_sequence.sv"
`include "ahb_zone_config_sequence.sv"
`include "motion_qualification_sequence.sv"

// Alarm priority sequence
`include "alarm_priority_sequence.sv"


//==================================================
// Keypad Sequences
//==================================================
`include "pin_valid_sequence.sv"
`include "pin_invalid_sequence.sv"
`include "pin_lockout_sequence.sv"
`include "pin_recovery_sequence.sv"


//==================================================
// Tests
//==================================================
`include "base_test.sv"


`include "sensor_reset_test.sv"
`include "sensor_basic_test.sv"
`include "sensor_debounce_test.sv"
`include "sensor_fault_test.sv"
`include "sensor_multi_zone_test.sv"

`include "keypad_reset_test.sv"
`include "pin_lockout_test.sv"
`include "pin_valid_test.sv"
`include "pin_invalid_test.sv"

`include "ahb_reset_test.sv"
`include "ahb_register_access_test.sv"
`include "ahb_read_write_test.sv"
`include "ahb_zone_config_test.sv"
`include "ahb_delay_config_test.sv"
`include "ahb_version_test.sv"
`include "motion_qualification_test.sv"

// Alarm priority test
`include "alarm_priority_test.sv"
