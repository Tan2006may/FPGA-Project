`timescale 1ns / 1ps

module mlp_testbench();

parameter DATA_WIDTH = 16;
parameter N_INPUTS = 4;
parameter N_NEURONS = 4;
parameter ADDR_WIDTH = 8;

reg clk;
reg rst;
reg [DATA_WIDTH*N_INPUTS-1:0] layer_inputs;
reg [DATA_WIDTH*N_INPUTS*N_NEURONS-1:0] layer_weights;
reg [ADDR_WIDTH*N_NEURONS-1:0] lut_addrs;
wire [DATA_WIDTH*N_NEURONS-1:0] layer_outputs;

fp_mlp_layer #(
    .DATA_WIDTH(DATA_WIDTH),
    .N_INPUTS(N_INPUTS),
    .N_NEURONS(N_NEURONS),
    .ADDR_WIDTH(ADDR_WIDTH)
) uut (
    .clk(clk),
    .rst(rst),
    .layer_inputs(layer_inputs),
    .layer_weights(layer_weights),
    .lut_addrs(lut_addrs),
    .layer_outputs(layer_outputs)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    rst = 1;
    layer_inputs = 0;
    layer_weights = 0;
    lut_addrs = 0;

    #15 rst = 0;

    layer_inputs = {
        32'h3fa00000, 32'h40a00000, 32'h40200000, 32'h40800000
    };

    layer_weights = {
        32'h3f800000, 32'h40000000, 32'h40400000, 32'h40800000,
        32'h40a00000, 32'h40c00000, 32'h40e00000, 32'h41000000,
        32'h41000000, 32'h40e00000, 32'h40c00000, 32'h40a00000
    };

    lut_addrs = 0;

    #100;
    $stop;
end

endmodule
