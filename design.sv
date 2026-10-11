//============================================================================
// alarm_pkg.sv  -  Shared types, register map and reset defaults
//============================================================================
// Waiver: package constants are consumed by different modules; not every
// module uses every constant.
/* verilator lint_off UNUSEDPARAM */
package alarm_pkg;

  //--------------------------------------------------------------------------
  // Zone types (register coding from spec section 7.6)
  //--------------------------------------------------------------------------
  typedef enum logic [2:0] {
    ZT_UNUSED    = 3'b000,
    ZT_ENTRY     = 3'b001,
    ZT_PERIMETER = 3'b010,
    ZT_MOTION    = 3'b011,
    ZT_FIRE      = 3'b100,
    ZT_PANIC     = 3'b101,
    ZT_RSVD6     = 3'b110,   // treated as UNUSED
    ZT_RSVD7     = 3'b111    // treated as UNUSED
  } zone_type_e;

  //--------------------------------------------------------------------------
  // Alarm FSM states (fits STATUS.SYSTEM_STATE[2:0])
  //--------------------------------------------------------------------------
  typedef enum logic [2:0] {
    ST_DISARMED    = 3'd0,
    ST_EXIT_DELAY  = 3'd1,
    ST_ARMED_STAY  = 3'd2,
    ST_ARMED_AWAY  = 3'd3,
    ST_ENTRY_DELAY = 3'd4,
    ST_ALARM       = 3'd5,
    ST_FAULT       = 3'd6,
    ST_RSVD7       = 3'd7
  } alarm_state_e;

  //--------------------------------------------------------------------------
  // Alarm reasons.  Numeric value == priority (higher wins):
  //   FIRE > PANIC > PERIMETER > MOTION > ENTRY_TIMEOUT
  //--------------------------------------------------------------------------
  typedef enum logic [2:0] {
    AR_NONE          = 3'd0,
    AR_ENTRY_TIMEOUT = 3'd1,
    AR_MOTION        = 3'd2,
    AR_PERIMETER     = 3'd3,
    AR_PANIC         = 3'd4,
    AR_FIRE          = 3'd5,
    AR_RSVD6         = 3'd6,
    AR_RSVD7         = 3'd7
  } alarm_reason_e;

  //--------------------------------------------------------------------------
  // Event log types
  //--------------------------------------------------------------------------
  typedef enum logic [3:0] {
    EV_NONE           = 4'd0,
    EV_ARM_STAY       = 4'd1,
    EV_ARM_AWAY       = 4'd2,
    EV_DISARM         = 4'd3,
    EV_INTRUSION      = 4'd4,   // perimeter / motion / entry-timeout alarm
    EV_FIRE           = 4'd5,
    EV_PANIC          = 4'd6,
    EV_INVALID_PIN    = 4'd7,
    EV_SENSOR_FAULT   = 4'd8,
    EV_ALARM_CLEAR    = 4'd9,
    EV_KEYPAD_LOCKOUT = 4'd10,
    EV_ENTRY_DELAY    = 4'd11
  } event_type_e;

  // Event word layout (32 bit; truncated / zero-extended to EVENT_WIDTH)
  //   [3:0]   event type          [11:4]  zone id (0xFF = none)
  //   [14:12] system state        [17:15] alarm reason
  //   [31:18] timestamp (14-bit count of timebase ticks)
  localparam logic [7:0] EV_NO_ZONE = 8'hFF;

  //--------------------------------------------------------------------------
  // Register map (byte offsets, 4 KB window)
  //--------------------------------------------------------------------------
  localparam logic [11:0] ADDR_CONTROL        = 12'h000;
  localparam logic [11:0] ADDR_STATUS         = 12'h004;
  localparam logic [11:0] ADDR_ENTRY_DELAY    = 12'h008;
  localparam logic [11:0] ADDR_EXIT_DELAY     = 12'h00C;
  localparam logic [11:0] ADDR_ALARM_DURATION = 12'h010;
  localparam logic [11:0] ADDR_PIN_CONFIG     = 12'h014;
  localparam logic [11:0] ADDR_ZONE_ENABLE    = 12'h018;  // word 0
  localparam logic [11:0] ADDR_ZONE_BYPASS    = 12'h01C;  // word 0
  localparam logic [11:0] ADDR_ZONE_STATUS    = 12'h020;  // word 0
  localparam logic [11:0] ADDR_ZONE_FAULT     = 12'h024;  // word 0
  localparam logic [11:0] ADDR_ALARM_STATUS   = 12'h028;
  localparam logic [11:0] ADDR_EVENT_STATUS   = 12'h02C;
  localparam logic [11:0] ADDR_EVENT_DATA     = 12'h030;
  localparam logic [11:0] ADDR_IRQ_STATUS     = 12'h034;
  localparam logic [11:0] ADDR_IRQ_ENABLE     = 12'h038;
  localparam logic [11:0] ADDR_VERSION        = 12'h03C;
  localparam logic [11:0] ADDR_LOCKOUT_DELAY  = 12'h040;  // added: keypad lockout
  // Extension banks: word k (k >= 1) lives at BASE + 4*k  (zones 32..)
  localparam logic [11:0] ADDR_ZEN_EXT        = 12'h100;
  localparam logic [11:0] ADDR_ZBY_EXT        = 12'h140;
  localparam logic [11:0] ADDR_ZST_EXT        = 12'h180;
  localparam logic [11:0] ADDR_ZFLT_EXT       = 12'h1C0;
  // Zone type registers: 8 zones per word, 4-bit field per zone (bit3 = RAZ/WI)
  localparam logic [11:0] ADDR_ZONE_TYPE      = 12'h200;

  // CONTROL bit positions
  localparam int CTRL_ARM_STAY    = 0;
  localparam int CTRL_ARM_AWAY    = 1;
  localparam int CTRL_DISARM      = 2;
  localparam int CTRL_CLEAR_ALARM = 3;
  localparam int CTRL_CLEAR_FAULT = 4;

  // IRQ bit positions
  localparam int IRQ_ALARM   = 0;
  localparam int IRQ_FIRE    = 1;
  localparam int IRQ_PANIC   = 2;
  localparam int IRQ_EVENT   = 3;
  localparam int IRQ_FAULT   = 4;
  localparam int IRQ_LOCKOUT = 5;
  localparam int IRQ_NUM     = 6;

  //--------------------------------------------------------------------------
  // Reset defaults of the programmable configuration.
  // Units are timebase ticks (TICK_DIV sys_clk cycles per tick).
  //--------------------------------------------------------------------------
  localparam int DEF_ENTRY_DELAY = 30;
  localparam int DEF_EXIT_DELAY  = 30;
  localparam int DEF_ALARM_DUR   = 180;
  localparam int DEF_LOCKOUT     = 60;
  localparam int DEF_PIN         = 32'h0000_1234;

  localparam logic [7:0] VERSION_MAJOR = 8'd1;
  localparam logic [7:0] VERSION_MINOR = 8'd0;

endpackage

//============================================================================
// reset_sync.sv  -  Reset synchronizer: asynchronous assertion,
//                   synchronous de-assertion (active-low).
//============================================================================
module reset_sync #(
  parameter int STAGES = 2
)(
  input  logic clk,
  input  logic arst_n,      // asynchronous reset in
  output logic rst_n        // domain reset out
);

  if (STAGES < 2) begin : g_stage_check
    $error("reset_sync: STAGES (%0d) must be >= 2", STAGES);
  end

  (* ASYNC_REG = "TRUE" *) logic [STAGES-1:0] ff;

  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) ff <= '0;
    else         ff <= {ff[STAGES-2:0], 1'b1};
  end

  assign rst_n = ff[STAGES-1];

endmodule
//============================================================================
// sync_ff.sv  -  Multi-flop synchronizer for PERSISTENT single-bit signals.
//   * STAGES >= 2 is enforced (a single flop is prohibited by the spec).
//   * WIDTH > 1 is allowed ONLY for bits that are individually independent
//     (never for a coherent bus).
//============================================================================
module sync_ff #(
  parameter int              STAGES    = 2,
  parameter int              WIDTH     = 1,
  parameter logic [WIDTH-1:0] RESET_VAL = '0
)(
  input  logic             clk,
  input  logic             rst_n,
  input  logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);

  if (STAGES < 2) begin : g_stage_check
    $error("sync_ff: STAGES (%0d) must be >= 2", STAGES);
  end

  (* ASYNC_REG = "TRUE" *) logic [STAGES-1:0][WIDTH-1:0] chain;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      chain <= {STAGES{RESET_VAL}};
    end else begin
      chain <= {chain[STAGES-2:0], d};
    end
  end

  assign q = chain[STAGES-1];

endmodule

//============================================================================
// req_ack_cdc.sv  -  Coherent multi-bit CDC using a 4-phase REQ/ACK handshake.
//
//  src : when src_ready && src_valid the data is captured into a HOLD register
//        that stays stable until the handshake completes; REQ is raised.
//  dst : REQ is synchronised; when seen (and ACK low) HOLD is captured into
//        dst_data, dst_valid pulses for one dst_clk, and ACK is raised.
//        ACK is synchronised back; REQ drops; ACK drops; link returns idle.
//
//  The handshake is level based, so a reset of either side in the middle of
//  a transfer recovers without dead-lock (see README, RDC section).
//============================================================================
module req_ack_cdc #(
  parameter int               WIDTH           = 8,
  parameter int               SYNC_STAGES     = 2,
  parameter logic [WIDTH-1:0] DST_RESET_VALUE = '0
)(
  // source domain
  input  logic             src_clk,
  input  logic             src_rst_n,
  input  logic             src_valid,
  output logic             src_ready,
  input  logic [WIDTH-1:0] src_data,
  // destination domain
  input  logic             dst_clk,
  input  logic             dst_rst_n,
  output logic             dst_valid,   // 1-cycle pulse: new data in dst_data
  output logic [WIDTH-1:0] dst_data     // holds last received value
);

  typedef enum logic [1:0] {S_IDLE, S_WAIT_ACK, S_WAIT_IDLE} src_state_e;
  src_state_e         sstate;
  logic               req, ack_sync;
  logic [WIDTH-1:0]   hold;

  always_ff @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
      sstate <= S_IDLE;
      req    <= 1'b0;
      hold   <= '0;
    end else begin
      case (sstate)
        S_IDLE: if (src_valid) begin
          hold   <= src_data;
          req    <= 1'b1;
          sstate <= S_WAIT_ACK;
        end
        S_WAIT_ACK: if (ack_sync) begin
          req    <= 1'b0;
          sstate <= S_WAIT_IDLE;
        end
        S_WAIT_IDLE: if (!ack_sync) sstate <= S_IDLE;
        default: sstate <= S_IDLE;
      endcase
    end
  end

  assign src_ready = (sstate == S_IDLE);

  // ---------------- destination ----------------
  logic req_sync, ack;

  sync_ff #(.STAGES(SYNC_STAGES)) u_req_sync (
    .clk(dst_clk), .rst_n(dst_rst_n), .d(req), .q(req_sync)
  );

  always_ff @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
      ack       <= 1'b0;
      dst_valid <= 1'b0;
      dst_data  <= DST_RESET_VALUE;
    end else begin
      dst_valid <= 1'b0;
      if (req_sync && !ack) begin
        dst_data  <= hold;          // HOLD is stable while REQ is high
        dst_valid <= 1'b1;
        ack       <= 1'b1;
      end else if (!req_sync && ack) begin
        ack <= 1'b0;
      end
    end
  end

  sync_ff #(.STAGES(SYNC_STAGES)) u_ack_sync (
    .clk(src_clk), .rst_n(src_rst_n), .d(ack), .q(ack_sync)
  );

endmodule

