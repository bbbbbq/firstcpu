module alu(
  input  [2:0] alu_op,
  input  [31:0] alu_src1,
  input  [31:0] alu_src2,
  output [31:0] alu_result,
  output        zero
);

wire op_add;   // 加法操作
wire op_sub;   // 减法操作
wire op_slt;   // 有符号比较，小于置位
wire op_and;   // 按位与
wire op_or;    // 按位或
wire op_xor;   // 按位异或

// 控制信号分解
assign op_add  = (alu_op == 3'b010);
assign op_sub  = (alu_op == 3'b110);
assign op_slt  = (alu_op == 3'b111);
assign op_and  = (alu_op == 3'b000);
assign op_or   = (alu_op == 3'b001);
assign op_xor  = (alu_op == 3'b011);

wire [31:0] add_sub_result;
wire [31:0] slt_result;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] xor_result;

// 32位加法器
wire [31:0] adder_a;
wire [31:0] adder_b;
wire        adder_cin;
wire [31:0] adder_result;
wire        adder_cout;

assign adder_a   = alu_src1;
assign adder_b   = op_sub ? ~alu_src2 : alu_src2;
assign adder_cin = op_sub ? 1'b1 : 1'b0;
assign {adder_cout, adder_result} = adder_a + adder_b + adder_cin;

// ADD, SUB结果
assign add_sub_result = adder_result;

// SLT结果
assign slt_result[31:1] = 31'b0;
assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31])
                        | ((alu_src1[31] ~^ alu_src2[31]) & adder_result[31]);

// 按位操作
assign and_result = alu_src1 & alu_src2;
assign or_result  = alu_src1 | alu_src2;
assign xor_result = alu_src1 ^ alu_src2;

// 生成Zero信号
assign zero = (alu_result == 32'b0);

// 最终结果选择
assign alu_result = ({32{op_add | op_sub}} & add_sub_result)
                  | ({32{op_slt         }} & slt_result)
                  | ({32{op_and         }} & and_result)
                  | ({32{op_or          }} & or_result)
                  | ({32{op_xor         }} & xor_result);

endmodule
