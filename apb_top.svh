////////////////////////////////////////
//arrange the file in the independent to dependent order
//<-------------------------------------independet to dependent order 
//tb_top
//	test
//		seq
//			seq_item
//		env
//			scb
//			agent
//				seqr
//				drv	
//				mon
//	intf
//	dut
////////////////////////////////////////
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "apb_assert_checker.sv"
`include "apb_cov_collector.sv"
`include "apb_bind_all.sv"

`include "apb_interface.sv"
`include "apb_sequence_item.sv"
`include "apb_sequence.sv"
`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"
`include "apb_scoreboard.sv"
`include "apb_env.sv"
`include "apb_test.sv"
`include "apb_dut.sv"
`include "apb_tb_top.sv"