//============================================================================
// async_fifo.sv  -  Dual-clock FIFO (Gray-coded pointers, Cummings style)
//   * Binary pointers used locally, Gray pointers cross the domains.
//   * DEPTH must be a power of two (>= 2).
//   * rdata is the head entry (first-word-fall-through); valid when !rempty.
//   * rcount is a conservative read-side occupancy (lags the write pointer).
//============================================================================
module async_fifo #(
  parameter int WIDTH       = 32,
  parameter int DEPTH       = 8,
  parameter int SYNC_STAGES = 2,
  localparam int ADDR_W     = $clog2(DEPTH),
  localparam int PTR_W      = ADDR_W + 1
)(
  // write side
  input  logic             wclk,
  input  logic             wrst_n,
  input  logic             winc,
  input  logic [WIDTH-1:0] wdata,
  output logic             wfull,
  output logic             woverflow,    // pulse: write attempted while full
  // read side
  input  logic             rclk,
  input  logic             rrst_n,
  input  logic             rinc,
  output logic [WIDTH-1:0] rdata,
  output logic             rempty,
  output logic             runderflow,   // pulse: read attempted while empty
  output logic [PTR_W-1:0] rcount
);

  if (DEPTH < 2 || (DEPTH & (DEPTH - 1)) != 0) begin : g_depth_check
    $error("async_fifo: DEPTH (%0d) must be a power of two >= 2", DEPTH);
  end

  localparam logic [PTR_W-1:0] FULL_MASK = PTR_W'(3) << (PTR_W - 2);

  logic [WIDTH-1:0] mem [DEPTH];

  logic [PTR_W-1:0] wbin, wgray, wbin_n, wgray_n;
  logic [PTR_W-1:0] rbin, rgray, rbin_n, rgray_n;
  logic [PTR_W-1:0] rgray_wsync;   // read pointer in write domain
  logic [PTR_W-1:0] wgray_rsync;   // write pointer in read domain

  // ---------------- write domain ----------------
  logic do_write;
  assign do_write = winc & ~wfull;
  assign wbin_n   = wbin + PTR_W'(do_write);
  assign wgray_n  = (wbin_n >> 1) ^ wbin_n;

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      wbin      <= '0;
      wgray     <= '0;
      wfull     <= 1'b0;
      woverflow <= 1'b0;
    end else begin
      wbin      <= wbin_n;
      wgray     <= wgray_n;
      wfull     <= (wgray_n == rgray_wsync);  // injected bug #4
      woverflow <= winc & wfull;
    end
  end

  always_ff @(posedge wclk) begin
    if (do_write) mem[wbin[ADDR_W-1:0]] <= wdata;
  end

  sync_ff #(.STAGES(SYNC_STAGES), .WIDTH(PTR_W)) u_rptr_sync (
    .clk(wclk), .rst_n(wrst_n), .d(rgray), .q(rgray_wsync)
  );

  // ---------------- read domain ----------------
  logic do_read;
  assign do_read = rinc & ~rempty;
  assign rbin_n  = rbin + PTR_W'(do_read);
  assign rgray_n = (rbin_n >> 1) ^ rbin_n;

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      rbin       <= '0;
      rgray      <= '0;
      rempty     <= 1'b1;
      runderflow <= 1'b0;
    end else begin
      rbin       <= rbin_n;
      rgray      <= rgray_n;
      rempty     <= (rgray_n == wgray_rsync);
      runderflow <= rinc & rempty;
    end
  end

  assign rdata = mem[rbin[ADDR_W-1:0]];

  sync_ff #(.STAGES(SYNC_STAGES), .WIDTH(PTR_W)) u_wptr_sync (
    .clk(rclk), .rst_n(rrst_n), .d(wgray), .q(wgray_rsync)
  );

  // Gray -> binary of the synchronised write pointer, then occupancy
  logic [PTR_W-1:0] wbin_rsync;
  always_comb begin
    wbin_rsync[PTR_W-1] = wgray_rsync[PTR_W-1];
    for (int i = PTR_W-2; i >= 0; i--) begin
      wbin_rsync[i] = wbin_rsync[i+1] ^ wgray_rsync[i];
    end
  end
  assign rcount = wbin_rsync - rbin;

endmodule

//============================================================================
// event_fifo_reader.sv  -  HCLK-side view of the event FIFO
//   * EVENT_DATA read pops the oldest event (never pops when empty)
//   * EVENT_STATUS: [0] EMPTY [1] FULL [2] OVERFLOW(sticky) [3] AVAILABLE
//                   [15:8] COUNT
//   * FULL is a read-side estimate (rcount lags the true write pointer)
//   * OVERFLOW is set by a pulse from the write side, cleared via clr_ovf
//============================================================================
module event_fifo_reader #(
  parameter int EVENT_WIDTH = 32,
  parameter int FIFO_DEPTH  = 8,
  parameter int PTR_W       = $clog2(FIFO_DEPTH) + 1
)(
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic                   rempty,
  input  logic [PTR_W-1:0]       rcount,
  input  logic [EVENT_WIDTH-1:0] rdata,
  input  logic                   pop,         // EVENT_DATA read completed
  input  logic                   ovf_pulse,   // from write side (HCLK domain)
  input  logic                   clr_ovf,
  output logic                   rinc,
  output logic                   avail_rise,  // FIFO went empty -> non-empty
  output logic [31:0]            event_status,
  output logic [31:0]            event_data
);

  logic ovf_q, avail_q;

  assign rinc = pop & ~rempty;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ovf_q   <= 1'b0;
      avail_q <= 1'b0;
    end else begin
      avail_q <= ~rempty;
      if (ovf_pulse)     ovf_q <= 1'b1;
      else if (clr_ovf)  ovf_q <= 1'b0;
    end
  end

  assign avail_rise = ~rempty & ~avail_q;

  logic [31:0] count32;
  logic [7:0]  count8;
  assign count32 = 32'(rcount);
  assign count8  = (count32 > 32'd255) ? 8'hFF : count32[7:0];

  logic full_est;
  assign full_est = (rcount == PTR_W'(FIFO_DEPTH));

  assign event_status = {16'h0, count8, 4'h0, ~rempty, ovf_q, full_est, rempty};
  assign event_data   = rempty ? 32'h0 : 32'(rdata);

endmodule
//============================================================================
// sensor_front_end.sv  -  All sensor channels + sensor_clk -> sys_clk CDC
//   per zone:
//     level      : debounced level        -> 2+ FF synchroniser   (persistent)
//     rise event : 1-cycle pulse          -> toggle pulse sync    (event)
//     fault event: excessive toggling     -> toggle pulse sync    (event)
//   The NUM_ZONES level bits are independent signals (not a coherent bus),
//   so per-bit synchronisation is legal.
//============================================================================
module sensor_front_end #(
  parameter int NUM_ZONES       = 8,
  parameter int SYNC_STAGES     = 2,
  parameter int DEBOUNCE_CYCLES = 4,
  parameter int TOGGLE_LIMIT    = 8,
  parameter int TOGGLE_WINDOW   = 1024
)(
  input  logic                  sensor_clk,
  input  logic                  sensor_rst_n,
  input  logic [NUM_ZONES-1:0]  sensor_in,

  input  logic                  sys_clk,
  input  logic                  sys_rst_n,
  output logic [NUM_ZONES-1:0]  zone_level,     // sys_clk domain
  output logic [NUM_ZONES-1:0]  zone_event,     // sys_clk domain, pulses
  output logic [NUM_ZONES-1:0]  zone_tfault     // sys_clk domain, pulses
);

  for (genvar i = 0; i < NUM_ZONES; i++) begin : g_zone
    logic lvl_s, rise_s, tfault_s;

    sensor_channel #(
      .SYNC_STAGES    (SYNC_STAGES),
      .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES),
      .TOGGLE_LIMIT   (TOGGLE_LIMIT),
      .TOGGLE_WINDOW  (TOGGLE_WINDOW)
    ) u_ch (
      .clk               (sensor_clk),
      .rst_n             (sensor_rst_n),
      .sensor_in         (sensor_in[i]),
      .level             (lvl_s),
      .rise_pulse        (rise_s),
      .toggle_fault_pulse(tfault_s)
    );

    sync_ff #(.STAGES(SYNC_STAGES)) u_lvl_cdc (
      .clk(sys_clk), .rst_n(sys_rst_n), .d(lvl_s), .q(zone_level[i])
    );

    toggle_pulse_sync #(.SYNC_STAGES(SYNC_STAGES)) u_evt_cdc (
      .src_clk(sensor_clk), .src_rst_n(sensor_rst_n), .src_pulse(rise_s),
      .dst_clk(sys_clk),    .dst_rst_n(sys_rst_n),    .dst_pulse(zone_event[i])
    );

    toggle_pulse_sync #(.SYNC_STAGES(SYNC_STAGES)) u_flt_cdc (
      .src_clk(sensor_clk), .src_rst_n(sensor_rst_n), .src_pulse(tfault_s),
      .dst_clk(sys_clk),    .dst_rst_n(sys_rst_n),    .dst_pulse(zone_tfault[i])
    );
  end

endmodule

//============================================================================
// ahb_lite_slave.sv  -  AHB-Lite slave protocol engine (HCLK domain)
//
//   * address-phase capture, data-phase execution (correct pipelining: the
//     HWDATA seen in a data phase belongs to the address/control captured in
//     the preceding address phase)
//   * 32-bit, word-aligned NONSEQ (SEQ treated identically) transfers
//   * wait states (HREADYOUT low) requested by the register block
//   * two-cycle ERROR response for: wrong HSIZE, misaligned address,
//     unmapped address, write to a read-only register
//   Register-side handshake:
//     acc_valid  : a legal-format access is in its data phase
//     acc_ready  : register block can complete this cycle (else wait state)
//     acc_err    : register block rejects the access
//     acc_commit : access completes OK this cycle -> perform side effects
//============================================================================
module ahb_lite_slave (
  input  logic        HCLK,
  input  logic        HRESETn,
  input  logic        HSEL,
  input  logic [31:0] HADDR,
  input  logic [1:0]  HTRANS,
  input  logic        HWRITE,
  input  logic [2:0]  HSIZE,
  input  logic [31:0] HWDATA,
  input  logic        HREADY,
  output logic [31:0] HRDATA,
  output logic        HREADYOUT,
  output logic        HRESP,

  output logic        acc_valid,
  output logic        acc_write,
  output logic [11:0] acc_addr,
  output logic [31:0] acc_wdata,
  output logic        acc_commit,
  input  logic        acc_ready,
  input  logic        acc_err,
  input  logic [31:0] acc_rdata
);

  logic        dp_valid_q, dp_write_q, err_q;
  logic [11:0] dp_addr_q;
  logic [2:0]  dp_size_q;

  logic        addr_phase, fmt_bad, bad, err_first;

  // HADDR[31:12] are decoded by the interconnect (HSEL)
  // HTRANS[0] (BUSY vs IDLE / SEQ vs NONSEQ) is not needed: every transfer
  // is treated as an independent single access.
  logic [20:0] unused_bits;
  assign unused_bits = {HADDR[31:12], HTRANS[0]};

  assign addr_phase = HSEL & HREADY & HTRANS[1];

  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      dp_valid_q <= 1'b0;
      dp_write_q <= 1'b0;
      dp_addr_q  <= '0;
      dp_size_q  <= '0;
      err_q      <= 1'b0;
    end else begin
      // injected bug #8: capture no longer gated by HREADY, so a new
      // address phase overwrites the pipeline register even while this
      // slave is still stalling (HREADYOUT low) the current access.
      dp_valid_q <= addr_phase;
      dp_write_q <= HWRITE;
      dp_addr_q  <= HADDR[11:0];
      dp_size_q  <= HSIZE;
      err_q <= err_first;
    end
  end

  assign fmt_bad   = (dp_size_q != 3'b010) | (dp_addr_q[1:0] != 2'b00);
  assign acc_valid = dp_valid_q & ~fmt_bad & ~err_q;
  assign acc_write = dp_write_q;
  assign acc_addr  = dp_addr_q;
  assign acc_wdata = HWDATA;

  assign bad       = fmt_bad | acc_err;
  assign err_first = dp_valid_q & ~err_q & bad;

  assign acc_commit = acc_valid & ~acc_err & acc_ready;

  always_comb begin
    HREADYOUT = 1'b1;
    HRESP     = 1'b0;
    if (err_q) begin
      HREADYOUT = 1'b1;  HRESP = 1'b1;      // 2nd cycle of ERROR
    end else if (dp_valid_q && bad) begin
      HREADYOUT = 1'b0;  HRESP = 1'b1;      // 1st cycle of ERROR
    end else if (dp_valid_q && !acc_ready) begin
      HREADYOUT = 1'b0;                     // wait state
    end
  end

  assign HRDATA = (acc_valid && !dp_write_q) ? acc_rdata : 32'h0;

endmodule

//============================================================================
// alarm_regs.sv  -  Software-visible register block (HCLK domain)
//   Registers are decoded from the simple access interface driven by
//   ahb_lite_slave.  Configuration registers live here; the config is pushed
//   to sys_clk by the top level (REQ/ACK).  Commands (CONTROL, ZONE_FAULT
//   RW1C) are issued through a second REQ/ACK channel; a write to those
//   registers is stalled with wait states while that channel is busy.
//
//   Zone-indexed registers use  NUM_ZONE_REGS = (NUM_ZONES+31)/32  words:
//     word 0 at the map address, words k>=1 at <EXT_BASE> + 4*k.
//   ZONE_TYPE: 8 zones / word, 4-bit field per zone ([2:0] type, [3] RAZ/WI).
//============================================================================
module alarm_regs
  import alarm_pkg::*;
