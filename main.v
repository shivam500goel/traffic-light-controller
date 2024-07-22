module mux_4_to_1(
    output reg Y,
    input [3:0] X,
    input [1:0] select 
);
always @(X,select)
case(select)
2'b00: Y=X[0];
2'b01: Y=X[1];
2'b10: Y=X[2];
2'b11: Y=X[3];
endcase
endmodule

module de_mux_1_to_4(
    output reg [3:0] Y,
    input X,
    input [1:0] select 
);
always @(X,select)
case(select)
2'b00: begin Y[0]=X;{Y[1],Y[2],Y[3]}=3'b000; end
2'b01: begin Y[1]=X;{Y[0],Y[2],Y[3]}=3'b000; end
2'b10: begin Y[2]=X;{Y[1],Y[0],Y[3]}=3'b000; end
2'b11: begin Y[3]=X;{Y[1],Y[2],Y[0]}=3'b000; end
endcase
endmodule

module de_mux_1_to_4_rev(
    output reg [3:0] Y,
    input X,
    input [1:0] select 
);
always @(X,select)
case(select)
2'b00: begin Y[0]=(!X);{Y[1],Y[2],Y[3]}=3'b111; end
2'b01: begin Y[1]=(!X);{Y[0],Y[2],Y[3]}=3'b111; end
2'b10: begin Y[2]=(!X);{Y[1],Y[0],Y[3]}=3'b111; end
2'b11: begin Y[3]=(!X);{Y[1],Y[2],Y[0]}=3'b111; end
endcase
endmodule

module counter_60(
    output reg next,R,O,G,
    input T,clk,reset
);
reg [5:0] state;
always @(posedge clk,negedge reset)
if (reset==1'b0) begin state<=6'b000000; end
else begin
    if (state>=6'b000000 && state<6'b110110) begin
        if(T==1'b1) state<=state+6'b000001;
        else state<=6'b110110; end
    else if (state==6'b110110) state<=state+6'b000001;
    else if (state>=6'b110111 && state<=6'b111010) state<=state+6'b000001;
    else if (state>=6'b111011) state<=6'b000000;
end

always @(state)
if (state>=6'b000000 && state<=6'b110110) begin
    G=1'b1;R=1'b1;O=1'b0;next=1'b0;end
else if (state>=6'b110111 && state<=6'b111010)begin
    G=1'b0;R=1'b1;O=1'b1;next=1'b0;end
else if (state>=6'b111011)begin
    G=1'b0;R=1'b1;O=1'b1;next=1'b1;end
endmodule

module traffic_side(
    output reg [1:0] side,
    input next,t1,t2,t3,t4,clk,reset
);
always @(posedge clk,negedge reset)
if (reset==1'b0) side<=2'b00;
else 
case (side)
2'b00: if (next==1'b0) side<=2'b00;else begin
    if (t2==1'b1) side<=2'b01;
    else if (t3==1'b1) side<=2'b10;
    else if (t4==1'b1) side<=2'b11;
 end
2'b01: if (next==1'b0) side<=2'b01;else begin
    if (t3==1'b1) side<=2'b10;
    else if (t4==1'b1) side<=2'b11;
    else if (t1==1'b1) side<=2'b00;
 end
2'b10: if (next==1'b0) side<=2'b10;else begin
    if (t4==1'b1) side<=2'b11;
    else if (t1==1'b1) side<=2'b00;
    else if (t2==1'b1) side<=2'b01;
 end
2'b11: if (next==1'b0) side<=2'b11;else begin
    if (t1==1'b1) side<=2'b00;
    else if (t2==1'b1) side<=2'b01;
    else if (t3==1'b1) side<=2'b10;
 end
endcase
endmodule

module main_module(
    output R1,O1,G1,
    output R2,O2,G2,
    output R3,O3,G3,
    output R4,O4,G4,
    input t1,t2,t3,t4,clk,reset
);
wire [1:0] side;
wire next,R,G,O,T;

mux_4_to_1 M1(T,{t4,t3,t2,t1},side);
de_mux_1_to_4 D1({G4,G3,G2,G1},G,side);
de_mux_1_to_4 D2({O4,O3,O2,O1},O,side);
de_mux_1_to_4_rev V1({R4,R3,R2,R1},R,side);

traffic_side T1(side,next,t1,t2,t3,t4,clk,reset);
counter_60 C1(next,R,O,G,T,clk,reset);
endmodule