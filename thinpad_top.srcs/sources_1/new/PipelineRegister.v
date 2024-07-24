module PipelineRegister #(parameter WIDTH = 32)(
    input clk,
    input reset,
    input clear,
    input enable,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= {WIDTH{1'b0}};
        end else if (clear) begin
            data_out <= {WIDTH{1'b0}};
        end else if (enable) begin
            data_out <= data_in;
        end
    end

endmodule
