`include "def.v"

module WB(
    input wire clk,
    input wire reset,
    input wire [`MC_WB_DATA_WIDTH-1:0] mc_wb_data,
    output wire [`WB_DC_DATA_WIDTH-1:0] wb_dc_data,
    output wire [`WB_HAZARD_DATA_WIDTH-1:0] wb_hazard_data,
    output wire [`WB_EC_DATA] wb_ec_data
);
wire regwrite = mc_wb_data[0];
wire memtoreg = mc_wb_data[1];
wire [31:0] alu_result = mc_wb_data[2 +: 32];
wire [31:0] read_data = mc_wb_data[34 +: 32];
wire [4:0] writereg = mc_wb_data[66 +: 5];

wire [31:0] resultw = memtoreg ? read_data : alu_result;
assign wb_ec_data = resultw;
assign wb_dc_data = {regwrite, writereg, resultw};

// wb_hazard_data赋值
assign wb_hazard_data = {writereg, regwrite};

endmodule
