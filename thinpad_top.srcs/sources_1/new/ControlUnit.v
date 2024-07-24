`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 16:26:26
// Design Name: 
// Module Name: ControlUnit
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

module ControlUnit (
    input wire [5:0] op,
    input wire [5:0] funct,

    output wire memtoreg,
    output wire memwrite,
    output wire branch,
    output wire alusrc,
    output wire regdst,
    output wire regwrite,
    output wire [2:0] alucontrol
);

    reg [7:0] controls;
    wire [1:0] aluop;

    // Main decoder logic
    always @(*) begin
        case (op)
            6'b000000: controls <= 8'b11000010; // R-TYPE
            6'b100011: controls <= 8'b10100100; // LW
            6'b101011: controls <= 8'b00101000; // SW
            6'b000100: controls <= 8'b00010001; // BEQ
            6'b001000: controls <= 8'b10100000; // ADDI
            default:   controls <= 8'b00000000; // illegal op
        endcase
    end

    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, aluop} = controls;

    // ALU decoder logic
    reg [2:0] alucontrol_reg;
    always @(*) begin
        case (aluop)
            2'b00: alucontrol_reg <= 3'b010; // add (for lw/sw/addi)
            2'b01: alucontrol_reg <= 3'b110; // sub (for beq)
            default: case (funct)
                6'b100000: alucontrol_reg <= 3'b010; // add
                6'b100010: alucontrol_reg <= 3'b110; // sub
                6'b100100: alucontrol_reg <= 3'b000; // and
                6'b100101: alucontrol_reg <= 3'b001; // or
                6'b101010: alucontrol_reg <= 3'b111; // slt
                default:   alucontrol_reg <= 3'b000; // illegal funct
            endcase
        endcase
    end

    assign alucontrol = alucontrol_reg;

endmodule
