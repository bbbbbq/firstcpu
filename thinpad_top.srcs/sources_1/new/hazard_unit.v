`include "def.v"

module hazard_unit(
    // 输入总线
    input wire [`DC_HAZARD_DATA_WIDTH-1:0] dc_hazard_data,
    input wire [`EC_HAZARD_DATA_WIDTH-1:0] ec_hazard_data,
    input wire [`MC_HAZARD_DATA_WIDTH-1:0] mc_hazard_data,
    input wire [`WB_HAZARD_DATA_WIDTH-1:0] wb_hazard_data,

    // 输出总线
    output wire [`HAZARD_IF_DATA_WIDTH-1:0] hazard_if_data,
    output wire [`HAZARD_DC_DATA_WIDTH-1:0] hazard_dc_data,
    output wire [`HAZARD_EC_DATA_WIDTH-1:0] hazard_ec_data
);

    // 解析dc_hazard_data信号
    wire [4:0] rsD = dc_hazard_data[10:6];
    wire [4:0] rtD = dc_hazard_data[5:1];
    wire branchD = dc_hazard_data[0];
    
    // 解析ec_hazard_data信号
    wire [4:0] rsE = ec_hazard_data[16:12];
    wire [4:0] rtE = ec_hazard_data[11:7];
    wire [4:0] writeregE = ec_hazard_data[6:2];
    wire regwriteE = ec_hazard_data[1];
    wire memtoregE = ec_hazard_data[0];
    
    // 解析mc_hazard_data信号
    wire [4:0] writeregM = mc_hazard_data[5:1];
    wire regwriteM = mc_hazard_data[0];
    
    // 解析wb_hazard_data信号
    wire [4:0] writeregW = wb_hazard_data[5:1];
    wire regwriteW = wb_hazard_data[0];
    
    // 声明输出信号
    wire stallF;
    wire forwardaD, forwardbD;
    wire stallD;
    reg [1:0] forwardaE, forwardbE;
    wire flushE;
    
    // forwarding sources to D stage (branch equality)
    assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
    assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
    
    // forwarding sources to E stage (ALU)
    always @(*) begin
        forwardaE = 2'b00;
        forwardbE = 2'b00;
        if(rsE != 0) begin
            if(rsE == writeregM & regwriteM) begin
                forwardaE = 2'b10;
            end else if(rsE == writeregW & regwriteW) begin
                forwardaE = 2'b01;
            end
        end
        if(rtE != 0) begin
            if(rtE == writeregM & regwriteM) begin
                forwardbE = 2'b10;
            end else if(rtE == writeregW & regwriteW) begin
                forwardbE = 2'b01;
            end
        end
    end

    //stalls
    wire lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
    wire branchstallD = branchD &
                (regwriteE & 
                (writeregE == rsD | writeregE == rtD) |
                memtoregM &
                (writeregM == rsD | writeregM == rtD));
    assign stallD = lwstallD | branchstallD;
    assign stallF = stallD;
    assign flushE = stallD;

    // 将输出信号打包成总线信号
    assign hazard_if_data = {stallF, stallF_D};
    assign hazard_dc_data = {forwardaD, forwardbD, stallD};
    assign hazard_ec_data = {forwardaE, forwardbE, flushE};

endmodule
