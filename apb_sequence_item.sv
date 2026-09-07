class apb_sequence_item extends uvm_sequence_item;

  // -------------------------
  // DUT inputs
  // -------------------------
  rand bit [2:0] paddr;
  rand bit [2:0] pwdata;
  rand bit       pwrite;
       bit       pselx;
       bit       penable;

  // -------------------------
  // DUT outputs
  // -------------------------
       bit [2:0] prdata;
       bit       pready;
       bit       pslave_error;

  // -------------------------
  // Constraints
  // -------------------------
  constraint c_addr_legal   { paddr  inside {[0:7]}; }
  constraint c_data_legal   { pwdata inside {[0:7]}; }
  constraint c_rw_balance   { soft pwrite dist {1:=50, 0:=50}; }

  // -------------------------
  // Constructor
  // -------------------------
  function new(string name="apb_sequence_item");
    super.new(name);
  endfunction

  // -------------------------
  // Factory + field automation
  // -------------------------
  `uvm_object_utils_begin(apb_sequence_item)
    `uvm_field_int(paddr,        UVM_ALL_ON)
    `uvm_field_int(pwdata,       UVM_ALL_ON)
    `uvm_field_int(pwrite,       UVM_ALL_ON)
    `uvm_field_int(pselx,        UVM_ALL_ON)
    `uvm_field_int(penable,      UVM_ALL_ON)
    `uvm_field_int(prdata,       UVM_ALL_ON)
    `uvm_field_int(pready,       UVM_ALL_ON)
    `uvm_field_int(pslave_error, UVM_ALL_ON)
  `uvm_object_utils_end

endclass

