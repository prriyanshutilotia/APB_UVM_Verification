module apb_tb_top;

  // clk + reset
  bit pclk;
  bit presetn;

  // clock generation
  initial pclk = 0;
  always #5 pclk = ~pclk;

  // reset generation (ACTIVE LOW)
  initial begin
    presetn = 0;
    #20 presetn = 1;
  end

  // interface
  apb_interface apb_interface_h(pclk, presetn);

  // DUT
  apb_slave apb_dut(
    .pclk        (apb_interface_h.pclk),
    .presetn     (apb_interface_h.presetn),
    .paddr       (apb_interface_h.paddr),
    .pwdata      (apb_interface_h.pwdata),
    .penable     (apb_interface_h.penable),
    .pwrite      (apb_interface_h.pwrite),
    .pselx       (apb_interface_h.pselx),
    .prdata      (apb_interface_h.prdata),
    .pready      (apb_interface_h.pready),
    .pslave_error(apb_interface_h.pslave_error)
  );

  // TEST selection (UVM style but same structure)
  initial begin
    string test_name;

    uvm_config_db#(virtual apb_interface)::set(uvm_root::get(), "*", "vif", apb_interface_h);

    if ($test$plusargs("WRITE_ONLY"))       test_name = "apb_write_only_test";
    else if ($test$plusargs("READ_ONLY"))   test_name = "apb_read_only_test";
    else if ($test$plusargs("MIXED"))       test_name = "apb_mixed_test";
    else                                    test_name = "apb_write_read_test"; // default

    run_test(test_name);
  end

  // END + REPORT
  initial begin
    #5000;

    apb_scoreboard::final_report();

    if (!apb_scoreboard::all_passed())
      $fatal(1, "TEST FAILED: Scoreboard detected mismatches");

    $finish;
  end

endmodule