#(
  parameter int NUM_ZONES   = 8,
  parameter int PIN_WIDTH   = 16,
  parameter int TIMER_WIDTH = 24
)(
  input  logic                    HCLK,
  input  logic                    HRESETn,

  // access interface (from ahb_lite_slave)
  input  logic                    acc_valid,
  input  logic                    acc_write,
  input  logic [11:0]             acc_addr,
  input  logic [31:0]             acc_wdata,
  input  logic                    acc_commit,
  output logic                    acc_ready,
  output logic                    acc_err,
  output logic [31:0]             acc_rdata,

  // configuration (HCLK domain)
  output logic [TIMER_WIDTH-1:0]  cfg_entry,
  output logic [TIMER_WIDTH-1:0]  cfg_exit,
  output logic [TIMER_WIDTH-1:0]  cfg_alarm,
  output logic [TIMER_WIDTH-1:0]  cfg_lockout,
  output logic [PIN_WIDTH-1:0]    cfg_pin,
  output logic [NUM_ZONES-1:0]    cfg_enable,
  output logic [NUM_ZONES-1:0]    cfg_bypass,
  output logic [3*NUM_ZONES-1:0]  cfg_type,
  output logic                    cfg_wr,          // pulse: config register written

  // command channel
  output logic                    cmd_req,
  output logic [4:0]              cmd_bits,
  output logic [NUM_ZONES-1:0]    cmd_fault_clr,
  input  logic                    cmd_ready,

  // status snapshot (HCLK domain)
  input  alarm_state_e            st_state,
  input  logic                    st_alarm_active,
  input  logic                    st_entry_active,
  input  logic                    st_exit_active,
  input  logic                    st_locked,
  input  logic                    st_siren,
  input  logic                    st_cfg_busy,
  input  alarm_reason_e           st_reason,
  input  logic [7:0]              st_zone,
  input  logic [NUM_ZONES-1:0]    st_zone_level,
  input  logic [NUM_ZONES-1:0]    st_zone_fault,

  // event FIFO reader
  input  logic [31:0]             evt_status,
  input  logic [31:0]             evt_data,
  output logic                    evt_pop,
  output logic                    clr_ovf,

  // interrupt controller
  input  logic [IRQ_NUM-1:0]      irq_status,
  input  logic [IRQ_NUM-1:0]      irq_enable,
  output logic                    irq_w1c_en,
  output logic [IRQ_NUM-1:0]      irq_w1c_data,
  output logic                    irq_enable_wr,
  output logic [IRQ_NUM-1:0]      irq_enable_data
);

  localparam int NUM_ZONE_REGS = (NUM_ZONES + 31) / 32;
  localparam int NUM_TYPE_REGS = (NUM_ZONES + 7)  / 8;

  //--------------------------------------------------------------------------
  // storage
  //--------------------------------------------------------------------------
  logic [TIMER_WIDTH-1:0] entry_q, exit_q, alarm_q, lockout_q;
  logic [PIN_WIDTH-1:0]   pin_q;
  logic [NUM_ZONES-1:0]   enable_q, bypass_q;
  logic [3*NUM_ZONES-1:0] type_q;

  assign cfg_entry   = entry_q;
  assign cfg_exit    = exit_q;
  assign cfg_alarm   = alarm_q;
  assign cfg_lockout = lockout_q;
  assign cfg_pin     = pin_q;
  assign cfg_enable  = enable_q;
  assign cfg_bypass  = bypass_q;
  assign cfg_type    = type_q;

  //--------------------------------------------------------------------------
  // address decode
  //--------------------------------------------------------------------------
  function automatic int bank_idx(input logic [11:0] a, input logic [11:0] w0,
                                  input logic [11:0] ext, input int nwords);
    int off;
    bank_idx = -1;
    if (a == w0) begin
      bank_idx = 0;
    end else begin
      off = int'(a) - int'(ext);
      if (off >= 4 && off < 4*nwords && off < 64) bank_idx = off >> 2;
    end
  endfunction

  int en_i, by_i, zs_i, zf_i, zt_i;
  logic hit_rw, hit_ro;

  always_comb begin
    int zt_off;
    en_i = bank_idx(acc_addr, ADDR_ZONE_ENABLE, ADDR_ZEN_EXT,  NUM_ZONE_REGS);
    by_i = bank_idx(acc_addr, ADDR_ZONE_BYPASS, ADDR_ZBY_EXT,  NUM_ZONE_REGS);
    zs_i = bank_idx(acc_addr, ADDR_ZONE_STATUS, ADDR_ZST_EXT,  NUM_ZONE_REGS);
    zf_i = bank_idx(acc_addr, ADDR_ZONE_FAULT,  ADDR_ZFLT_EXT, NUM_ZONE_REGS);
    zt_off = int'(acc_addr) - int'(ADDR_ZONE_TYPE);
    zt_i   = (zt_off >= 0 && zt_off < 4*NUM_TYPE_REGS) ? (zt_off >> 2) : -1;

    hit_rw = 1'b0;
    hit_ro = 1'b0;
    case (acc_addr)
      ADDR_CONTROL, ADDR_ENTRY_DELAY, ADDR_EXIT_DELAY, ADDR_ALARM_DURATION,
      ADDR_PIN_CONFIG, ADDR_IRQ_STATUS, ADDR_IRQ_ENABLE, ADDR_LOCKOUT_DELAY:
        hit_rw = 1'b1;
      ADDR_STATUS, ADDR_ALARM_STATUS, ADDR_EVENT_STATUS, ADDR_EVENT_DATA, ADDR_VERSION:
        hit_ro = 1'b1;
      default: ;
    endcase
    if (en_i >= 0 || by_i >= 0 || zf_i >= 0 || zt_i >= 0) hit_rw = 1'b1;
    if (zs_i >= 0) hit_ro = 1'b1;
  end

  // unmapped, or write to a read-only register -> ERROR response
  assign acc_err = acc_valid & ~(hit_rw | (hit_ro & ~acc_write));

  // CONTROL / ZONE_FAULT writes need the command channel -> wait state if busy
  assign acc_ready = 1'b1;  // injected bug #9: ignores cmd_ready, so a second
  // CONTROL/ZONE_FAULT write can be accepted (and silently dropped) while the
  // previous command is still crossing to sys_clk.

  //--------------------------------------------------------------------------
  // helpers
  //--------------------------------------------------------------------------
  function automatic logic [31:0] vec_word(input logic [NUM_ZONES-1:0] v, input int k);
    logic [31:0] w;
    w = '0;
    for (int b = 0; b < 32; b++) if (32*k + b < NUM_ZONES) w[b] = v[32*k + b];
    return w;
  endfunction

  function automatic logic [31:0] type_word(input logic [3*NUM_ZONES-1:0] t, input int k);
    logic [31:0] w;
    w = '0;
    for (int z = 0; z < 8; z++) if (8*k + z < NUM_ZONES) w[4*z +: 3] = t[3*(8*k + z) +: 3];
    return w;
  endfunction

  //--------------------------------------------------------------------------
  // register writes
  //--------------------------------------------------------------------------
  logic wr;
  assign wr = acc_commit & acc_write;

  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      entry_q   <= TIMER_WIDTH'(DEF_ENTRY_DELAY);
      exit_q    <= TIMER_WIDTH'(DEF_EXIT_DELAY);
      alarm_q   <= TIMER_WIDTH'(DEF_ALARM_DUR);
      lockout_q <= TIMER_WIDTH'(DEF_LOCKOUT);
      pin_q     <= PIN_WIDTH'(DEF_PIN);
      enable_q  <= '0;
      bypass_q  <= '0;
      type_q    <= '0;
    end else if (wr) begin
      case (acc_addr)
        ADDR_ENTRY_DELAY:    exit_q    <= acc_wdata[TIMER_WIDTH-1:0];  // injected bug #2
        ADDR_EXIT_DELAY:     entry_q   <= acc_wdata[TIMER_WIDTH-1:0];  // injected bug #2
        ADDR_ALARM_DURATION: alarm_q   <= acc_wdata[TIMER_WIDTH-1:0];
        ADDR_LOCKOUT_DELAY:  lockout_q <= acc_wdata[TIMER_WIDTH-1:0];
        ADDR_PIN_CONFIG:     pin_q     <= acc_wdata[PIN_WIDTH-1:0];
        default: ;
      endcase
      if (en_i >= 0)
        for (int b = 0; b < 32; b++)
          if (32*en_i + b < NUM_ZONES) enable_q[32*en_i + b] <= acc_wdata[b];
      if (by_i >= 0)
        for (int b = 0; b < 32; b++)
          if (32*by_i + b < NUM_ZONES) bypass_q[32*by_i + b] <= acc_wdata[b];
      if (zt_i >= 0)
        for (int z = 0; z < 8; z++)
          if (8*zt_i + z < NUM_ZONES) type_q[3*(8*zt_i + z) +: 3] <= acc_wdata[4*z +: 3];
    end
  end

  assign cfg_wr = wr & ( (acc_addr == ADDR_ENTRY_DELAY) | (acc_addr == ADDR_EXIT_DELAY)
                       | (acc_addr == ADDR_ALARM_DURATION) | (acc_addr == ADDR_LOCKOUT_DELAY)
                       | (acc_addr == ADDR_PIN_CONFIG)
                       | (en_i >= 0) | (by_i >= 0) | (zt_i >= 0) );

  //--------------------------------------------------------------------------
  // command channel (CONTROL and ZONE_FAULT RW1C)
  //--------------------------------------------------------------------------
  logic ctrl_wr, zf_wr;
  assign ctrl_wr = wr & (acc_addr == ADDR_CONTROL);
  assign zf_wr   = wr & (zf_i >= 0);

  always_comb begin
    cmd_bits      = ctrl_wr ? acc_wdata[4:0] : 5'b0;
    cmd_fault_clr = '0;
    if (zf_wr)
      for (int b = 0; b < 32; b++)
        if (32*zf_i + b < NUM_ZONES) cmd_fault_clr[32*zf_i + b] = acc_wdata[b];
    cmd_req = (|cmd_bits) | (|cmd_fault_clr);
  end

  // CLEAR_FAULT also clears the sticky FIFO-overflow flag (HCLK-local)
  assign clr_ovf = ctrl_wr & acc_wdata[CTRL_CLEAR_FAULT];

  //--------------------------------------------------------------------------
  // event FIFO / interrupt access
  //--------------------------------------------------------------------------
  assign evt_pop         = acc_commit & ~acc_write & (acc_addr == ADDR_EVENT_DATA);
  assign irq_w1c_en      = wr & (acc_addr == ADDR_IRQ_STATUS);
  assign irq_w1c_data    = acc_wdata[IRQ_NUM-1:0];
  assign irq_enable_wr   = wr & (acc_addr == ADDR_IRQ_ENABLE);
  assign irq_enable_data = acc_wdata[IRQ_NUM-1:0];

  //--------------------------------------------------------------------------
  // read mux
  //--------------------------------------------------------------------------
  logic sys_fault;
  assign sys_fault = (st_state == ST_FAULT) | (|st_zone_fault);

  always_comb begin
    acc_rdata = 32'h0;
    case (acc_addr)
      ADDR_CONTROL:        acc_rdata = 32'h0;     // command bits self-clear
      ADDR_STATUS:         acc_rdata = {23'h0, st_cfg_busy, sys_fault, st_locked,
                                        st_exit_active, st_entry_active,
                                        st_alarm_active, 3'(st_state)};
      ADDR_ENTRY_DELAY:    acc_rdata = 32'(entry_q);
      ADDR_EXIT_DELAY:     acc_rdata = 32'(exit_q);
      ADDR_ALARM_DURATION: acc_rdata = 32'(alarm_q);
      ADDR_LOCKOUT_DELAY:  acc_rdata = 32'(lockout_q);
      ADDR_PIN_CONFIG:     acc_rdata = 32'(pin_q);
      ADDR_ALARM_STATUS:   acc_rdata = {14'h0, st_siren, st_alarm_active, st_zone, 5'h0, 3'(st_reason)};
      ADDR_EVENT_STATUS:   acc_rdata = evt_status;
      ADDR_EVENT_DATA:     acc_rdata = evt_data;
      ADDR_IRQ_STATUS:     acc_rdata = 32'(irq_status);
      ADDR_IRQ_ENABLE:     acc_rdata = 32'(irq_enable);
      ADDR_VERSION:        acc_rdata = {VERSION_MINOR, VERSION_MAJOR, 16'(NUM_ZONES)};  // injected bug #10
      default: begin
        if      (en_i >= 0) acc_rdata = vec_word(enable_q,      en_i);
        else if (by_i >= 0) acc_rdata = vec_word(bypass_q,      by_i);
        else if (zs_i >= 0) acc_rdata = vec_word(st_zone_level, zs_i);
        else if (zf_i >= 0) acc_rdata = vec_word(st_zone_fault, zf_i);
        else if (zt_i >= 0) acc_rdata = type_word(type_q,       zt_i);
      end
    endcase
  end

endmodule


//============================================================================
// irq_ctrl.sv  -  Interrupt status (RW1C) / enable / output (HCLK domain)
//   irq = |(irq_status & irq_enable)
//   A hardware 'set' wins over a simultaneous write-one-to-clear.
//============================================================================
module irq_ctrl #(
  parameter int NUM_IRQ = 6
)(
  input  logic               clk,
  input  logic               rst_n,
  input  logic [NUM_IRQ-1:0] irq_set,        // pulses (HCLK domain)
  input  logic               status_w1c_en,
  input  logic [NUM_IRQ-1:0] status_w1c_data,
  input  logic               enable_wr_en,
  input  logic [NUM_IRQ-1:0] enable_wr_data,
  output logic [NUM_IRQ-1:0] irq_status,
  output logic [NUM_IRQ-1:0] irq_enable,
  output logic               irq
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      irq_status <= '0;
      irq_enable <= '0;
    end else begin
      irq_status <= (irq_status & ~(status_w1c_en ? status_w1c_data : '0)) | irq_set;
      if (enable_wr_en) irq_enable <= enable_wr_data;
    end
  end

  assign irq = |(irq_status & irq_enable);

endmodule

//============================================================================
// alarm_core.sv  -  Complete sys_clk domain
//   zone manager, alarm priority, alarm FSM, timers, PIN/auth, fault register,
//   event collector/formatter and status outputs.
//============================================================================
module alarm_core
  import alarm_pkg::*;
#(
  parameter int NUM_ZONES         = 8,
  parameter int PIN_WIDTH         = 16,
  parameter int TIMER_WIDTH       = 24,
  parameter int EVENT_WIDTH       = 32,
  parameter int TICK_DIV          = 1,
  parameter int MAX_PIN_ATTEMPTS  = 3,
  parameter bit SW_DISARM_TRUSTED = 1'b1,
  parameter int ZW                = (NUM_ZONES > 1) ? $clog2(NUM_ZONES) : 1
)(
  input  logic                     clk,
  input  logic                     rst_n,

  // from sensor front end (sys_clk domain)
  input  logic [NUM_ZONES-1:0]     zone_level,
  input  logic [NUM_ZONES-1:0]     zone_event,
  input  logic [NUM_ZONES-1:0]     zone_tfault,

  // configuration (from HCLK via REQ/ACK, already in sys_clk domain)
  input  logic [TIMER_WIDTH-1:0]   cfg_entry,
  input  logic [TIMER_WIDTH-1:0]   cfg_exit,
  input  logic [TIMER_WIDTH-1:0]   cfg_alarm,
  input  logic [TIMER_WIDTH-1:0]   cfg_lockout,
  input  logic [PIN_WIDTH-1:0]     cfg_pin,
  input  logic [NUM_ZONES-1:0]     cfg_enable,
  input  logic [NUM_ZONES-1:0]     cfg_bypass,
  input  logic [3*NUM_ZONES-1:0]   cfg_type,

  // commands (from HCLK via REQ/ACK)
  input  logic                     cmd_valid,
  input  logic [4:0]               cmd_bits,
  input  logic [NUM_ZONES-1:0]     cmd_fault_clr,

  // keypad
  input  logic                     pin_valid,
  input  logic [PIN_WIDTH-1:0]     pin_code,

  // alarm outputs
  output logic                     siren,
  output logic                     strobe,
  output logic                     alarm_active,

  // event stream to async FIFO write port
  output logic                     ev_push,
  output logic [EVENT_WIDTH-1:0]   ev_word,

  // status (snapshotted to HCLK)
  output alarm_state_e             st_state,
  output logic                     st_alarm_active,
  output logic                     st_entry_active,
  output logic                     st_exit_active,
  output logic                     st_locked,
  output logic                     st_siren,
  output alarm_reason_e            st_reason,
  output logic [7:0]               st_zone,
  output logic [NUM_ZONES-1:0]     st_zone_level,
  output logic [NUM_ZONES-1:0]     st_zone_fault
);

  //--------------------------------------------------------------------------
  // time base: tick every TICK_DIV clocks (TICK_DIV = 1 -> count clk cycles)
  //--------------------------------------------------------------------------
  logic tick;
  if (TICK_DIV <= 1) begin : g_tick1
    assign tick = 1'b1;
  end else begin : g_tickn
    localparam int TC_W = $clog2(TICK_DIV);
    logic [TC_W-1:0] tick_cnt;
    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)                              tick_cnt <= '0;
      else if (tick_cnt == TC_W'(TICK_DIV-1))  tick_cnt <= '0;
      else                                     tick_cnt <= tick_cnt + 1'b1;
    end
    assign tick = (tick_cnt == TC_W'(TICK_DIV-1));
  end

  logic [13:0] ts_q;                     // timestamp in ticks
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)    ts_q <= '0;
    else if (tick) ts_q <= ts_q + 1'b1;
  end

  //--------------------------------------------------------------------------
  // command decode
  //--------------------------------------------------------------------------
  logic cmd_arm_stay, cmd_arm_away, cmd_disarm, cmd_clear_alarm, cmd_clear_fault;
  assign cmd_arm_stay    = cmd_valid & cmd_bits[CTRL_ARM_STAY];
  assign cmd_arm_away    = cmd_valid & cmd_bits[CTRL_ARM_AWAY];
  assign cmd_disarm      = cmd_valid & cmd_bits[CTRL_DISARM];
  assign cmd_clear_alarm = cmd_valid & cmd_bits[CTRL_CLEAR_ALARM];
  assign cmd_clear_fault = cmd_valid & cmd_bits[CTRL_CLEAR_FAULT];

  //--------------------------------------------------------------------------
  // zone manager + priority
  //--------------------------------------------------------------------------
  alarm_state_e         state;
  logic                 entry_req, perim_req, motion_req, panic_req, fire_req;
  logic [ZW-1:0]        entry_zone, perim_zone, motion_zone, panic_zone, fire_zone;
  logic [NUM_ZONES-1:0] open_stay, open_away;

  zone_manager #(.NUM_ZONES(NUM_ZONES), .ZW(ZW)) u_zone_mgr (
    .state(state),
    .zone_level(zone_level), .zone_event(zone_event),
    .cfg_enable(cfg_enable), .cfg_bypass(cfg_bypass), .cfg_type(cfg_type),
    .entry_req(entry_req),   .entry_zone(entry_zone),
    .perim_req(perim_req),   .perim_zone(perim_zone),
    .motion_req(motion_req), .motion_zone(motion_zone),
    .panic_req(panic_req),   .panic_zone(panic_zone),
    .fire_req(fire_req),     .fire_zone(fire_zone),
    .open_stay(open_stay),   .open_away(open_away)
  );

  logic          exit_expired, entry_expired, alarm_expired;
  logic [ZW-1:0] entry_zone_q, zone_q;
  logic          entry_timeout_req, alarm_request;
  alarm_reason_e alarm_reason, reason_q;
  logic [ZW-1:0] alarm_zone;

  assign entry_timeout_req = entry_expired & (state == ST_ENTRY_DELAY);

  alarm_priority #(.ZW(ZW)) u_prio (
    .entry_timeout_req(entry_timeout_req), .entry_zone(entry_zone_q),
    .perim_req(perim_req),   .perim_zone(perim_zone),
    .motion_req(motion_req), .motion_zone(motion_zone),
    .panic_req(panic_req),   .panic_zone(panic_zone),
    .fire_req(fire_req),     .fire_zone(fire_zone),
    .alarm_request(alarm_request), .alarm_reason(alarm_reason), .alarm_zone(alarm_zone)
  );

  //--------------------------------------------------------------------------
  // PIN / authentication
  //--------------------------------------------------------------------------
  logic pin_ok, pin_bad, lockout_start, locked;

  pin_auth #(.PIN_WIDTH(PIN_WIDTH), .TIMER_WIDTH(TIMER_WIDTH),
             .MAX_ATTEMPTS(MAX_PIN_ATTEMPTS)) u_pin (
    .clk(clk), .rst_n(rst_n), .tick(tick),
    .pin_valid(pin_valid), .pin_code(pin_code),
    .cfg_pin(cfg_pin), .cfg_lockout(cfg_lockout),
    .pin_ok(pin_ok), .pin_bad(pin_bad),
    .lockout_start(lockout_start), .locked(locked)
  );

  //--------------------------------------------------------------------------
  // alarm FSM
  //--------------------------------------------------------------------------
  logic                 start_exit, stop_exit, start_entry, stop_entry;
  logic                 start_alarm, stop_alarm, siren_off;
  logic                 fsm_ev_req;
  event_type_e          fsm_ev_type;
  logic [7:0]           fsm_ev_zone;
  logic [NUM_ZONES-1:0] arm_fault_set;

  alarm_fsm #(.NUM_ZONES(NUM_ZONES), .ZW(ZW), .SW_DISARM_TRUSTED(SW_DISARM_TRUSTED)) u_fsm (
    .clk(clk), .rst_n(rst_n),
    .cmd_arm_stay(cmd_arm_stay), .cmd_arm_away(cmd_arm_away),
    .cmd_disarm(cmd_disarm), .cmd_clear_alarm(cmd_clear_alarm),
    .cmd_clear_fault(cmd_clear_fault), .auth_ok(pin_ok),
    .exit_expired(exit_expired), .alarm_expired(alarm_expired),
    .start_exit(start_exit),   .stop_exit(stop_exit),
    .start_entry(start_entry), .stop_entry(stop_entry),
    .start_alarm(start_alarm), .stop_alarm(stop_alarm),
    .entry_req(entry_req), .entry_zone(entry_zone),
    .alarm_request(alarm_request), .alarm_reason(alarm_reason), .alarm_zone(alarm_zone),
    .open_stay(open_stay), .open_away(open_away),
    .state(state), .entry_zone_q(entry_zone_q),
    .reason_q(reason_q), .zone_q(zone_q), .siren_off(siren_off),
    .ev_req(fsm_ev_req), .ev_type(fsm_ev_type), .ev_zone(fsm_ev_zone),
    .arm_fault_set(arm_fault_set)
  );

  //--------------------------------------------------------------------------
  // timers (shared programmable_timer)
  //--------------------------------------------------------------------------
  logic exit_active, entry_active, alarm_tmr_active;

  programmable_timer #(.WIDTH(TIMER_WIDTH)) u_exit_timer (
    .clk(clk), .reset_n(rst_n), .tick(tick),
    .start(start_exit), .stop(stop_exit), .timeout_value(cfg_exit),
    .active(exit_active), .expired(exit_expired));

  programmable_timer #(.WIDTH(TIMER_WIDTH)) u_entry_timer (
    .clk(clk), .reset_n(rst_n), .tick(tick),
    .start(start_entry), .stop(stop_entry), .timeout_value(cfg_entry),
    .active(entry_active), .expired(entry_expired));

  // Alarm duration 0 => siren stays on until the alarm is cleared.
  programmable_timer #(.WIDTH(TIMER_WIDTH)) u_alarm_timer (
    .clk(clk), .reset_n(rst_n), .tick(tick),
    .start(start_alarm & (cfg_alarm != '0)), .stop(stop_alarm),
    .timeout_value(cfg_alarm),
    .active(alarm_tmr_active), .expired(alarm_expired));

  logic unused_alarm_tmr_active;
  assign unused_alarm_tmr_active = alarm_tmr_active;

  //--------------------------------------------------------------------------
  // zone fault register (sticky).  Set: excessive toggling, sensor open at
  // arm attempt.  Clear: CONTROL.CLEAR_FAULT (all) or RW1C mask from AHB.
  //--------------------------------------------------------------------------
  logic [NUM_ZONES-1:0] zone_fault_q, fault_set, fault_clr, fault_new;

  assign fault_set = (zone_tfault & cfg_enable) | arm_fault_set;
  assign fault_clr = ({NUM_ZONES{cmd_clear_fault}}) |
                     (cmd_valid ? cmd_fault_clr : '0);
  assign fault_new = (zone_tfault & cfg_enable) & ~zone_fault_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) zone_fault_q <= '0;
    else        zone_fault_q <= (zone_fault_q & ~fault_clr) | fault_set;
  end

  //--------------------------------------------------------------------------
  // event collector: 4 sources, 1 push per cycle, fixed priority.
  //   0: FSM   1: invalid PIN   2: keypad lockout   3: toggling sensor fault
  //--------------------------------------------------------------------------
  localparam int NSRC = 4;
  logic [NSRC-1:0] req_v, pend_q, grant;
  event_type_e     type_v [NSRC];
  logic [7:0]      zone_v [NSRC];
  event_type_e     pend_type [NSRC];
  logic [7:0]      pend_zone [NSRC];

  function automatic logic [7:0] lowest_zone(input logic [NUM_ZONES-1:0] v);
    logic [7:0] r;
    r = EV_NO_ZONE;
    for (int i = NUM_ZONES-1; i >= 0; i--) if (v[i]) r = 8'(i);
    return r;
  endfunction

  always_comb begin
    req_v   = {(|fault_new), lockout_start, pin_bad, fsm_ev_req};
    type_v[0] = fsm_ev_type;         zone_v[0] = fsm_ev_zone;
    type_v[1] = EV_INVALID_PIN;      zone_v[1] = EV_NO_ZONE;
    type_v[2] = EV_KEYPAD_LOCKOUT;   zone_v[2] = EV_NO_ZONE;
    type_v[3] = EV_SENSOR_FAULT;     zone_v[3] = lowest_zone(fault_new);

    grant = '0;
    for (int k = NSRC-1; k >= 0; k--) if (pend_q[k]) begin
      grant     = '0;
      grant[k]  = 1'b1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pend_q <= '0;
      for (int k = 0; k < NSRC; k++) begin
        pend_type[k] <= EV_NONE;
        pend_zone[k] <= EV_NO_ZONE;
      end
    end else begin
      for (int k = 0; k < NSRC; k++) begin
        pend_q[k] <= (pend_q[k] & ~grant[k]) | req_v[k];
        if (req_v[k] && (!pend_q[k] || grant[k])) begin
          pend_type[k] <= type_v[k];
          pend_zone[k] <= zone_v[k];
        end
      end
    end
  end

  // format the granted event (state / reason / timestamp sampled at push time)
  logic [31:0]  ev_word32;
  event_type_e  g_type;
  logic [7:0]   g_zone;

  always_comb begin
    g_type = EV_NONE;
    g_zone = EV_NO_ZONE;
    for (int k = 0; k < NSRC; k++) if (grant[k]) begin
      g_type = pend_type[k];
      g_zone = pend_zone[k];
    end
  end

  assign ev_push   = |pend_q;
  assign ev_word32 = {ts_q, 3'(reason_q), 3'(state), g_zone, 4'(g_type)};
  assign ev_word   = EVENT_WIDTH'(ev_word32);

  //--------------------------------------------------------------------------
  // outputs / status
  //--------------------------------------------------------------------------
  assign alarm_active = (state == ST_ALARM);
  assign strobe       = alarm_active;
  assign siren        = alarm_active & ~siren_off;

  assign st_state        = state;
  assign st_alarm_active = alarm_active;
  assign st_entry_active = entry_active;
  assign st_exit_active  = exit_active;
  assign st_locked       = locked;
  assign st_siren        = siren;
  assign st_reason       = reason_q;
  assign st_zone         = 8'(zone_q);
  assign st_zone_level   = zone_level;
  assign st_zone_fault   = zone_fault_q;

endmodule

//============================================================================
// alarm_fsm.sv  -  Overall alarm operation (sys_clk domain)
//
//   DISARMED -> EXIT_DELAY -> ARMED_STAY / ARMED_AWAY -> ENTRY_DELAY -> ALARM
//   FAULT is entered when arming is attempted with an open sensor.
//   FIRE / PANIC (and any other alarm request) go straight to ALARM; FIRE and
//   PANIC are honoured in every state.
//
//   Disarm / clear-alarm are "authenticated" operations:
//     * a valid keypad PIN (auth_ok) always performs disarm + clear
//     * software CONTROL.DISARM / CLEAR_ALARM are honoured only when
//       SW_DISARM_TRUSTED = 1 (host CPU treated as an authenticated master).
//   Any alarm returns to DISARMED when cleared.
//   An alarm in progress can be ESCALATED (reason upgraded, event logged) if a
//   higher-priority condition appears.
//============================================================================
module alarm_fsm
  import alarm_pkg::*;
#(
  parameter int NUM_ZONES         = 8,
  parameter int ZW                = (NUM_ZONES > 1) ? $clog2(NUM_ZONES) : 1,
  parameter bit SW_DISARM_TRUSTED = 1'b1
)(
  input  logic                  clk,
  input  logic                  rst_n,

  // commands (1-cycle pulses)
  input  logic                  cmd_arm_stay,
  input  logic                  cmd_arm_away,
  input  logic                  cmd_disarm,
  input  logic                  cmd_clear_alarm,
  input  logic                  cmd_clear_fault,
  input  logic                  auth_ok,          // valid PIN entered

  // timers
  input  logic                  exit_expired,
  input  logic                  alarm_expired,
  output logic                  start_exit,  stop_exit,
  output logic                  start_entry, stop_entry,
  output logic                  start_alarm, stop_alarm,

  // zone manager / priority
  input  logic                  entry_req,
  input  logic [ZW-1:0]         entry_zone,
  input  logic                  alarm_request,
  input  alarm_reason_e         alarm_reason,
  input  logic [ZW-1:0]         alarm_zone,
  input  logic [NUM_ZONES-1:0]  open_stay,
  input  logic [NUM_ZONES-1:0]  open_away,

  // state / status
  output alarm_state_e          state,
  output logic [ZW-1:0]         entry_zone_q,
  output alarm_reason_e         reason_q,
  output logic [ZW-1:0]         zone_q,
  output logic                  siren_off,        // alarm duration elapsed

  // event + fault reporting
  output logic                  ev_req,
  output event_type_e           ev_type,
  output logic [7:0]            ev_zone,
  output logic [NUM_ZONES-1:0]  arm_fault_set
);

  alarm_state_e state_q, next_state;
  logic         away_q;
  logic         latch_alarm;

  logic                 arm_cmd, arm_away_sel, disarm_req, clear_req;
  logic [NUM_ZONES-1:0] bad_mask;

  assign disarm_req   = auth_ok | (SW_DISARM_TRUSTED & cmd_disarm);
  assign clear_req    = auth_ok | (SW_DISARM_TRUSTED & cmd_clear_alarm);
  assign arm_cmd      = cmd_arm_stay | cmd_arm_away;
  assign arm_away_sel = cmd_arm_away;                       // AWAY wins a tie
  assign bad_mask     = arm_away_sel ? open_away : open_stay;

  assign state = state_q;

  function automatic event_type_e reason_to_ev(input alarm_reason_e r);
    case (r)
      AR_FIRE:  return EV_FIRE;
      AR_PANIC: return EV_PANIC;
      default:  return EV_INTRUSION;
    endcase
  endfunction

  function automatic logic [7:0] lowest_set(input logic [NUM_ZONES-1:0] v);
    logic [7:0] r;
    r = EV_NO_ZONE;
    for (int i = NUM_ZONES-1; i >= 0; i--) if (v[i]) r = 8'(i);
    return r;
  endfunction

  // -------------------------------------------------------------------------
  // next-state / event logic
  // -------------------------------------------------------------------------
  always_comb begin
    next_state    = state_q;
    latch_alarm   = 1'b0;
    ev_req        = 1'b0;
    ev_type       = EV_NONE;
    ev_zone       = EV_NO_ZONE;
    arm_fault_set = '0;

    case (state_q)
      //---------------------------------------------------------------------
      ST_DISARMED: begin
        if (alarm_request) begin                       // FIRE / PANIC only
          next_state  = ST_ALARM;
          latch_alarm = 1'b1;
          ev_req = 1'b1; ev_type = reason_to_ev(alarm_reason); ev_zone = 8'(alarm_zone);
        end else if (arm_cmd) begin
          if (|bad_mask) begin                         // sensor active when arming
            next_state    = ST_FAULT;
            arm_fault_set = bad_mask;
            ev_req = 1'b1; ev_type = EV_SENSOR_FAULT; ev_zone = lowest_set(bad_mask);
          end else begin
            next_state = ST_EXIT_DELAY;
            ev_req  = 1'b1;
            ev_type = arm_away_sel ? EV_ARM_AWAY : EV_ARM_STAY;
          end
        end
      end
      //---------------------------------------------------------------------
      ST_EXIT_DELAY: begin
        if (alarm_request) begin
          next_state  = ST_ALARM;
          latch_alarm = 1'b1;
          ev_req = 1'b1; ev_type = reason_to_ev(alarm_reason); ev_zone = 8'(alarm_zone);
        end else if (disarm_req) begin
          next_state = ST_DISARMED;
          ev_req = 1'b1; ev_type = EV_DISARM;
        end else if (exit_expired) begin
          next_state = away_q ? ST_ARMED_AWAY : ST_ARMED_STAY;
        end
      end
      //---------------------------------------------------------------------
      ST_ARMED_STAY, ST_ARMED_AWAY: begin
        if (alarm_request) begin
          next_state  = ST_ALARM;
          latch_alarm = 1'b1;
          ev_req = 1'b1; ev_type = reason_to_ev(alarm_reason); ev_zone = 8'(alarm_zone);
        end else if (entry_req) begin                      // injected bug #7 (order swapped)
          next_state = ST_ENTRY_DELAY;
          ev_req = 1'b1; ev_type = EV_ENTRY_DELAY; ev_zone = 8'(entry_zone);
        end else if (disarm_req) begin
          next_state = ST_DISARMED;
          ev_req = 1'b1; ev_type = EV_DISARM;
        end
      end
      //---------------------------------------------------------------------
      ST_ENTRY_DELAY: begin
        // alarm_request already includes ENTRY_TIMEOUT (see alarm_core)
        if (alarm_request) begin
          next_state  = ST_ALARM;
          latch_alarm = 1'b1;
          ev_req = 1'b1; ev_type = reason_to_ev(alarm_reason); ev_zone = 8'(alarm_zone);
        end else if (disarm_req) begin
          next_state = ST_DISARMED;
          ev_req = 1'b1; ev_type = EV_DISARM;
        end
      end
      //---------------------------------------------------------------------
      ST_ALARM: begin
        if (clear_req) begin
          next_state = ST_DISARMED;
          ev_req = 1'b1; ev_type = EV_ALARM_CLEAR;
        end else if (alarm_request && (3'(alarm_reason) >= 3'(reason_q))) begin  // injected bug #6
          latch_alarm = 1'b1;                          // escalation
          ev_req = 1'b1; ev_type = reason_to_ev(alarm_reason); ev_zone = 8'(alarm_zone);
        end
      end
      //---------------------------------------------------------------------
      ST_FAULT: begin
        if (alarm_request) begin
          next_state  = ST_ALARM;
          latch_alarm = 1'b1;
          ev_req = 1'b1; ev_type = reason_to_ev(alarm_reason); ev_zone = 8'(alarm_zone);
        end else if (cmd_clear_fault || disarm_req) begin
          next_state = ST_DISARMED;
          ev_req = 1'b1; ev_type = EV_DISARM;
        end
      end
      //---------------------------------------------------------------------
      default: next_state = ST_DISARMED;
    endcase
  end

  // -------------------------------------------------------------------------
  // timer control derived from state transitions
  // -------------------------------------------------------------------------
  assign start_exit  = (state_q != ST_EXIT_DELAY)  && (next_state == ST_EXIT_DELAY);
  assign stop_exit   = (state_q == ST_EXIT_DELAY)  && (next_state != ST_EXIT_DELAY);
  assign start_entry = (state_q != ST_ENTRY_DELAY) && (next_state == ST_ENTRY_DELAY);
  assign stop_entry  = (state_q == ST_ENTRY_DELAY) && (next_state != ST_ENTRY_DELAY);
  assign start_alarm = ((state_q != ST_ALARM) && (next_state == ST_ALARM)) ||
                       ((state_q == ST_ALARM) && latch_alarm);
  assign stop_alarm  = (state_q == ST_ALARM) && (next_state != ST_ALARM);

  // -------------------------------------------------------------------------
  // registers
  // -------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q      <= ST_DISARMED;
      away_q       <= 1'b0;
      entry_zone_q <= '0;
      reason_q     <= AR_NONE;
      zone_q       <= '0;
      siren_off    <= 1'b0;
    end else begin
      state_q <= next_state;

      if (state_q == ST_DISARMED && next_state == ST_EXIT_DELAY)
        away_q <= arm_away_sel;

      if (next_state == ST_ENTRY_DELAY && state_q != ST_ENTRY_DELAY)
        entry_zone_q <= entry_zone;

      if (latch_alarm) begin
        reason_q <= alarm_reason;
        zone_q   <= alarm_zone;
      end else if (state_q == ST_ALARM && next_state != ST_ALARM) begin
        reason_q <= AR_NONE;
        zone_q   <= '0;
      end

      if (start_alarm || stop_alarm) siren_off <= 1'b0;
      else if (state_q == ST_ALARM && alarm_expired) siren_off <= 1'b1;
    end
  end

endmodule


//============================================================================
// alarm_priority.sv  -  Resolves simultaneous alarm conditions
//   FIRE > PANIC > PERIMETER > MOTION > ENTRY_TIMEOUT
//============================================================================
module alarm_priority
  import alarm_pkg::*;
#(
  parameter int ZW = 3
)(
  input  logic            entry_timeout_req,
  input  logic [ZW-1:0]   entry_zone,
  input  logic            perim_req,
  input  logic [ZW-1:0]   perim_zone,
  input  logic            motion_req,
  input  logic [ZW-1:0]   motion_zone,
  input  logic            panic_req,
  input  logic [ZW-1:0]   panic_zone,
  input  logic            fire_req,
  input  logic [ZW-1:0]   fire_zone,

  output logic            alarm_request,
  output alarm_reason_e   alarm_reason,
  output logic [ZW-1:0]   alarm_zone
);

  always_comb begin
    alarm_request = 1'b1;
    if (fire_req) begin
      alarm_reason = AR_FIRE;          alarm_zone = fire_zone;
    end else if (panic_req) begin
      alarm_reason = AR_PANIC;         alarm_zone = panic_zone;
    end else if (perim_req) begin
      alarm_reason = AR_PERIMETER;     alarm_zone = perim_zone;
    end else if (motion_req) begin
      alarm_reason = AR_MOTION;        alarm_zone = motion_zone;
    end else if (entry_timeout_req) begin
      alarm_reason = AR_ENTRY_TIMEOUT; alarm_zone = entry_zone;
    end else begin
      alarm_request = 1'b0;
      alarm_reason  = AR_NONE;         alarm_zone = '0;
    end
  end

