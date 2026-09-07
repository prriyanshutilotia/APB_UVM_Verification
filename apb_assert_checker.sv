//======================================================
// APB Assertions Checker (bindable) - CLEAN VERSION
//======================================================
module apb_assert_checker #(
  parameter int ADDR_W = 3,
  parameter int DATA_W = 3
)(
  input  logic              pclk,
  input  logic              presetn,

  input  logic              pselx,
  input  logic              penable,
  input  logic              pwrite,
  input  logic              pready,
  input  logic              pslave_error,

  input  logic [ADDR_W-1:0] paddr,
  input  logic [DATA_W-1:0] pwdata,
  input  logic [DATA_W-1:0] prdata
);

  default clocking cb @(posedge pclk); endclocking
  default disable iff (!presetn);

  // ----------------------------------------
  // Small helper macro to avoid repetition
  // ----------------------------------------
  `define APB_ASSERT(NAME, PROP, MSG) \
  NAME: assert property (PROP) else $error(MSG);

  // ----------------------------------------
  // PHASE RULES
  // ----------------------------------------

  // PENABLE must only happen with PSEL
  property P_ENABLE_ONLY_WITH_PSEL;
    penable |-> pselx;
  endproperty

  // Setup (PSEL=1, PENABLE=0) must go to Enable next cycle
  property P_SETUP_TO_ENABLE;
    (pselx && !penable) |=> (pselx && penable);
  endproperty

  // During ENABLE wait-states, addr/control stable
  property P_STABLE_ADDR_CTRL_DURING_WAIT;
    (pselx && penable && !pready) |-> $stable({paddr, pwrite});
  endproperty

  // During ENABLE wait-states, write data stable on WRITE
  property P_STABLE_WDATA_DURING_WAIT;
    (pselx && penable && pwrite && !pready) |-> $stable(pwdata);
  endproperty

  // After completion, PENABLE must drop next cycle
  property P_COMPLETE_DROPS_PENABLE;
    (pselx && penable && pready) |=> !penable;
  endproperty

  // Strong rule: keep PSEL high during ENABLE until ready
  property P_PSEL_STAYS_HIGH_UNTIL_READY;
    (pselx && penable && !pready) |=> (pselx && penable);
  endproperty


  // ----------------------------------------
  // ASSERT INSTANTIATIONS (NEAT LIST)
  // ----------------------------------------
  `APB_ASSERT(A1_ENABLE_WITH_PSEL,      P_ENABLE_ONLY_WITH_PSEL, "APB: PENABLE=1 while PSEL=0")
  `APB_ASSERT(A2_SETUP_TO_ENABLE,       P_SETUP_TO_ENABLE, "APB: SETUP did not transition to ENABLE")
  `APB_ASSERT(A3_STABLE_ADDR_CTRL_WAIT, P_STABLE_ADDR_CTRL_DURING_WAIT, "APB: PADDR/PWRITE changed during ENABLE wait-state")
  `APB_ASSERT(A4_STABLE_WDATA_WAIT,     P_STABLE_WDATA_DURING_WAIT, "APB: PWDATA changed during WRITE ENABLE wait-state")
  `APB_ASSERT(A5_COMPLETE_DROP_PEN,     P_COMPLETE_DROPS_PENABLE, "APB: PENABLE did not drop after completion")
  `APB_ASSERT(A6_PSEL_STAYS_HIGH,       P_PSEL_STAYS_HIGH_UNTIL_READY, "APB: PSEL dropped during ENABLE wait-state")

  `undef APB_ASSERT

endmodule



