vlog -work work -vopt -sv -stats=none P:/New_APB/Student_APB/APB_UVM/apb_top.svh
vsim -voptargs=+acc work.apb_tb_top +WRITE_ONLY -l write_only.log
vsim -voptargs=+acc work.apb_tb_top +READ_ONLY -l read_only.log
vsim -voptargs=+acc work.apb_tb_top +MIXED       -l mixed.log
vsim -voptargs=+acc work.apb_tb_top +WR_RD       -l mixed.log
add wave -position insertpoint sim:/apb_tb_top/apb_interface_h/*
run -all

