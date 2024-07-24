`include "def.v"

module DC(
    input clk,
    input reset,
    input [`IF_DC_DATA_WIDTH-1:0] if_dc_data,
    input [`WB_DC_DATA_WIDTH-1:0] wb_dc_data,
    output [`DC_EC_DATA_WIDTH-1:0] dc_ec_data,

    input wire [`MC_DC_DATA_WIDTH-1:0] mc_dc_data,

    input wire [`HAZARD_DC_DATA_WIDTH-1:0] hazard_dc_data,
    output wire [`DC_HAZARD_DATA_WIDTH-1:0] dc_hazard_data,
    
    output wire [`DC_IF_DATA] dc_if_data
);
//mc_dc_data解析
assign alu_result = mc_dc_data;

//hazard_dc_data解析
wire forwardaD;
wire forwardbD;
wire stallD;

assign forwardaD = hazard_dc_data[0];
assign forwardbD = hazard_dc_data[1];
assign clear = hazard_dc_data[2];



// 解析if_dc_data数据
wire [31:0] pc_dc = if_dc_data[31:0];
wire [31:0] instr = if_dc_data[63:32];

wire [15:0] imme_num = instr[15:0];
wire [4:0] rte = instr[20:16];
wire [4:0] rde = instr[15:11];
wire [4:0] rse = instr[25:21];

// 解析wb_dc_data数据
wire [31:0] wd3 = wb_dc_data[31:0];
wire [4:0] writeregW = wb_dc_data[36:32];

// 立即数扩展
wire [31:0] signextend_imme;
SignExtend u_SignExtend(
    .immediate_in (imme_num),
    .extended_out (signextend_imme)
);

// 读取寄存器数据
wire we3 = 1;
wire [4:0] ra1, ra2;
assign ra1 = instr[25:21];
assign ra2 = instr[20:16];

wire [31:0] rd1;
wire [31:0] rd2;
RegisterFile u_RegisterFile(
    .clk (clk),
    .we3 (we3),
    .ra1 (ra1),
    .ra2 (ra2),
    .wa3 (writeregW),
    .wd3 (wd3),
    .rd1 (rd1),
    .rd2 (rd2)
);

wire [5:0] op = instr[31:26];
wire [5:0] funct = instr[5:0];
// 控制模块解析控制信号
wire memtoreg;
wire memwrite;
wire branch;
wire alusrc;
wire regdst;
wire regwrite;
wire jump;
wire [2:0] alucontrol;
ControlUnit u_ControlUnit(
    .op (op),
    .funct (funct),
    .memtoreg (memtoreg),
    .memwrite (memwrite),
    .branch (branch),
    .alusrc (alusrc),
    .regdst (regdst),
    .regwrite (regwrite),
    .alucontrol (alucontrol)
);

wire [9:0] controls;
assign controls = {regwrite, regdst, alusrc, branch, memwrite, memtoreg, alucontrol};
wire [`DC_EC_DATA_WIDTH-1:0] dc_ec_data_c;
assign dc_ec_data_c = {controls, signextend_imme, rd1, rd2, rte, rde, pc_dc,rse};


//解决数据冒险
wire equel_d = (forwardaD ? rd1 : alu_result) == (forwardbD ? rd2 : alu_result);
wire pcsrcd = branch & equel_d;

PipelineRegister #(
    .WIDTH (`DC_EC_DATA_WIDTH)
) u_PipelineRegister (
    .clk (clk),
    .reset (reset),
    .data_in (dc_ec_data_c),
    .data_out (dc_ec_data)
);
wire enable = 1;

PipelineRegister#(
    .WIDTH   ( `DC_EC_DATA_WIDTH )
)u2_PipelineRegister(
    .clk     ( clk     ),
    .reset   ( reset   ),
    .clear   ( clear   ),
    .enable  ( enable  ),
    .data_in ( dc_ec_data_c ),
    .data_out  ( dc_ec_data  )
);


// dc_hazard_data赋值
assign dc_hazard_data = {rse, rte, branch};

//dc_if_data赋值
assign dc_if_data = pcsrcd; 
endmodule
