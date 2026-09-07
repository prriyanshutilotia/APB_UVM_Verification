`define DRIVER_INTF apb_interface_vh.driver_cb

class apb_driver extends uvm_driver#(apb_sequence_item);
  `uvm_component_utils(apb_driver)

  apb_sequence_item     tx;
  virtual apb_interface apb_interface_vh;

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface)::get(this,"","vif",apb_interface_vh))
      `uvm_fatal("NOVIF","Virtual interface not set for apb_driver")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tx);
      driver_logic();
      seq_item_port.item_done();
    end
  endtask


  task driver_logic();

    // SETUP
    @(apb_interface_vh.driver_cb);
    `DRIVER_INTF.pselx   <= 1;
    `DRIVER_INTF.penable <= 0;
    `DRIVER_INTF.paddr   <= tx.paddr;
    `DRIVER_INTF.pwrite  <= tx.pwrite;
    if (tx.pwrite) `DRIVER_INTF.pwdata <= tx.pwdata;

// ACCESS phase
@(apb_interface_vh.driver_cb);
`DRIVER_INTF.penable <= 1;

// At least one ACCESS clock must occur before checking PREADY.
// This lets the DUT insert wait states correctly.
do begin
  @(apb_interface_vh.driver_cb);
end while (`DRIVER_INTF.pready !== 1);

// Transfer completes only after PREADY is 1.
if (!tx.pwrite)
  tx.prdata = `DRIVER_INTF.prdata;

tx.pready       = `DRIVER_INTF.pready;
tx.pslave_error = `DRIVER_INTF.pslave_error;

// Next clock: IDLE phase
//@(apb_interface_vh.driver_cb);
`DRIVER_INTF.pselx   <= 0;
`DRIVER_INTF.penable <= 0;

  endtask

endclass
