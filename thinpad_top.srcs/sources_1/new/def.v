`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 13:11:10
// Design Name: 
// Module Name: def
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
`define IF_DC_DATA 63:0
`define DC_EC_DATA 179:0
`define WB_DC_DATA 36:0
`define EX_MC_DATA 105:0
`define MC_IF_DATA 32:0
`define MC_WB_DATA 70:0
`define WB_DC_DATA 37:0
`define HAZARD_EC_DATA 4:0
`define HAZARD_IF_DATA 1:0
`define HAZARD_DC_DATA 2:0
`define DC_HAZARD_DATA 10:0
`define EC_HAZARD_DATA 16:0
`define MC_HAZARD_DATA 5:0
`define WB_HAZARD_DATA 5:0
`define MC_EC_DATA 31:0
`define WB_EC_DATA 31:0
`define MC_DC_DATA 31:0
`define DC_IF_DATA 0:0

`define IF_DC_DATA_WIDTH 64
`define DC_EC_DATA_WIDTH 180
`define WB_DC_DATA_WIDTH 37
`define EX_MC_DATA_WIDTH 106
`define MC_IF_DATA_WIDTH 33
`define MC_WB_DATA_WIDTH 71
`define WB_DC_DATA_WIDTH 38
`define HAZARD_EC_DATA_WIDTH 5
`define HAZARD_IF_DATA_WIDTH 2
`define HAZARD_DC_DATA_WIDTH 3
`define DC_HAZARD_DATA_WIDTH 11
`define EC_HAZARD_DATA_WIDTH 17
`define MC_HAZARD_DATA_WIDTH 6
`define WB_HAZARD_DATA_WIDTH 6
`define MC_EC_DATA_WIDTH 31
`define WB_EC_DATA_WIDTH 31
`define MC_DC_DATA_WIDTH 32
`define DC_IF_DATA_WIDTH 1

`define BASE_RAM_ADDRESS_START 32'h80000000
`define BASE_RAM_ADDRESS_END   32'h803FFFFF
`define EXT_RAM_ADDRESS_START  32'h80400000
`define EXT_RAM_ADDRESS_END    32'h807FFFFF
