`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cordic_mlp
// Description: Multi-layer perceptron using CORDIC neurons
//////////////////////////////////////////////////////////////////////////////////

module cordic_mlp #(
    parameter INPUT_WIDTH = 20,
    parameter HIDDEN_WIDTH =  20,
    parameter OUTPUT_WIDTH = 20,
    parameter ACCUM_WIDTH = 48,
    parameter NUM_INPUTS = 4,
    parameter NUM_HIDDEN = 8,
    parameter NUM_OUTPUTS = 3
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [INPUT_WIDTH*NUM_INPUTS-1:0] inputs_flat,
    output wire signed [OUTPUT_WIDTH*NUM_OUTPUTS-1:0] outputs_flat,
    output wire mlp_valid
);

    // Hidden layer outputs - flattened
    wire signed [HIDDEN_WIDTH*NUM_HIDDEN-1:0] hidden_outputs_flat;
    wire hidden_valid;
    
    // Hidden layer (Input ? Hidden)
    cordic_mlp_layer #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .OUTPUT_WIDTH(HIDDEN_WIDTH),
        .NUM_INPUTS(NUM_INPUTS),
        .NUM_NEURONS(NUM_HIDDEN)
    ) hidden_layer (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inputs_flat(inputs_flat),
        .outputs_flat(hidden_outputs_flat),
        .layer_valid(hidden_valid)
    );
    
    // Output layer (Hidden ? Output)
    cordic_mlp_layer #(
        .INPUT_WIDTH(HIDDEN_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .NUM_INPUTS(NUM_HIDDEN),
        .NUM_NEURONS(NUM_OUTPUTS)
    ) output_layer (
        .clk(clk),
        .rst(rst),
        .start(hidden_valid),
        .inputs_flat(hidden_outputs_flat),
        .outputs_flat(outputs_flat),
        .layer_valid(mlp_valid)
    );

endmodule
