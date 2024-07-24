`include "def.v"

module mips_top(
    input wire clk,             // 时钟信号
    input wire reset,           // 复位信号

    // UART接口连接
    output wire txd,    // UART发送端
    input wire rxd,     // UART接收端

    // 指令存储器接口
    output wire instr_en,
    output wire [3:0] instr_wen,
    output wire [31:0] instr_addr,
    output wire [31:0] instr_wdata,
    input wire [31:0] instr_rdata,

    // 数据存储器接口
    output wire data_en,
    output wire [3:0] data_wen,
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    input wire [31:0] data_rdata
);

wire [`MC_IF_DATA_WIDTH-1:0] mc_if_data;
wire [`IF_DC_DATA_WIDTH-1:0] if_dc_data;
wire [`WB_DC_DATA_WIDTH-1:0] wb_dc_data;
wire [`DC_EC_DATA_WIDTH-1:0] dc_ec_data;
wire [`EX_MC_DATA_WIDTH-1:0] ex_mc_data;
wire [`MC_WB_DATA_WIDTH-1:0] mc_wb_data;

// Hazard signals
wire [`HAZARD_IF_DATA_WIDTH-1:0] hazard_if_data;
wire [`HAZARD_DC_DATA_WIDTH-1:0] hazard_dc_data;
wire [`HAZARD_EC_DATA_WIDTH-1:0] hazard_ec_data;
wire [`DC_HAZARD_DATA_WIDTH-1:0] dc_hazard_data;
wire [`EC_HAZARD_DATA_WIDTH-1:0] ec_hazard_data;
wire [`MC_HAZARD_DATA_WIDTH-1:0] mc_hazard_data;
wire [`WB_HAZARD_DATA_WIDTH-1:0] wb_hazard_data;

IF u_IF(
    .clk            ( clk            ),
    .reset          ( reset          ),
    .mc_if_data     ( mc_if_data     ),
    .if_dc_data     ( if_dc_data     ),
    .instr_en       ( instr_en       ),
    .instr_wen      ( instr_wen      ),
    .instr_addr     ( instr_addr     ),
    .instr_wdata    ( instr_wdata    ),
    .instr_rdata    ( instr_rdata    ),
    .hazard_if_data ( hazard_if_data ),
    .dc_if_data     ( dc_if_data     )
);

DC u_DC(
    .clk            ( clk            ),
    .reset          ( reset          ),
    .if_dc_data     ( if_dc_data     ),
    .wb_dc_data     ( wb_dc_data     ),
    .dc_ec_data     ( dc_ec_data     ),
    .mc_dc_data     ( mc_dc_data     ),
    .hazard_dc_data ( hazard_dc_data ),
    .dc_hazard_data ( dc_hazard_data )
);

EC u_EC(
    .clk            ( clk            ),
    .reset          ( reset          ),
    .dc_ec_data     ( dc_ec_data     ),
    .ex_mc_data     ( ex_mc_data     ),
    .hazard_ec_data ( hazard_ec_data ),
    .ec_hazard_data ( ec_hazard_data )
);

MC u_MC(
    .clk            ( clk            ),
    .reset          ( reset          ),
    .ex_mc_data     ( ex_mc_data     ),
    .mc_if_data     ( mc_if_data     ),
    .mc_wb_data     ( mc_wb_data     ),
    .data_mem_en    ( data_en        ),
    .data_mem_wen   ( data_wen       ),
    .data_mem_addr  ( data_addr      ),
    .data_mem_wdata ( data_wdata     ),
    .data_mem_rdata ( data_rdata     ),
    .mc_hazard_data ( mc_hazard_data )
);

WB u_WB(
    .clk            ( clk            ),
    .reset          ( reset          ),
    .mc_wb_data     ( mc_wb_data     ),
    .wb_dc_data     ( wb_dc_data     ),
    .wb_hazard_data ( wb_hazard_data )
);


hazard_unit u_hazard_unit(
    .stallF         ( stallF         ),    //instr_fetch
    .dc_hazard_data ( dc_hazard_data ),
    .hazard_dc_data ( hazard_dc_data ),
    .ec_hazard_data ( ec_hazard_data ),
    .hazard_ec_data ( hazard_ec_data ),
    .mc_hazard_data ( mc_hazard_data ),
    .wb_hazard_data  ( wb_hazard_data  )
);


hazard_unit u_hazard_unit(
    .dc_hazard_data ( dc_hazard_data ),
    .ec_hazard_data ( ec_hazard_data ),
    .mc_hazard_data ( mc_hazard_data ),
    .wb_hazard_data ( wb_hazard_data ),
    .hazard_if_data ( hazard_if_data ),
    .hazard_dc_data ( hazard_dc_data ),
    .hazard_ec_data ( hazard_ec_data )
);

endmodule
