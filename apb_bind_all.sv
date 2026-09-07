//======================================================
// Bind APB assertions + coverage into apb_tb_top (NOT interface)
//======================================================

// Bind assertions into the TB top and hook up to interface instance signals
bind apb_tb_top apb_assert_checker #( .ADDR_W(3), .DATA_W(3)) 

apb_assert_i (
  .pclk         (apb_interface_h.pclk),
  .presetn      (apb_interface_h.presetn),
  .pselx        (apb_interface_h.pselx),
  .penable      (apb_interface_h.penable),
  .pwrite       (apb_interface_h.pwrite),
  .pready       (apb_interface_h.pready),
  .pslave_error (apb_interface_h.pslave_error),
  .paddr        (apb_interface_h.paddr),
  .pwdata       (apb_interface_h.pwdata),
  .prdata       (apb_interface_h.prdata)
);

// Bind coverage into the TB top and hook up to interface instance signals
bind apb_tb_top apb_cov_collector #( .ADDR_W(3), .DATA_W(3)) 

apb_cov_i (
  .pclk         (apb_interface_h.pclk),
  .presetn      (apb_interface_h.presetn),
  .pselx        (apb_interface_h.pselx),
  .penable      (apb_interface_h.penable),
  .pwrite       (apb_interface_h.pwrite),
  .pready       (apb_interface_h.pready),
  .pslave_error (apb_interface_h.pslave_error),
  .paddr        (apb_interface_h.paddr),
  .pwdata       (apb_interface_h.pwdata),
  .prdata       (apb_interface_h.prdata)
);

