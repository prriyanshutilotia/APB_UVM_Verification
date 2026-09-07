# APB UVM Verification Environment

A SystemVerilog/UVM verification environment for an APB slave with functional coverage, assertion-based verification, a scoreboard, and configurable wait-state/error behavior.

## Highlights

- UVM agent: sequencer, driver, monitor, and sequence items
- APB slave memory model (3-bit address and data by default)
- Random read/write traffic with WRITE_ONLY, READ_ONLY, MIXED, and write-read modes
- Configurable wait states derived from the request address
- Error response (`PSLVERR`) for address `3'b111`
- Scoreboard-based read-data checking
- Protocol assertions for APB setup, access, wait-state, and completion rules
- Functional coverage for address, read/write, data, errors, waits, and crosses
- **100% functional and assertion coverage achieved**

## Project Structure

| File | Purpose |
| --- | --- |
| `apb_tb_top.sv` | Testbench top: clock, reset, interface, DUT, and UVM test selection |
| `apb_interface.sv` | APB interface, clocking blocks, and modports |
| `apb_dut.sv` | APB slave/memory DUT with wait-state and error behavior |
| `apb_sequence_item.sv` | APB transaction fields and random constraints |
| `apb_sequence.sv` | Read/write traffic sequences |
| `apb_sequencer.sv` | UVM sequencer |
| `apb_driver.sv` | APB master-side protocol driver |
| `apb_monitor.sv` | Completed-transfer monitor and UVM covergroup |
| `apb_scoreboard.sv` | Reference-memory model and transaction checker |
| `apb_agent.sv` | UVM agent construction and connections |
| `apb_env.sv` | Environment construction and monitor-to-scoreboard connection |
| `apb_test.sv` | Base and derived UVM tests |
| `apb_assert_checker.sv` | APB protocol assertions |
| `apb_cov_collector.sv` | Bound functional coverage collector |
| `apb_bind_all.sv` | Binds assertions and coverage to the top-level testbench |
| `apb_top.svh` | Compilation include file |
| `run.do` | QuestaSim compilation and simulation script |

## APB Behavior Under Test

| Address | Wait states | Response |
| --- | ---: | --- |
| `0`, `4` | 0 | Normal access |
| `1`, `5` | 1 | Normal access |
| `2`, `6` | 2 | Normal access |
| `3` | 3 | Normal access |
| `7` | 3 | `PSLVERR = 1` (intentional error response) |

## Prerequisites

- QuestaSim/ModelSim with SystemVerilog and UVM support
- UVM library available to the simulator

## Run the Simulation

Update the source path in `run.do` if required, then run from the QuestaSim transcript:

```tcl
do run.do
```

To select a test, use one of these plusargs with the `vsim` command:

```tcl
# Mixed random reads and writes (recommended coverage run)
vsim -voptargs=+acc work.apb_tb_top +MIXED

# Only writes
vsim -voptargs=+acc work.apb_tb_top +WRITE_ONLY

# Only reads
vsim -voptargs=+acc work.apb_tb_top +READ_ONLY

# A write followed by a read in each iteration
vsim -voptargs=+acc work.apb_tb_top +WR_RD

run -all
```

## Coverage

The environment collects:

- Read and write transfers
- All addresses (`0` through `7`)
- Write/read data values
- Zero, one, two, and three-or-more wait states
- Successful and error transfers
- Address × read/write crosses
- Read/write × wait-state crosses
- Read/write × error crosses
- APB assertions covering phase transitions, stability during waits, and completion behavior

The final `+MIXED` regression achieved:

```text
Functional coverage : 100%
Assertion coverage  : 100%
Total coverage      : 100%
```

## Notes

- Address `7` is an expected error transaction; the scoreboard treats its `PSLVERR` response as a pass.
- The monitor waits for a new SETUP phase before collecting a transaction, preventing duplicate sampling of a completed transfer.
- The driver deasserts `PSEL` and `PENABLE` immediately after completion, satisfying the APB completion assertion.

