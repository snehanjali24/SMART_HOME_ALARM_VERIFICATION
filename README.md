# Smart Home Alarm Controller Verification using UVM

## Project Overview

The Smart Home Alarm Controller is a security system that monitors multiple sensor zones, handles keypad PIN authentication, detects alarm conditions, and allows register access through the AHB-Lite interface.

In this project, we used SystemVerilog and UVM 1.2 to verify the functionality of the alarm controller. The testbench applies different inputs to the DUT, monitors its responses, and checks whether the design behaves as expected.

## Objectives

- Verify sensor activation and alarm behavior.
- Test valid and invalid PIN entries.
- Check keypad lockout and recovery.
- Verify AHB register read and write operations.
- Test alarm priority and status registers.
- Identify functional issues through simulation.

## Tools and Technologies

- SystemVerilog
- UVM 1.2
- Synopsys VCS
- EDA Playground
- AHB-Lite protocol

## UVM Testbench Architecture

The testbench is divided into different components to make verification easier to manage and debug.

- **Sequences:** Generate sensor, keypad, and AHB transactions.
- **Sequencers:** Send sequence items to the drivers.
- **Drivers:** Apply stimulus to the DUT through interfaces.
- **Monitors:** Observe interface signals and collect transaction data.
- **Agents:** Organize the drivers, monitors, and sequencers.
- **Reference Model:** Maintains the expected behavior of the design.
- **Scoreboard and Checkers:** Compare the expected results with the observed DUT behavior.
- **Environment:** Connects the verification components.
- **Tests:** Run specific verification scenarios.
- **Testbench Top:** Connects the DUT, interfaces, and UVM environment.

## Verification Scenarios

### AHB Verification

- Register read and write operations.
- Register default-value and readback checks.
- Entry and exit delay configuration.
- VERSION register readback.
- Zone configuration and alarm-status checks.
- AHB error and protocol testing where implemented.

### Keypad Verification

- Valid PIN authentication.
- Invalid PIN handling.
- Multiple incorrect PIN attempts.
- Keypad lockout behavior.
- Reset and recovery checks.

### Sensor and Alarm Verification

- Sensor activation and deactivation.
- Sensor debounce and qualification.
- Alarm activation and latching.
- Multiple-zone testing.
- Alarm-priority verification.

## Bug Detection

During verification, simulation logs and DUT responses are analyzed to identify functional issues. The areas investigated include register behavior, keypad lockout, sensor debounce, and alarm-priority logic.

The actual result of each test is determined from its simulation log and the checks implemented in the testbench.



## My Contributions

- Developed sensor verification sequences and test cases using SystemVerilog and UVM.
- Worked on sensor reset, activation, debounce, and multi-zone verification.
- Developed motion qualification test scenarios to verify motion detection in `ARMED_STAY` and `ARMED_AWAY` security modes.
- Analyzed motion qualification simulation logs and waveforms to investigate alarm activation failures.
- Worked on sensor fault detection scenarios and reviewed the corresponding simulation results.
- Verified expected zone status against DUT responses using sensor checkers.
- Analyzed UVM logs and waveforms to identify functional mismatches and debug sensor-related issues.

AHB and keypad verification were also covered as part of the team's work, including register read/write operations, PIN authentication, keypad lockout, and recovery testing.

## Run the Project

The project can be accessed through EDA Playground.

**[Smart Home Alarm Controller on EDA Playground](https://www.edaplayground.com/x/vsjT)**

Open the project, select the required simulator and UVM settings, and run the testbench.

## Learning Outcomes

- Learned how to build and use a UVM testbench.
- Gained experience with sequences, drivers, monitors, and agents.
- Practiced AHB register-level verification.
- Used reference models and checkers to verify DUT behavior.
- Analyzed simulation logs to investigate functional failures.
- Gained practical experience with SystemVerilog-based verification.

## Project Details

- **Project:** Smart Home Alarm Controller Verification
- **Language:** SystemVerilog
- **Methodology:** UVM 1.2
- **Simulator:** Synopsys VCS
- **Platform:** EDA Playground
- **Protocol:** AHB-Lite
