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

    // Initialize layer_inputs: 4 inputs, each 16-bit half-precision float/example values
    layer_inputs = {
        16'h3fa0,  // example half-precision hex
        16'h40a0,
        16'h4020,
        16'h4080
    };

    // Initialize layer_weights: 16 weights (4 inputs * 4 neurons), 16-bit each
    layer_weights = {
        16'h3f80, 16'h4000, 16'h4040, 16'h4080,
        16'h40a0, 16'h40c0, 16'h40e0, 16'h4100,
        16'h4100, 16'h40e0, 16'h40c0, 16'h40a0,
        16'h4080, 16'h4040, 16'h4000, 16'h3f80
    };

    lut_addrs = 0;

    #100;
    $stop;
end

endmodule
