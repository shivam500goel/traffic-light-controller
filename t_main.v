`timescale 100ms/1ms
`include "main.v"
module t_main;
wire R1,O1,G1;
wire R2,O2,G2;
wire R3,O3,G3;
wire R4,O4,G4;
reg t1,t2,t3,t4,clk,reset;

main_module Q1(R1,O1,G1,R2,O2,G2,R3,O3,G3,R4,O4,G4,t1,t2,t3,t4,clk,reset);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,t_main);
    clk=1'b0;
end
always #5 clk=(!clk);
initial #5000 $finish;

initial fork
t1=1'b1;
t2=1'b1;
t3=1'b1;
t4=1'b1;
reset = 1'b0;
#2 reset = 1'b1;
#200 t1=1'b0;
#2000 t4=1'b0;
#3000 t2=1'b0;
#3000 t3=1'b0;
#3600 t1=1'b1;
#4400 t3=1'b1;
join
endmodule