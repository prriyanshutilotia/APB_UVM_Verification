module apb_slave #(
  parameter int addr_width = 3,
  parameter int data_width = 3
)(
  input  logic                  pclk,
  input  logic                  presetn,

  input  logic [addr_width-1:0] paddr,
  input  logic [data_width-1:0] pwdata,
  output logic [data_width-1:0] prdata,

  input  logic                  pwrite,
  input  logic                  pselx,
  input  logic                  penable,

  output logic                  pready,
  output logic                  pslave_error
);

  logic [data_width-1:0] mem [0:(1<<addr_width)-1];
  int unsigned wait_left;
  integer i;

  // Address all-1s (3'b111 = 7) is treated as an error address.
  wire error_addr = (paddr == {addr_width{1'b1}});

  // APB transfer completes only when ready is high in ACCESS phase.
  wire xfer = pselx && penable && pready;

  /*
   * Wait-state generation:
   * paddr[1:0] decides the number of waits.
   *
   * addr 0,4 -> 0 waits
   * addr 1,5 -> 1 wait
   * addr 2,6 -> 2 waits
   * addr 3,7 -> 3 waits
   */
  assign pready = (!pselx || !penable) ? 1'b1 :
                  (wait_left == 0);

  // PSLVERR is valid only at transfer completion.
  assign pslave_error = xfer && error_addr;

  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      prdata     <= '0;
      wait_left  <= 0;

      for (i = 0; i < (1 << addr_width); i++)
        mem[i] <= '0;

    end else begin

      // SETUP phase: decide wait-state count for this request.
      if (pselx && !penable) begin
        wait_left <= paddr[1:0];
      end

      // ACCESS phase while slave is not ready.
      else if (pselx && penable && !pready) begin
        wait_left <= wait_left - 1;
      end

      // Completed transfer.
      else if (xfer) begin
        wait_left <= 0;

        // Error address has no memory operation.
        if (!error_addr) begin
          if (pwrite)
            mem[paddr] <= pwdata;
          else
            prdata <= mem[paddr];
        end
        else if (!pwrite) begin
          prdata <= '0;
        end
      end

      // Idle
      else begin
        wait_left <= 0;
      end
    end
  end

endmodule
