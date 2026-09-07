interface apb_interface(input logic pclk,presetn);
logic  [2:0] paddr;
logic  [2:0] pwdata;
logic  penable ;
logic  pwrite;
logic  pselx;
logic  [2:0] prdata;
logic  pready;
logic  pslave_error;


//clocking block=direction(sync signal)+setup_hold_time
//modport block =direction(async signal)



clocking driver_cb @(posedge pclk);
default input #1 output #1;
output paddr;
output pwdata;
output penable;
output pwrite;
output pselx;
input prdata;
input pready;
input pslave_error;
endclocking

clocking monitor_cb @(posedge pclk);
default input #1 output #1;
input paddr;
input pwdata;
input penable;
input pwrite;
input pselx;
input prdata;
input pready;
input pslave_error;
endclocking

modport DRIVER (clocking driver_cb,input pclk,presetn);
modport MONITOR(clocking monitor_cb,input pclk,presetn);
endinterface

