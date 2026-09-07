// IMPORTANT: define this enum only ONCE in the whole project
typedef enum int {WR_RD=0, WRITE_ONLY=1, READ_ONLY=2, MIXED=3} gen_mode_e;


class apb_sequence extends uvm_sequence #(apb_sequence_item);
  `uvm_object_utils(apb_sequence)

  int        repeat_count = 200;
  gen_mode_e mode = WR_RD;

  apb_sequence_item tx;

  function new(string name="apb_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (repeat_count) begin
      case (mode)

        WR_RD: begin
          // WRITE
          tx = apb_sequence_item::type_id::create("tx");
          start_item(tx);//wait_for_grant();
          assert(tx.randomize() with { pwrite == 1; });
          finish_item(tx);//send_request(tx) and wait_for_item_done
          tx.print();

          // READ
          tx = apb_sequence_item::type_id::create("tx"); //or tx=new();
	  
          wait_for_grant();
          assert(tx.randomize() with { pwrite == 0; });
          send_request(tx);
	  wait_for_item_done();
          tx.print();
        end

        WRITE_ONLY: begin
          tx = apb_sequence_item::type_id::create("tx");
          start_item(tx);
          assert(tx.randomize() with { pwrite == 1; });
          finish_item(tx);
          tx.print();
        end

        READ_ONLY: begin
          tx = apb_sequence_item::type_id::create("tx");
          start_item(tx);
          assert(tx.randomize() with { pwrite == 0; });
          finish_item(tx);
          tx.print();
        end

        MIXED: begin
          tx = apb_sequence_item::type_id::create("tx");
          start_item(tx);
          assert(tx.randomize());
          finish_item(tx);
          tx.print();
        end

      endcase
    end
  endtask

endclass


//body coding of sequence can be done in anyway one of the following ways 
//1.5 steps method
//create
//wait_for_grant
//tx.randomize
//send_request(tx)
//wait_for_item_done

//2.4 steps method
//create
//start_item(tx)
//tx.randomize
//finsih_item(tx)

//3. 1 step method
//`uvm_do_*