endmodule

//============================================================================
// pin_auth.sv  -  Keypad PIN authentication and lockout (sys_clk domain)
//   * one attempt per rising edge of pin_valid
//   * consecutive failures counted; MAX_ATTEMPTS-th failure starts lockout
//   * while locked, keypad entries are ignored
//   * a successful attempt clears the failure count
//   * lockout time = cfg_lockout ticks (0 disables the lockout)
//============================================================================
module pin_auth #(
  parameter int PIN_WIDTH    = 16,
  parameter int TIMER_WIDTH  = 24,
  parameter int MAX_ATTEMPTS = 3
)(
  input  logic                    clk,
  input  logic                    rst_n,
  input  logic                    tick,
  input  logic                    pin_valid,
  input  logic [PIN_WIDTH-1:0]    pin_code,
  input  logic [PIN_WIDTH-1:0]    cfg_pin,
  input  logic [TIMER_WIDTH-1:0]  cfg_lockout,
  output logic                    pin_ok,          // 1-cycle pulse
  output logic                    pin_bad,         // 1-cycle pulse
  output logic                    lockout_start,   // 1-cycle pulse
  output logic                    locked
);

  localparam int FC_W = $clog2(MAX_ATTEMPTS + 1);

  logic            pin_valid_q, attempt, match;
  logic [FC_W-1:0] fail_cnt;
  logic            lock_expired;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pin_valid_q <= 1'b0;
    else        pin_valid_q <= pin_valid;
  end

  assign attempt = pin_valid & ~pin_valid_q & ~locked;
  assign match   = (pin_code == cfg_pin);
  assign pin_ok  = attempt & match;
  assign pin_bad = attempt & ~match;
  assign lockout_start = pin_bad & (fail_cnt == FC_W'(MAX_ATTEMPTS - 1));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fail_cnt <= '0;
    end else begin
      if (pin_bad || lockout_start) fail_cnt <= '0;        // injected bug #5
      else if (pin_ok)              fail_cnt <= fail_cnt + 1'b1;  // injected bug #5
    end
  end

  programmable_timer #(.WIDTH(TIMER_WIDTH)) u_lock_timer (
    .clk(clk), .reset_n(rst_n), .tick(tick),
    .start(lockout_start), .stop(1'b0),
    .timeout_value(cfg_lockout),
    .active(locked), .expired(lock_expired)
  );

  // lock_expired is informational only (lockout ends when the timer stops)
  logic unused_lock_expired;
  assign unused_lock_expired = lock_expired;

endmodule

//============================================================================
// programmable_timer.sv  -  Reusable down-counter timer
//   start  : (re)load timeout_value and run.  timeout_value == 0 expires on
//            the next clock.
//   stop   : cancel (has priority over start).
//   tick   : timebase enable (tie to 1'b1 to count clk cycles).
//   active : high while counting.
//   expired: single-cycle pulse when the programmed time has elapsed.
//   The counter decrements once per tick, so a value of N expires after
//   N ticks.
//============================================================================
module programmable_timer #(
  parameter int WIDTH = 24
)(
  input  logic             clk,
  input  logic             reset_n,
  input  logic             tick,
  input  logic             start,
  input  logic             stop,
  input  logic [WIDTH-1:0] timeout_value,
  output logic             active,
  output logic             expired
);

  logic [WIDTH-1:0] count;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      count   <= '0;
      active  <= 1'b0;
      expired <= 1'b0;
    end else begin
      expired <= 1'b0;
      if (stop) begin
        active <= 1'b0;
        count  <= '0;
      end else if (start) begin
        if (timeout_value == '0) begin
          active  <= 1'b0;
          expired <= 1'b1;
        end else begin
          active <= 1'b1;
          count  <= timeout_value;
        end
      end else if (active && tick) begin
        if (count == WIDTH'(1)) begin
          active  <= 1'b0;
          expired <= 1'b1;
          count   <= '0;
        end else begin
          count <= count - 1'b1;
        end
      end
    end
  end

endmodule

//============================================================================
// sensor_channel.sv  -  One physical sensor input (sensor_clk domain)
//   sensor_in --> SYNC_STAGES flop synchroniser --> debounce --> level
//                                                       |--> rise event
//                                                       '--> toggle-rate fault
//   Sensors are active-high (1 = triggered / open / detected).
//============================================================================
module sensor_channel #(
  parameter int SYNC_STAGES    = 2,
  parameter int DEBOUNCE_CYCLES = 4,     // >= 1
  parameter int TOGGLE_LIMIT   = 8,      // debounced edges per window; 0 = off
  parameter int TOGGLE_WINDOW  = 1024    // window length in sensor_clk cycles
)(
  input  logic clk,
  input  logic rst_n,
  input  logic sensor_in,            // asynchronous
  output logic level,                // debounced sensor state
  output logic rise_pulse,           // 1-cycle pulse on inactive -> active
  output logic toggle_fault_pulse    // 1-cycle pulse: excessive toggling
);

  if (DEBOUNCE_CYCLES < 1) begin : g_db_check
    $error("sensor_channel: DEBOUNCE_CYCLES (%0d) must be >= 1", DEBOUNCE_CYCLES);
  end

  // ---- 1. synchroniser -----------------------------------------------------
  logic sync_out;
  sync_ff #(.STAGES(SYNC_STAGES)) u_sync (
    .clk(clk), .rst_n(rst_n), .d(sensor_in), .q(sync_out)
  );

  // ---- 2. debounce: new value must be stable for DEBOUNCE_CYCLES clocks ----
  localparam int DB_W = $clog2(DEBOUNCE_CYCLES + 1);
  logic [DB_W-1:0] db_cnt;
  logic            level_q, level_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      db_cnt  <= '0;
      level_q <= 1'b0;
      level_d <= 1'b0;
    end else begin
      level_d <= level_q;
      if (sync_out == level_q) begin
        db_cnt <= '0;
      end else if (db_cnt == DB_W'(DEBOUNCE_CYCLES)) begin  // injected bug #3
        level_q <= sync_out;
        db_cnt  <= '0;
      end else begin
        db_cnt <= db_cnt + 1'b1;
      end
    end
  end

  assign level      = level_q;
  assign rise_pulse = level_q & ~level_d;

  // ---- 3. excessive-toggle detector ----------------------------------------
  if (TOGGLE_LIMIT >= 2) begin : g_toggle_mon
    localparam int WIN_W = $clog2(TOGGLE_WINDOW);
    localparam int EC_W  = $clog2(TOGGLE_LIMIT + 1);

    logic [WIN_W-1:0] win_cnt;
    logic [EC_W-1:0]  edge_cnt;
    logic             edge_seen, win_wrap;

    assign edge_seen = level_q ^ level_d;
    assign win_wrap  = (win_cnt == WIN_W'(TOGGLE_WINDOW - 1));

    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        win_cnt            <= '0;
        edge_cnt           <= '0;
        toggle_fault_pulse <= 1'b0;
      end else begin
        toggle_fault_pulse <= 1'b0;
        if (win_wrap) begin
          win_cnt  <= '0;
          edge_cnt <= EC_W'(edge_seen);
        end else begin
          win_cnt <= win_cnt + 1'b1;
          if (edge_seen && (edge_cnt != EC_W'(TOGGLE_LIMIT))) begin
            edge_cnt <= edge_cnt + 1'b1;
            if (edge_cnt == EC_W'(TOGGLE_LIMIT - 1)) toggle_fault_pulse <= 1'b1;
          end
        end
      end
    end
  end else begin : g_no_toggle_mon
    assign toggle_fault_pulse = 1'b0;
  end

endmodule

//============================================================================
// toggle_pulse_sync.sv  -  Safe single-event CDC (toggle + feedback).
//
//  src : a pulse sets 'pending'; when the link is idle the source toggles
//        src_tog.  The destination synchronises the toggle, XORs it with its
//        previous value to regenerate ONE dst_clk pulse, and echoes the
//        toggle back.  The source will not launch a new toggle until the echo
//        has returned, so the scheme is correct for ANY clock ratio.
//        Pulses arriving while the link is busy are coalesced into a single
//        pending event (at-least-one semantic).
//
//  RDC note: a destination-side reset is absorbed by a short warm-up window
//  (no pulse is produced while the synchroniser refills).  A source-only
//  reset can cause at most one spurious pulse in the destination.
//============================================================================
module toggle_pulse_sync #(
  parameter int SYNC_STAGES = 2
)(
  input  logic src_clk,
  input  logic src_rst_n,
  input  logic src_pulse,
  input  logic dst_clk,
  input  logic dst_rst_n,
  output logic dst_pulse
);

  localparam int WARM_MAX = SYNC_STAGES + 1;
  localparam int WARM_W   = $clog2(WARM_MAX + 1);

  // ---------------- source domain ----------------
  logic src_tog, pending, ack_sync;
  logic want, busy, launch;

  assign want   = pending | src_pulse;
  assign busy   = src_tog ^ ack_sync;
  assign launch = want & ~busy;

  always_ff @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
      src_tog <= 1'b0;
      pending <= 1'b0;
    end else begin
      pending <= want & ~launch;
      if (launch) src_tog <= ~src_tog;
    end
  end

  // ---------------- destination domain ----------------
  logic               tog_sync, tog_q;
  logic [WARM_W-1:0]  warm;

  sync_ff #(.STAGES(SYNC_STAGES)) u_tog_sync (
    .clk(dst_clk), .rst_n(dst_rst_n), .d(src_tog), .q(tog_sync)
  );

  always_ff @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
      tog_q <= 1'b0;
      warm  <= '0;
    end else begin
      tog_q <= tog_sync;
      if (warm != WARM_W'(WARM_MAX)) warm <= warm + 1'b1;
    end
  end

  assign dst_pulse = (tog_sync ^ tog_q) & (warm == WARM_W'(WARM_MAX));

  // ---------------- echo back to source ----------------
  sync_ff #(.STAGES(SYNC_STAGES)) u_ack_sync (
    .clk(src_clk), .rst_n(src_rst_n), .d(tog_q), .q(ack_sync)
  );

endmodule


//============================================================================
// zone_manager.sv  -  Interprets every sensor per its programmed type
//   (sys_clk domain, purely combinational).
//
//   Trigger of a zone  = debounced level OR rise-event  (the event catches
//   pulses shorter than the level-CDC latency).
//
//   Qualification by system state:
//     ENTRY     : ARMED_STAY, ARMED_AWAY                 -> starts entry delay
//     PERIMETER : ARMED_STAY, ARMED_AWAY, ENTRY_DELAY    -> immediate alarm
//     MOTION    : ARMED_AWAY only                        -> immediate alarm
//     FIRE/PANIC: every state, never bypassable
//   Enable/bypass:  disabled zones are ignored; bypass suppresses ENTRY,
//   PERIMETER and MOTION zones only.
//============================================================================
module zone_manager
  import alarm_pkg::*;
#(
  parameter int NUM_ZONES = 8,
  parameter int ZW        = (NUM_ZONES > 1) ? $clog2(NUM_ZONES) : 1
)(
  input  alarm_state_e             state,
  input  logic [NUM_ZONES-1:0]     zone_level,
  input  logic [NUM_ZONES-1:0]     zone_event,
  input  logic [NUM_ZONES-1:0]     cfg_enable,
  input  logic [NUM_ZONES-1:0]     cfg_bypass,
  input  logic [3*NUM_ZONES-1:0]   cfg_type,

  // per-class requests + lowest-numbered offending zone
  output logic                     entry_req,
  output logic [ZW-1:0]            entry_zone,
  output logic                     perim_req,
  output logic [ZW-1:0]            perim_zone,
  output logic                     motion_req,
  output logic [ZW-1:0]            motion_zone,
  output logic                     panic_req,
  output logic [ZW-1:0]            panic_zone,
  output logic                     fire_req,
  output logic [ZW-1:0]            fire_zone,

  // sensors that are open right now and would block arming
  output logic [NUM_ZONES-1:0]     open_stay,
  output logic [NUM_ZONES-1:0]     open_away
);

  logic st_armed, st_perim_ok, st_motion_ok;
  assign st_armed     = (state == ST_ARMED_STAY) || (state == ST_ARMED_AWAY);
  assign st_perim_ok  = st_armed || (state == ST_ENTRY_DELAY);
  assign st_motion_ok = (state == ST_ARMED_STAY);   // injected bug #1

  logic [NUM_ZONES-1:0] v_entry, v_perim, v_motion, v_panic, v_fire;

  for (genvar i = 0; i < NUM_ZONES; i++) begin : g_zone
    zone_type_e zt;
    logic       trig, live;      // live = enabled and not bypassed
    assign zt   = zone_type_e'(cfg_type[3*i +: 3]);
    assign trig = zone_level[i] | zone_event[i];
    assign live = cfg_enable[i] & ~cfg_bypass[i];

    assign v_entry [i] = live & trig & (zt == ZT_ENTRY)     & st_armed;
    assign v_perim [i] = live & trig & (zt == ZT_PERIMETER) & st_perim_ok;
    assign v_motion[i] = live & trig & (zt == ZT_MOTION)    & st_motion_ok;
    assign v_panic [i] = cfg_enable[i] & trig & (zt == ZT_PANIC);  // no bypass
    assign v_fire  [i] = cfg_enable[i] & trig & (zt == ZT_FIRE);   // no bypass

    assign open_stay[i] = live & zone_level[i] &
                          ((zt == ZT_ENTRY) || (zt == ZT_PERIMETER));
    assign open_away[i] = live & zone_level[i] &
                          ((zt == ZT_ENTRY) || (zt == ZT_PERIMETER) || (zt == ZT_MOTION));
  end

  // lowest-index priority encode per class
  function automatic logic [ZW-1:0] lowest(input logic [NUM_ZONES-1:0] v);
    logic [ZW-1:0] r;
    r = '0;
    for (int i = NUM_ZONES-1; i >= 0; i--) if (v[i]) r = ZW'(i);
    return r;
  endfunction

  assign entry_req   = |v_entry;   assign entry_zone  = lowest(v_entry);
  assign perim_req   = |v_perim;   assign perim_zone  = lowest(v_perim);
  assign motion_req  = |v_motion;  assign motion_zone = lowest(v_motion);
  assign panic_req   = |v_panic;   assign panic_zone  = lowest(v_panic);
  assign fire_req    = |v_fire;    assign fire_zone   = lowest(v_fire);

endmodule


/* verilator lint_on UNUSEDPARAM */
//============================================================================
// smart_home_alarm_top.sv  -  Smart Home Alarm Controller (top level)
//
//   sensor_clk : sensor synchronisation / debounce / event detection
//   sys_clk    : alarm FSM, timers, PIN, zone manager, event generation
//   HCLK       : AHB-Lite slave, registers, IRQ, event FIFO reader
//
//   CDC summary (see README for the full table):
//     sensor level      sensor_clk -> sys_clk  SYNC_STAGES-flop synchroniser
//     sensor events     sensor_clk -> sys_clk  toggle pulse sync (handshaked)
//     configuration     HCLK       -> sys_clk  REQ/ACK, multi-bit
//     commands          HCLK       -> sys_clk  REQ/ACK, multi-bit
//     status snapshot   sys_clk    -> HCLK     REQ/ACK, multi-bit (continuous)
//     event stream      sys_clk    -> HCLK     asynchronous FIFO
//     FIFO overflow     sys_clk    -> HCLK     toggle pulse sync
//     sys reset status  sys_clk    -> HCLK     SYNC_STAGES-flop synchroniser
//============================================================================
module smart_home_alarm_top
  import alarm_pkg::*;
#(
  parameter int NUM_ZONES         = 8,
  parameter int PIN_WIDTH         = 16,
  parameter int TIMER_WIDTH       = 24,
  parameter int EVENT_WIDTH       = 32,
  parameter int EVENT_FIFO_DEPTH  = 8,
  parameter int SYNC_STAGES       = 2,
  parameter int DEBOUNCE_CYCLES   = 4,
  // additional (documented) parameters
  parameter int TICK_DIV          = 1,     // sys_clk cycles per timer tick
  parameter int MAX_PIN_ATTEMPTS  = 3,
  parameter int TOGGLE_LIMIT      = 8,     // sensor toggle-fault: edges / window (0 = off)
  parameter int TOGGLE_WINDOW     = 1024,  // window in sensor_clk cycles
  parameter bit SW_DISARM_TRUSTED = 1'b1   // CONTROL.DISARM/CLEAR_ALARM honoured w/o PIN
)(
  // ---------------- sensor domain ----------------
  input  logic                    sensor_clk,
  input  logic                    sensor_reset_n,
  input  logic [NUM_ZONES-1:0]    sensor_in,

  // ---------------- system domain ----------------
  input  logic                    sys_clk,
  input  logic                    sys_reset_n,
  input  logic                    pin_valid,
  input  logic [PIN_WIDTH-1:0]    pin_code,
  output logic                    siren,
  output logic                    strobe,
  output logic                    alarm_active,

  // ---------------- AHB-Lite slave ----------------
  input  logic                    HCLK,
  input  logic                    HRESETn,
  input  logic                    HSEL,
  input  logic [31:0]             HADDR,
  input  logic [1:0]              HTRANS,
  input  logic                    HWRITE,
  input  logic [2:0]              HSIZE,
  input  logic [31:0]             HWDATA,
  input  logic                    HREADY,
  output logic [31:0]             HRDATA,
  output logic                    HREADYOUT,
  output logic                    HRESP,
  output logic                    irq
);

  //==========================================================================
  // Illegal-parameter checks (elaboration time)
  //==========================================================================
  if (NUM_ZONES < 1 || NUM_ZONES > 256) begin : g_chk_zones
    $error("NUM_ZONES (%0d) must be 1..256", NUM_ZONES);
  end
  if (PIN_WIDTH < 1 || PIN_WIDTH > 32) begin : g_chk_pin
    $error("PIN_WIDTH (%0d) must be 1..32", PIN_WIDTH);
  end
  if (TIMER_WIDTH < 2 || TIMER_WIDTH > 32) begin : g_chk_timer
    $error("TIMER_WIDTH (%0d) must be 2..32", TIMER_WIDTH);
  end
  if (EVENT_WIDTH < 12 || EVENT_WIDTH > 32) begin : g_chk_evw
    $error("EVENT_WIDTH (%0d) must be 12..32", EVENT_WIDTH);
  end
  if (EVENT_FIFO_DEPTH < 2 || (EVENT_FIFO_DEPTH & (EVENT_FIFO_DEPTH - 1)) != 0) begin : g_chk_depth
    $error("EVENT_FIFO_DEPTH (%0d) must be a power of two >= 2", EVENT_FIFO_DEPTH);
  end
  if (SYNC_STAGES < 2) begin : g_chk_sync
    $error("SYNC_STAGES (%0d) must be >= 2", SYNC_STAGES);
  end
  if (DEBOUNCE_CYCLES < 1) begin : g_chk_deb
    $error("DEBOUNCE_CYCLES (%0d) must be >= 1", DEBOUNCE_CYCLES);
  end
  if (TICK_DIV < 1) begin : g_chk_tick
    $error("TICK_DIV (%0d) must be >= 1", TICK_DIV);
  end
  if (MAX_PIN_ATTEMPTS < 1) begin : g_chk_att
    $error("MAX_PIN_ATTEMPTS (%0d) must be >= 1", MAX_PIN_ATTEMPTS);
  end
  if (TOGGLE_LIMIT == 1 || TOGGLE_LIMIT < 0 || (TOGGLE_LIMIT >= 2 && TOGGLE_WINDOW < 2)) begin : g_chk_tog
    $error("TOGGLE_LIMIT must be 0 or >=2 and TOGGLE_WINDOW >= 2");
  end

  localparam int ZW       = (NUM_ZONES > 1) ? $clog2(NUM_ZONES) : 1;
  localparam int PTR_W    = $clog2(EVENT_FIFO_DEPTH) + 1;

  //==========================================================================
  // Reset synchronisers (async assert, sync de-assert), one per domain
  //==========================================================================
  // Waiver SYNCASYNCNET: sys_rst_n is deliberately (a) the synchronous-release
  // reset of the sys_clk domain and (b) sampled as a level by u_sysup_sync in
  // HCLK so the configuration is re-pushed after a sys-only reset (RDC handling).
  /* verilator lint_off SYNCASYNCNET */
  logic sensor_rst_n, sys_rst_n, hrst_n;
  /* verilator lint_on SYNCASYNCNET */

  reset_sync #(.STAGES(SYNC_STAGES)) u_rst_sensor (.clk(sensor_clk), .arst_n(sensor_reset_n), .rst_n(sensor_rst_n));
  reset_sync #(.STAGES(SYNC_STAGES)) u_rst_sys    (.clk(sys_clk),    .arst_n(sys_reset_n),    .rst_n(sys_rst_n));
  reset_sync #(.STAGES(SYNC_STAGES)) u_rst_hclk   (.clk(HCLK),       .arst_n(HRESETn),        .rst_n(hrst_n));

  //==========================================================================
  // Sensor domain + sensor -> sys CDC
  //==========================================================================
  logic [NUM_ZONES-1:0] zone_level, zone_event, zone_tfault;

  sensor_front_end #(
    .NUM_ZONES(NUM_ZONES), .SYNC_STAGES(SYNC_STAGES),
    .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES),
    .TOGGLE_LIMIT(TOGGLE_LIMIT), .TOGGLE_WINDOW(TOGGLE_WINDOW)
  ) u_sensors (
    .sensor_clk(sensor_clk), .sensor_rst_n(sensor_rst_n), .sensor_in(sensor_in),
    .sys_clk(sys_clk), .sys_rst_n(sys_rst_n),
    .zone_level(zone_level), .zone_event(zone_event), .zone_tfault(zone_tfault)
  );

  //==========================================================================
  // AHB-Lite slave + register block (HCLK)
  //==========================================================================
  logic        acc_valid, acc_write, acc_commit, acc_ready, acc_err;
  logic [11:0] acc_addr;
  logic [31:0] acc_wdata, acc_rdata;

  ahb_lite_slave u_ahb (
    .HCLK(HCLK), .HRESETn(hrst_n),
    .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HWDATA(HWDATA), .HREADY(HREADY),
    .HRDATA(HRDATA), .HREADYOUT(HREADYOUT), .HRESP(HRESP),
    .acc_valid(acc_valid), .acc_write(acc_write), .acc_addr(acc_addr),
    .acc_wdata(acc_wdata), .acc_commit(acc_commit),
    .acc_ready(acc_ready), .acc_err(acc_err), .acc_rdata(acc_rdata)
  );

  // configuration (HCLK) ------------------------------------------------------
  logic [TIMER_WIDTH-1:0] h_entry, h_exit, h_alarm, h_lockout;
  logic [PIN_WIDTH-1:0]   h_pin;
  logic [NUM_ZONES-1:0]   h_enable, h_bypass;
  logic [3*NUM_ZONES-1:0] h_type;
  logic                   cfg_wr;

  // command channel (HCLK)
  logic                   cmd_req, cmd_ready;
  logic [4:0]             h_cmd_bits;
  logic [NUM_ZONES-1:0]   h_cmd_fclr;

  // status (HCLK view of the sys_clk snapshot)
  logic [2:0]             h_state;
  logic                   h_alarm_act, h_entry_act, h_exit_act, h_locked, h_siren;
  logic [2:0]             h_reason;
  logic [7:0]             h_zone;
  logic [NUM_ZONES-1:0]   h_zone_level, h_zone_fault;
  logic                   cfg_busy;

  // event FIFO reader / IRQ
  logic [31:0]            evt_status, evt_data;
  logic                   evt_pop, clr_ovf;
  logic [IRQ_NUM-1:0]     irq_status, irq_enable, irq_set, irq_w1c_data, irq_enable_data;
  logic                   irq_w1c_en, irq_enable_wr;

  alarm_regs #(.NUM_ZONES(NUM_ZONES), .PIN_WIDTH(PIN_WIDTH), .TIMER_WIDTH(TIMER_WIDTH)) u_regs (
    .HCLK(HCLK), .HRESETn(hrst_n),
    .acc_valid(acc_valid), .acc_write(acc_write), .acc_addr(acc_addr),
    .acc_wdata(acc_wdata), .acc_commit(acc_commit),
    .acc_ready(acc_ready), .acc_err(acc_err), .acc_rdata(acc_rdata),
    .cfg_entry(h_entry), .cfg_exit(h_exit), .cfg_alarm(h_alarm), .cfg_lockout(h_lockout),
    .cfg_pin(h_pin), .cfg_enable(h_enable), .cfg_bypass(h_bypass), .cfg_type(h_type),
    .cfg_wr(cfg_wr),
    .cmd_req(cmd_req), .cmd_bits(h_cmd_bits), .cmd_fault_clr(h_cmd_fclr), .cmd_ready(cmd_ready),
    .st_state(alarm_state_e'(h_state)), .st_alarm_active(h_alarm_act),
    .st_entry_active(h_entry_act), .st_exit_active(h_exit_act),
    .st_locked(h_locked), .st_siren(h_siren), .st_cfg_busy(cfg_busy),
    .st_reason(alarm_reason_e'(h_reason)), .st_zone(h_zone),
    .st_zone_level(h_zone_level), .st_zone_fault(h_zone_fault),
    .evt_status(evt_status), .evt_data(evt_data), .evt_pop(evt_pop), .clr_ovf(clr_ovf),
    .irq_status(irq_status), .irq_enable(irq_enable),
    .irq_w1c_en(irq_w1c_en), .irq_w1c_data(irq_w1c_data),
    .irq_enable_wr(irq_enable_wr), .irq_enable_data(irq_enable_data)
  );

  //==========================================================================
  // Configuration CDC  HCLK -> sys_clk  (REQ/ACK)
  //   'cfg_dirty' is set by any config write, and after every sys_clk reset
  //   release, so both domains always converge on the same configuration.
  //==========================================================================
  localparam int CFG_W = 4*TIMER_WIDTH + PIN_WIDTH + 5*NUM_ZONES;

  localparam logic [CFG_W-1:0] CFG_RESET = {
    {(3*NUM_ZONES){1'b0}},        // types
    {NUM_ZONES{1'b0}},            // bypass
    {NUM_ZONES{1'b0}},            // enable
    PIN_WIDTH'(DEF_PIN),
    TIMER_WIDTH'(DEF_LOCKOUT),
    TIMER_WIDTH'(DEF_ALARM_DUR),
    TIMER_WIDTH'(DEF_EXIT_DELAY),
    TIMER_WIDTH'(DEF_ENTRY_DELAY)
  };

  logic [CFG_W-1:0] cfg_tx, cfg_rx;
  logic             cfg_src_ready, cfg_dirty, cfg_resend;
  logic             cfg_rx_valid_unused;

  assign cfg_tx = {h_type, h_bypass, h_enable, h_pin, h_lockout, h_alarm, h_exit, h_entry};

  always_ff @(posedge HCLK or negedge hrst_n) begin
    if (!hrst_n)                    cfg_dirty <= 1'b1;         // push defaults after reset
    else if (cfg_wr | cfg_resend)   cfg_dirty <= 1'b1;
    else if (cfg_src_ready)         cfg_dirty <= 1'b0;         // accepted this cycle
  end

  assign cfg_busy = cfg_dirty | ~cfg_src_ready;

  req_ack_cdc #(.WIDTH(CFG_W), .SYNC_STAGES(SYNC_STAGES), .DST_RESET_VALUE(CFG_RESET)) u_cfg_cdc (
    .src_clk(HCLK), .src_rst_n(hrst_n), .src_valid(cfg_dirty),
    .src_ready(cfg_src_ready), .src_data(cfg_tx),
    .dst_clk(sys_clk), .dst_rst_n(sys_rst_n),
    .dst_valid(cfg_rx_valid_unused), .dst_data(cfg_rx)
  );

  logic [TIMER_WIDTH-1:0] s_entry, s_exit, s_alarm, s_lockout;
  logic [PIN_WIDTH-1:0]   s_pin;
  logic [NUM_ZONES-1:0]   s_enable, s_bypass;
  logic [3*NUM_ZONES-1:0] s_type;

  assign {s_type, s_bypass, s_enable, s_pin, s_lockout, s_alarm, s_exit, s_entry} = cfg_rx;

  // sys_clk reset status seen from HCLK -> re-push configuration on release
  logic sys_up_h, sys_up_q;
  sync_ff #(.STAGES(SYNC_STAGES)) u_sysup_sync (
    .clk(HCLK), .rst_n(hrst_n), .d(sys_rst_n), .q(sys_up_h)
  );
  always_ff @(posedge HCLK or negedge hrst_n) begin
    if (!hrst_n) sys_up_q <= 1'b0;
    else         sys_up_q <= sys_up_h;
  end
  assign cfg_resend = sys_up_h & ~sys_up_q;

  //==========================================================================
  // Command CDC  HCLK -> sys_clk  (REQ/ACK)   CONTROL + ZONE_FAULT RW1C
  //==========================================================================
  localparam int CMD_W = 5 + NUM_ZONES;

  logic [CMD_W-1:0] cmd_rx;
  logic             cmd_rx_valid;
  logic [4:0]           s_cmd_bits;
  logic [NUM_ZONES-1:0] s_cmd_fclr;

  req_ack_cdc #(.WIDTH(CMD_W), .SYNC_STAGES(SYNC_STAGES)) u_cmd_cdc (
    .src_clk(HCLK), .src_rst_n(hrst_n), .src_valid(cmd_req),
    .src_ready(cmd_ready), .src_data({h_cmd_fclr, h_cmd_bits}),
    .dst_clk(sys_clk), .dst_rst_n(sys_rst_n),
    .dst_valid(cmd_rx_valid), .dst_data(cmd_rx)
  );
  assign {s_cmd_fclr, s_cmd_bits} = cmd_rx;

  //==========================================================================
  // System domain
  //==========================================================================
  logic                   ev_push, ev_ovf_s;
  logic [EVENT_WIDTH-1:0] ev_word;
  alarm_state_e           s_state;
  logic                   s_alarm_act, s_entry_act, s_exit_act, s_locked, s_siren;
  alarm_reason_e          s_reason;
  logic [7:0]             s_zone;
  logic [NUM_ZONES-1:0]   s_zone_level, s_zone_fault;

  alarm_core #(
    .NUM_ZONES(NUM_ZONES), .PIN_WIDTH(PIN_WIDTH), .TIMER_WIDTH(TIMER_WIDTH),
    .EVENT_WIDTH(EVENT_WIDTH), .TICK_DIV(TICK_DIV),
    .MAX_PIN_ATTEMPTS(MAX_PIN_ATTEMPTS), .SW_DISARM_TRUSTED(SW_DISARM_TRUSTED)
  ) u_core (
    .clk(sys_clk), .rst_n(sys_rst_n),
    .zone_level(zone_level), .zone_event(zone_event), .zone_tfault(zone_tfault),
    .cfg_entry(s_entry), .cfg_exit(s_exit), .cfg_alarm(s_alarm), .cfg_lockout(s_lockout),
    .cfg_pin(s_pin), .cfg_enable(s_enable), .cfg_bypass(s_bypass), .cfg_type(s_type),
    .cmd_valid(cmd_rx_valid), .cmd_bits(s_cmd_bits), .cmd_fault_clr(s_cmd_fclr),
    .pin_valid(pin_valid), .pin_code(pin_code),
    .siren(siren), .strobe(strobe), .alarm_active(alarm_active),
    .ev_push(ev_push), .ev_word(ev_word),
    .st_state(s_state), .st_alarm_active(s_alarm_act), .st_entry_active(s_entry_act),
    .st_exit_active(s_exit_act), .st_locked(s_locked), .st_siren(s_siren),
    .st_reason(s_reason), .st_zone(s_zone),
    .st_zone_level(s_zone_level), .st_zone_fault(s_zone_fault)
  );

  //==========================================================================
  // Status snapshot CDC  sys_clk -> HCLK  (continuously refreshed REQ/ACK)
  //==========================================================================
  localparam int ST_W = 19 + 2*NUM_ZONES;

  logic [ST_W-1:0] st_tx, st_rx;
  logic            st_src_ready_unused, st_rx_valid_unused;

  assign st_tx = {s_zone_fault, s_zone_level, s_zone, 3'(s_reason),
                  s_siren, s_locked, s_exit_act, s_entry_act, s_alarm_act, 3'(s_state)};

  req_ack_cdc #(.WIDTH(ST_W), .SYNC_STAGES(SYNC_STAGES)) u_status_cdc (
    .src_clk(sys_clk), .src_rst_n(sys_rst_n), .src_valid(1'b1),
    .src_ready(st_src_ready_unused), .src_data(st_tx),
    .dst_clk(HCLK), .dst_rst_n(hrst_n),
    .dst_valid(st_rx_valid_unused), .dst_data(st_rx)
  );

  assign {h_zone_fault, h_zone_level, h_zone, h_reason,
          h_siren, h_locked, h_exit_act, h_entry_act, h_alarm_act, h_state} = st_rx;

  //==========================================================================
  // Event FIFO  sys_clk -> HCLK
  //==========================================================================
  logic                   f_wfull_unused, f_underflow_unused, f_rempty, f_rinc;
  logic [EVENT_WIDTH-1:0] f_rdata;
  logic [PTR_W-1:0]       f_rcount;
  logic                   ovf_h, avail_rise;

  async_fifo #(.WIDTH(EVENT_WIDTH), .DEPTH(EVENT_FIFO_DEPTH), .SYNC_STAGES(SYNC_STAGES)) u_evt_fifo (
    .wclk(sys_clk), .wrst_n(sys_rst_n), .winc(ev_push), .wdata(ev_word),
    .wfull(f_wfull_unused), .woverflow(ev_ovf_s),
    .rclk(HCLK), .rrst_n(hrst_n), .rinc(f_rinc), .rdata(f_rdata),
    .rempty(f_rempty), .runderflow(f_underflow_unused), .rcount(f_rcount)
  );

  toggle_pulse_sync #(.SYNC_STAGES(SYNC_STAGES)) u_ovf_cdc (
    .src_clk(sys_clk), .src_rst_n(sys_rst_n), .src_pulse(ev_ovf_s),
    .dst_clk(HCLK),    .dst_rst_n(hrst_n),    .dst_pulse(ovf_h)
  );

  event_fifo_reader #(.EVENT_WIDTH(EVENT_WIDTH), .FIFO_DEPTH(EVENT_FIFO_DEPTH)) u_evt_rd (
    .clk(HCLK), .rst_n(hrst_n),
    .rempty(f_rempty), .rcount(f_rcount), .rdata(f_rdata),
    .pop(evt_pop), .ovf_pulse(ovf_h), .clr_ovf(clr_ovf),
    .rinc(f_rinc), .avail_rise(avail_rise),
    .event_status(evt_status), .event_data(evt_data)
  );

  //==========================================================================
  // Interrupts (HCLK).  Persistent conditions from the status snapshot are
  // edge-detected into sticky RW1C status bits.
  //==========================================================================
  logic [IRQ_NUM-1:0] irq_lvl, irq_lvl_q;

  always_comb begin
    irq_lvl = '0;
    irq_lvl[IRQ_ALARM]   = h_alarm_act;
    irq_lvl[IRQ_FIRE]    = h_alarm_act & (alarm_reason_e'(h_reason) == AR_FIRE);
    irq_lvl[IRQ_PANIC]   = h_alarm_act & (alarm_reason_e'(h_reason) == AR_PANIC);
    irq_lvl[IRQ_FAULT]   = (alarm_state_e'(h_state) == ST_FAULT) | (|h_zone_fault);
    irq_lvl[IRQ_LOCKOUT] = h_locked;
  end

  always_ff @(posedge HCLK or negedge hrst_n) begin
    if (!hrst_n) irq_lvl_q <= '0;
    else         irq_lvl_q <= irq_lvl;
  end

  always_comb begin
    irq_set = irq_lvl & ~irq_lvl_q;
    irq_set[IRQ_EVENT] = avail_rise;
  end

  irq_ctrl #(.NUM_IRQ(IRQ_NUM)) u_irq (
    .clk(HCLK), .rst_n(hrst_n),
    .irq_set(irq_set),
    .status_w1c_en(irq_w1c_en), .status_w1c_data(irq_w1c_data),
    .enable_wr_en(irq_enable_wr), .enable_wr_data(irq_enable_data),
    .irq_status(irq_status), .irq_enable(irq_enable), .irq(irq)
  );

  // exit/entry/zone-id/unused snapshot bits and the ZW helper are informational
  logic unused_top;
  assign unused_top = ^{ZW[0], h_zone[0]};

endmodule
