`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 16:14:03
// Design Name: 
// Module Name: SignExtend
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


module SignExtend (
    input [15:0] immediate_in,    // 16位输入
    output [31:0] extended_out    // 32位输出
);

    // 符号扩展逻辑
    assign extended_out = {{16{immediate_in[15]}}, immediate_in};

endmodule

