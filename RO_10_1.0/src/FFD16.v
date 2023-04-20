`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2023 01:14:45 PM
// Design Name: 
// Module Name: FFD16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FFD16(
    input [15:0] q,
    input c,
    output [15:0] d
    );
    
    (* dont_touch = "true" *) FD FD0(.D(q[0]), .C(c), .Q(d[0]));
    (* dont_touch = "true" *) FD FD1(.D(q[1]), .C(c), .Q(d[1]));
    (* dont_touch = "true" *) FD FD2(.D(q[2]), .C(c), .Q(d[2]));
    (* dont_touch = "true" *) FD FD3(.D(q[3]), .C(c), .Q(d[3]));
    (* dont_touch = "true" *) FD FD4(.D(q[4]), .C(c), .Q(d[4]));
    (* dont_touch = "true" *) FD FD5(.D(q[5]), .C(c), .Q(d[5]));
    (* dont_touch = "true" *) FD FD6(.D(q[6]), .C(c), .Q(d[6]));
    (* dont_touch = "true" *) FD FD7(.D(q[7]), .C(c), .Q(d[7]));
    (* dont_touch = "true" *) FD FD8(.D(q[8]), .C(c), .Q(d[8]));
    (* dont_touch = "true" *) FD FD9(.D(q[9]), .C(c), .Q(d[9]));
    (* dont_touch = "true" *) FD FD10(.D(q[10]), .C(c), .Q(d[10]));
    (* dont_touch = "true" *) FD FD11(.D(q[11]), .C(c), .Q(d[11]));
    (* dont_touch = "true" *) FD FD12(.D(q[12]), .C(c), .Q(d[12]));
    (* dont_touch = "true" *) FD FD13(.D(q[13]), .C(c), .Q(d[13]));
    (* dont_touch = "true" *) FD FD14(.D(q[14]), .C(c), .Q(d[14]));
    (* dont_touch = "true" *) FD FD15(.D(q[15]), .C(c), .Q(d[15]));
    
endmodule
