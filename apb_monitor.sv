`define MONITOR_INTF apb_interface_vh.monitor_cb

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  uvm_analysis_port #(apb_sequence_item) mon_port;

  apb_sequence_item     tx;
  virtual apb_interface apb_interface_vh;

  // Functional coverage
  covergroup apb_cg;
    option.per_instance = 1;

    cp_addr  : coverpoint tx.paddr {
      bins a[] = {[0:7]};
    }

    cp_write : coverpoint tx.pwrite {
      bins WR = {1};
      bins RD = {0};
    }

    cp_wdata : coverpoint tx.pwdata iff (tx.pwrite) {
      bins d[] = {[0:7]};
    }

    cp_rdata : coverpoint tx.prdata iff (!tx.pwrite) {
      bins d[] = {[0:7]};
    }

    cp_err : coverpoint tx.pslave_error {
      bins OK  = {0};
      bins ERR = {1};
    }

    cx_addr_rw : cross cp_addr, cp_write;
  endgroup

  function new(string name="apb_monitor", uvm_component parent=null);
    super.new(name, parent);

    mon_port = new("mon_port", this);
    apb_cg   = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_interface)::get(
          this, "", "vif", apb_interface_vh))
      `uvm_fatal("NOVIF", "Virtual interface not set for apb_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      tx = apb_sequence_item::type_id::create("tx");
      monitor_logic();
    end
  endtask

  task monitor_logic();

    // Wait for a new APB SETUP phase.
    // This avoids collecting the same completed transfer twice.
    do @(apb_interface_vh.monitor_cb);
    while (!(`MONITOR_INTF.pselx && !`MONITOR_INTF.penable));

    // Wait for completion of that transaction.
    do @(apb_interface_vh.monitor_cb);
    while (!(`MONITOR_INTF.pselx &&
              `MONITOR_INTF.penable &&
              `MONITOR_INTF.pready));

    // Capture completed transaction.
    tx.paddr        = `MONITOR_INTF.paddr;
    tx.pwrite       = `MONITOR_INTF.pwrite;
    tx.pwdata       = `MONITOR_INTF.pwdata;
    tx.pready       = `MONITOR_INTF.pready;
    tx.pslave_error = `MONITOR_INTF.pslave_error;

    if (tx.pwrite)
      tx.prdata = '0;
    else
      tx.prdata = `MONITOR_INTF.prdata;

    apb_cg.sample();
    mon_port.write(tx);

  endtask

endclass
