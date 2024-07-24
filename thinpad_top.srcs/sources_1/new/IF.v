`include "def.v"

module IF(
    input wire clk,
    input wire reset,
    input wire [`MC_IF_DATA_WIDTH-1:0] mc_if_data,
    output wire [`IF_DC_DATA_WIDTH-1:0] if_dc_data,

    // 与指令存储器接口
    output wire instr_en,
    output wire [3:0] instr_wen,
    output wire [31:0] instr_addr,
    output wire [31:0] instr_wdata,
    input wire [31:0] instr_rdata,

    input wire [`HAZARD_IF_DATA] hazard_if_data,

    input wire [`DC_IF_DATA] dc_if_data
);
//dc_if_data 解析
assign pcsrcd = dc_if_data;

//hazard_if_data解析
wire stall_F = hazard_if_data[0:0];
wire stallF_D = hazard_if_data[1:1];


// 解析mc_if_data
// pcsrcm, pc_branch
wire pcsrcm = mc_if_data[0];
wire [31:0] pc_branch = mc_if_data[1 +: 32];
reg [31:0] pc;

initial begin
    pc = 32'h80000000;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 32'h80000000;
    end else if (stall_F) begin
        pc <= pc;  // 保持不变
    end else if (pcsrcd) begin
        pc <= pc_branch;
    end else begin
        pc <= pc + 4;
    end
end

// 指令存储器控制信号
assign instr_en = 1;
assign instr_wen = 4'b0000; // 不进行写操作
assign instr_addr = pc;
assign instr_wdata = 32'b0; // 不进行写操作

wire [31:0] instr;
assign instr = instr_rdata;

wire [`IF_DC_DATA_WIDTH-1:0] if_dc_data_c;
assign if_dc_data_c = {pc, instr};

PipelineRegister #(
    .WIDTH(`IF_DC_DATA_WIDTH)
) u_PipelineRegister (
    .clk(clk),
    .reset(reset),
    .clear(pcsrcd),
    .enable(!stallF_D),
    .data_in(if_dc_data_c),
    .data_out(if_dc_data)
);

endmodule
