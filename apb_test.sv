

// -----------------------------------------------------
// BASE TEST  (same idea as SV apb_base_test)
// -----------------------------------------------------
class apb_base_test extends uvm_test;
  `uvm_component_utils(apb_base_test)

  apb_env     apb_env_h;
  apb_sequence apb_seq_h;

  gen_mode_e  mode;   // ✅ same as SV generator mode

  function new(string name="apb_base_test", uvm_component parent=null);
    super.new(name,parent);
    mode = WR_RD; // default
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    apb_env_h = apb_env::type_id::create("apb_env_h", this);
    apb_seq_h = apb_sequence::type_id::create("apb_seq_h");
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    print();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // ✅ like SV: env.generator.mode = ...
    apb_seq_h.mode = mode;

    // ✅ like SV: env.run()
    apb_seq_h.start(apb_env_h.apb_agent_h.apb_sequencer_h);

    phase.drop_objection(this);
  endtask
endclass


// -----------------------------------------------------
// Derived tests (look same as SV: set mode then super.run())
// -----------------------------------------------------
class apb_write_read_test extends apb_base_test;
  `uvm_component_utils(apb_write_read_test)

  function new(string name="apb_write_read_test", uvm_component parent=null);
    super.new(name,parent);
    mode = WR_RD;
  endfunction
endclass


class apb_write_only_test extends apb_base_test;
  `uvm_component_utils(apb_write_only_test)

  function new(string name="apb_write_only_test", uvm_component parent=null);
    super.new(name,parent);
    mode = WRITE_ONLY;
  endfunction
endclass


class apb_read_only_test extends apb_base_test;
  `uvm_component_utils(apb_read_only_test)

  function new(string name="apb_read_only_test", uvm_component parent=null);
    super.new(name,parent);
    mode = READ_ONLY;
  endfunction
endclass


class apb_mixed_test extends apb_base_test;
  `uvm_component_utils(apb_mixed_test)

  function new(string name="apb_mixed_test", uvm_component parent=null);
    super.new(name,parent);
    mode = MIXED;
  endfunction
endclass

