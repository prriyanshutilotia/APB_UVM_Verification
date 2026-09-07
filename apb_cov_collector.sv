
//======================================================
// APB Coverage Collector (bindable)
//======================================================
module apb_cov_collector #(
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

  // Wait-state counter (for coverage bins)
  int unsigned wait_cycles;

  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      wait_cycles <= 0;
    end else begin
      if (pselx && penable && !pready)
        wait_cycles <= wait_cycles + 1;
      else if (pselx && penable && pready)
        wait_cycles <= 0;
      else if (!penable)
        wait_cycles <= 0;
    end
  end

  // Sample only on successful completion: (PSEL && PENABLE && PREADY)
  covergroup apb_cg @(posedge pclk);
    option.per_instance = 1;

    cp_rw: coverpoint pwrite iff (pselx && penable && pready) {
      bins READ  = {0};
      bins WRITE = {1};
    }

    cp_addr: coverpoint paddr iff (pselx && penable && pready) {
      bins all_addr[] = {[0:(2**ADDR_W)-1]};
    }

    cp_waits: coverpoint wait_cycles iff (pselx && penable && pready) {
      bins no_wait = {0};
      bins w1      = {1};
      bins w2      = {2};
      bins w3plus  = {[3:$]};
    }

    cp_err: coverpoint pslave_error iff (pselx && penable && pready) {
      bins ok  = {0};
      bins err = {1};
    }

    cross_rw_addr: cross cp_rw, cp_addr;
    cross_rw_wait: cross cp_rw, cp_waits;
    cross_rw_err : cross cp_rw, cp_err;
  endgroup

  apb_cg cg = new();

endmodule
