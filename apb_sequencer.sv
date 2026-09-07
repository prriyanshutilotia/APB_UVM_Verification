//Factroy Registration
class apb_sequencer extends uvm_sequencer#(apb_sequence_item);
`uvm_component_utils(apb_sequencer)

//inheritance constructor calling
function new(string name,uvm_component parent);
super.new(name,parent);
endfunction

endclass

//or Default FIFO Style arbitration is followed rest of coding is taken care
//in lib we can change the arbitration scheme via set and get arbitration from
//the test file/env file 

//typedef uvm_sequencer#(apb_sequence) apb_sequencer;
//

