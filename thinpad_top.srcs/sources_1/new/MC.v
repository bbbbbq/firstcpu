`include "def.v"

module MC(
    input wire clk,
    input wire reset,
    input wire [`EX_MC_DATA_WIDTH-1:0] ex_mc_data,
    output wire [`MC_IF_DATA_WIDTH-1:0] mc_if_data,
    output wire [`MC_WB_DATA_WIDTH-1:0] mc_wb_data,
    output wire [`MC_EC_DATA] mc_ec_data,
    output wire [`MC_DC_DATA] mc_dc_data,
    // 外部数据存储器接口
    output wire data_mem_en,
    output wire [3:0] data_mem_wen,
    output wire [31:0] data_mem_addr,
    output wire [31:0] data_mem_wdata,
    input wire [31:0] data_mem_rdata,

    output wire [`MC_HAZARD_DATA_WIDTH-1:0] mc_hazard_data
);

// 解析 ex_mc_data 信号
wire regwrite = ex_mc_data[0];
wire memtoreg = ex_mc_data[1];
wire memwrite = ex_mc_data[2];
wire branch = ex_mc_data[3];
wire zero = ex_mc_data[4];
wire [31:0] alu_result = ex_mc_data[5 +: 32];
wire [31:0] rd2 = ex_mc_data[37 +: 32];
wire [4:0] writereg = ex_mc_data[69 +: 5];
wire [31:0] pc_branch = ex_mc_data[74 +: 32];

// 控制信号
assign data_mem_en = 1;
assign data_mem_wen = memwrite ? 4'b1111 : 4'b0000;  // 如果写使能则全部字节使能
assign data_mem_addr = alu_result;
assign data_mem_wdata = rd2;

// 从外部数据存储器读取的数据
wire [31:0] read_data = data_mem_rdata;

// pcsrcm选择
wire pcsrcm;
assign pcsrcm = branch & zero;

// mc_if_data和mc_wb_data
wire [`MC_IF_DATA_WIDTH-1:0] mc_if_data_c;
wire [`MC_WB_DATA_WIDTH-1:0] mc_wb_data_c;
assign mc_if_data_c = {pcsrcm, pc_branch};
assign mc_wb_data_c = {regwrite, memtoreg, alu_result, read_data, writereg};

PipelineRegister #(
    .WIDTH(`MC_IF_DATA_WIDTH)
) PipelineRegister_to_if (
    .clk(clk),
    .reset(reset),
    .data_in(mc_if_data_c),
    .data_out(mc_if_data)
);

PipelineRegister #(
    .WIDTH(`MC_WB_DATA_WIDTH)
) PipelineRegister_to_wb (
    .clk(clk),
    .reset(reset),
    .data_in(mc_wb_data_c),
    .data_out(mc_wb_data)
);

// mc_hazard_data赋值
assign mc_hazard_data = {writereg, regwrite};

// mc_ec_data赋值
assign mc_ec_data = alu_result;

//mc_dc_data赋值
assign mc_dc_data = alu_result;
endmodule
