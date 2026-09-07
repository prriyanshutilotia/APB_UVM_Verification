class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  // UVM way: monitor writes into analysis port -> scoreboard receives in write()
  uvm_analysis_imp #(apb_sequence_item, apb_scoreboard) scb_port;

  // Queue as buffer (like mailbox)
  apb_sequence_item tx_queue[$];

  // Reference memory model (3-bit mem => 8 locations)
  bit [2:0] exp_mem [0:7];

  // Make counters static so tb_top can check result easily
  static int total_tx;
  static int pass_cnt;
  static int fail_cnt;

  function new(string name="apb_scoreboard", uvm_component parent=null);
    super.new(name,parent);
scb_port = new("scb_port", this);

    total_tx = 0;
    pass_cnt = 0;
    fail_cnt = 0;

    for (int i = 0; i < 8; i++) exp_mem[i] = '0;
  endfunction


  // ----------------------------
  // write() gets called automatically when monitor does mon_port.write(tx)
  // ----------------------------
  virtual function void write(apb_sequence_item tx);
    tx_queue.push_back(tx);
  endfunction

  // ----------------------------
  // Main scoreboard task (use run_phase in UVM)
  // ----------------------------
  task run_phase(uvm_phase phase);
  

    forever begin
      apb_sequence_item tx;
      wait (tx_queue.size() > 0);

      tx = tx_queue.pop_front();
      total_tx++;

    // PSLVERR check
if (tx.pslave_error) begin
  if (tx.paddr == 3'b111) begin
    pass_cnt++;
    $display("[SCB][%0t] EXPECTED ERROR PASS: addr=%0d | pass=%0d fail=%0d total=%0d",
             $time, tx.paddr, pass_cnt, fail_cnt, total_tx);
  end
  else begin
    fail_cnt++;
    $display("[SCB][%0t] UNEXPECTED PSLVERR: addr=%0d | pass=%0d fail=%0d total=%0d",
             $time, tx.paddr, pass_cnt, fail_cnt, total_tx);
  end
  continue;
end 

      // WRITE: update expected memory
      if (tx.pwrite) begin
        exp_mem[tx.paddr] = tx.pwdata;
        pass_cnt++;
        $display("[SCB][%0t] WRITE PASS: addr=%0d data=%0d | pass=%0d fail=%0d total=%0d",
                 $time, tx.paddr, tx.pwdata, pass_cnt, fail_cnt, total_tx);

      end else begin
        // READ: compare with expected memory
        if (tx.prdata === exp_mem[tx.paddr]) begin
          pass_cnt++;
          $display("[SCB][%0t] READ  PASS: addr=%0d exp=%0d got=%0d | pass=%0d fail=%0d total=%0d",
                   $time, tx.paddr, exp_mem[tx.paddr], tx.prdata, pass_cnt, fail_cnt, total_tx);
        end else begin
          fail_cnt++;
          $display("[SCB][%0t] READ  FAIL: addr=%0d exp=%0d got=%0d | pass=%0d fail=%0d total=%0d",
                   $time, tx.paddr, exp_mem[tx.paddr], tx.prdata, pass_cnt, fail_cnt, total_tx);
          tx.print();
        end
      end
    end
  endtask

  // ----------------------------
  // Final result helpers
  // ----------------------------
  static function bit all_passed();
    return (fail_cnt == 0);
  endfunction

  static function void final_report();
    $display("\n==================================================");
    $display("                APB SCOREBOARD SUMMARY            ");
    $display("==================================================");
    $display("TOTAL TX  : %0d", total_tx);
    $display("PASS CNT  : %0d", pass_cnt);
    $display("FAIL CNT  : %0d", fail_cnt);

    if (fail_cnt == 0)
      $display("FINAL     : TEST PASSED ✅");
    else
      $display("FINAL     : TEST FAILED ❌");

    $display("==================================================\n");
  endfunction

endclass

