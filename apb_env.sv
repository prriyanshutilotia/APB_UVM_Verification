class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_agent      apb_agent_h;
  apb_scoreboard apb_scoreboard_h;

  function new(string name="apb_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agent_h      = apb_agent     ::type_id::create("apb_agent_h", this);
    apb_scoreboard_h = apb_scoreboard::type_id::create("apb_scoreboard_h", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb_agent_h.apb_monitor_h.mon_port.connect(apb_scoreboard_h.scb_port);
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("ENV", "apb_env run_phase (UVM auto-runs components)", UVM_LOW)
  endtask

endclass
