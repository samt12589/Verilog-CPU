// 8-bit cpu
//-------------
module yAdder1(z, cout, a, b, cin);
  
  output z, cout;
  input a, b, cin;
  
  wire outandl, outandr, outxorl;
  
  xor left_xor(outxorl, a,b);
  xor right_xor(z, cin, outxorl);
  and left_and(outandl, a, b);
  and right_and(outandr, outxorl, cin);
  or my_or(cout, outandr, outandl);
endmodule
//---------------------------------
module yAdder(z, cout, a, b, cin);
  
  output [7:0] z;
  output cout;
  
  input [7:0] a, b;
  input cin;
  
  wire [7:0] in, out;
  
  yAdder1 my_adder[7:0](z, out, a, b, in);
  
  assign in[0] = cin;
  assign in[7:1] = out[6:0];
  
  assign cout = out[7]; // line missing in code tell the TA
endmodule
//-------------------------------------------------------
// 2 bit mux
module yMux(z,a,b,c);
  
  parameter SIZE = 2;
  output [SIZE-1:0] z;
  input  [SIZE-1:0] a,b;
  input  [0:0] c;  // single bit
  
  //assigning 
  yMux1 my_mux[SIZE-1:0](z,a,b,c);
  
  // older way delted
endmodule
//--------------------------------------------------------------------

// describing the mux circuit
//ymux1 module
module yMux1(z,a,b,c);
  output z;
  input a,b,c;
  wire notC, upper, lower;
  
  //Gates and connections
  not my_not(notC,c);
  and And1(upper,a,notC);
  and And2(lower,c,b);
  or my_or(z,upper,lower);
endmodule
//-------------------------------------------------------------------
module yMux4to1(z,a0,a1,a2,a3,c);
  parameter SIZE = 2;
  output [SIZE-1:0] z;
  input [SIZE-1:0] a0,a1,a2,a3;
  input[1:0] c;
  wire [SIZE-1:0] zlo ,zhi;
  yMux #(SIZE) lo(zlo, a0, a1, c[0]);
  yMux #(SIZE) hi(zhi, a2, a3, c[0]);
  yMux #(SIZE) final(z, zlo, zhi, c[1]);
endmodule
//------------------------------------------------------------------------
module yArith(z, cout, a, b,ctrl);
 // we are renaming cin to ctrl
  // if ctrl = 0 add
  // if ctrl = 1 sub
  
  output [7:0] z;
  output cout;
  input [7:0] a, b;
  input ctrl;
  wire [7:0] notB, tmp;
  wire cin;
  
  not my_not[7:0](notB, b);
  yMux #(8) mux(tmp, b, notB, ctrl);
  assign cin = ctrl;
  yAdder add(z, cout, a, tmp, cin);
endmodule
//--------------------------------------------------------------------------
// 8 bit ALU with added SLT
module yAlu(z, zero, a, b, op);
  input[7:0] a, b;
  input [2:0] op;
  output [7:0] z;
  output zero;
  
  wire [7:0] zAnd, zOr, zAr, slt;
  wire condition , cout;
  
  // for slt
  assign slt[7:1] = 0; // hard coded ; //SLT
  xor (condition, a[7], b[7]);
  yMux #(1) sltMux(slt[0], zAr[7], a[7], condition);
  
  // other ops
  
  and my_and[7:0](zAnd, a, b);
  or my_or[7:0](zOr, a, b);
  yArith my_arith(zAr, cout, a, b, op[2]);
  yMux4to1 #(8) my_mux(z, zAnd, zOr, zAr, slt, op[1:0]);
  
  // added support for z = 0 for all bits[7;0]
  
  wire z1;
  or or1[0:0](z1, z[7],z[6],z[5],z[4],z[3],z[2],z[1],z[0]);
  not last(zero, z1);
  // we are gonna check is this condition becomes true
endmodule
//------------------------------------------------------------------
