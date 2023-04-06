// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/ECS/data/hdlMacro/verilog/CB16CE.v,v 1.4 2012/08/30 17:45:42 robh Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2006 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor      : Xilinx
// \   \   \/     Version     : Jade (J.23)
//  \   \         Description : Xilinx HDL Macro Library
//  /   /                       16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
// /___/   /\     Filename    : CB16CE.v
// \   \  /  \    Timestamp   : Tue Jul 25 2006
//  \___\/\___\
//
// Revision:
//    07/25/06 - Initial version.
// End Revision

`timescale 100 ps / 10 ps

module CB16CE(CEO, Q, TC, C, CE, CLR);
   
   localparam TERMINAL_COUNT = 16'b1111_1111_1111_1111;
   
   output             CEO;
   output [15:0]      Q;
   output             TC;

   input 	      C;	
   input 	      CE;	
   input 	      CLR;	
   
   reg    [15:0]      Q;
   
   always @(posedge C or posedge CLR)
     begin
	if (CLR)
	  Q <= 16'b0000_0000_0000_0000;
	else if (CE)
	  Q <= Q + 1;
     end
   
   assign CEO = TC & CE;
   assign TC = (Q == TERMINAL_COUNT);
   
endmodule
