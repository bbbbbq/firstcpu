`include "def.v"

module EC(
    input wire clk,
    input wire reset,
    input wire [`DC_EC_DATA_WIDTH-1:0] dc_ec_data,
    input wire [`MC_EC_DATA] mc_ec_data,
    input wire [`WB_EC_DATA] wb_ec_data,

    output wire [`EX_MC_DATA_WIDTH-1:0] ex_mc_data,
    
    input wire [`HAZARD_EC_DATA_WIDTH-1:0] hazard_ec_data,
    output wire [`EC_HAZARD_DATA_WIDTH-1:0] ec_hazard_data
);
//mc_ec_data解析
wire [31:0] alu_result_M = mc_ec_data;

//wb_ec_data解析
wire [31:0] result_w = wb_ec_data;


// hazard_ec_data解析
wire [1:0] forwardaE, forwardbE;
assign forwardaE = hazard_ec_data[1:0];
assign forwardbE = hazard_ec_data[3:2];
wire flushE = hazard_ec_data[4];

// 解析dc_ec_data数据
wire [9:0] controls = dc_ec_data[9:0];
wire [31:0] signextend_imme = dc_ec_data[41:10];
wire [31:0] rd1 = dc_ec_data[73:42];
wire [31:0] rd2 = dc_ec_data[105:74];
wire [4:0] rte = dc_ec_data[110:106];
wire [4:0] rde = dc_ec_data[115:111];
wire [4:0] rse = dc_ec_data[179:175];
wire [31:0] pc_ec = dc_ec_data[147:116];

// 解析控制信号
wire regwrite = controls[9];
wire regdst = controls[8];
wire alusrc = controls[7];
wire branch = controls[6];
wire memwrite = controls[5];
wire memtoreg = controls[4];
wire [2:0] alucontrol = controls[3:1];

// ALU src 声明赋值
wire [31:0] alusrcAE;
wire [31:0] alusrcBE;

assign alusrcAE = (forwardaE == 2'b00) ? rd1 :
                  (forwardaE == 2'b01) ? result_w:
                  (forwardaE == 2'b10) ? alu_result_M : 32'b0;

assign alusrcBE = (forwardbE == 2'b00) ? rd2 :
                  (forwardbE == 2'b01) ? result_w :
                  (forwardbE == 2'b10) ? alu_result_M : 32'b0;

// ALU计算
wire [31:0] alu_result;
wire zero;

alu u_alu(
    .alu_op     ( alucontrol   ),
    .alu_src1   ( alusrcAE     ),
    .alu_src2   ( alusrcBE     ),
    .alu_result ( alu_result   ),
    .zero       ( zero         )
);

// writereg选择
wire [4:0] writereg = regdst ? rde : rte;

// 分支指令实现
wire [31:0] imme_shift = signextend_imme << 2;
wire [31:0] pc_branch = imme_shift + pc_ec;

wire [`EX_MC_DATA_WIDTH-1:0] ex_mc_data_c;
// rd2 = writedata
assign ex_mc_data_c = {regwrite, memtoreg, memwrite, branch, zero, alu_result, rd2, writereg, pc_branch};

PipelineRegister#(
    .WIDTH   ( `EX_MC_DATA_WIDTH )
) u_PipelineRegister (
    .clk     ( clk     ),
    .reset   ( reset   ),
    .data_in ( ex_mc_data_c ),
    .data_out( ex_mc_data  )
);

// ec_hazard_data赋值
assign ec_hazard_data = {rse, rte, writereg, regwrite};

endmodule
