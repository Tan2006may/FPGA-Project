`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cordic_mlp_layer
// Description: A fully-connected (dense) layer using multiple CORDIC neurons
//////////////////////////////////////////////////////////////////////////////////

module cordic_mlp_layer #(
    parameter INPUT_WIDTH = 20,
    parameter ACCUM_WIDTH = 48,
    parameter OUTPUT_WIDTH = 20,
    parameter NUM_INPUTS = 4,
    parameter NUM_NEURONS = 3
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [INPUT_WIDTH*NUM_INPUTS-1:0] inputs_flat,
    output wire signed [OUTPUT_WIDTH*NUM_NEURONS-1:0] outputs_flat,
    output wire layer_valid
);

    // Flattened weight storage for each neuron
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n0;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n1;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n2;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n3;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n4;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n5;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n6;
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat_n7;
    
    reg signed [ACCUM_WIDTH-1:0] bias_n0, bias_n1, bias_n2, bias_n3;
    reg signed [ACCUM_WIDTH-1:0] bias_n4, bias_n5, bias_n6, bias_n7;
    
    wire [NUM_NEURONS-1:0] neuron_valid;
    wire signed [OUTPUT_WIDTH-1:0] neuron_outputs [0:NUM_NEURONS-1];
    
    // Initialize weights (pack them into flattened format)
    // Format: weights_flat = {w3, w2, w1, w0} for 4 inputs
    initial begin
        // Neuron 0 weights: [w0, w1, w2, w3]
        weights_flat_n0[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;  // w0
        weights_flat_n0[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h20000;  // w1
        weights_flat_n0[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h30000;  // w2
        weights_flat_n0[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h18000;  // w3
        bias_n0 = 48'h000000080000;
        
        // Neuron 1
        weights_flat_n1[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h28000;
        weights_flat_n1[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h18000;
        weights_flat_n1[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h20000;
        weights_flat_n1[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h30000;
        bias_n1 = 48'h000000040000;
        
        // Neuron 2
        weights_flat_n2[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h30000;
        weights_flat_n2[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h28000;
        weights_flat_n2[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h10000;
        weights_flat_n2[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h20000;
        bias_n2 = 48'h0000000C0000;
        
        // Initialize remaining neurons (for hidden layer with 8 neurons)
        weights_flat_n3[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;
        weights_flat_n3[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h10000;
        weights_flat_n3[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h10000;
        weights_flat_n3[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h10000;
        bias_n3 = 48'h000000040000;
        
        weights_flat_n4[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;
        weights_flat_n4[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h10000;
        weights_flat_n4[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h10000;
        weights_flat_n4[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h10000;
        bias_n4 = 48'h000000040000;
        
        weights_flat_n5[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;
        weights_flat_n5[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h10000;
        weights_flat_n5[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h10000;
        weights_flat_n5[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h10000;
        bias_n5 = 48'h000000040000;
        
        weights_flat_n6[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;
        weights_flat_n6[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h10000;
        weights_flat_n6[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h10000;
        weights_flat_n6[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h10000;
        bias_n6 = 48'h000000040000;
        
        weights_flat_n7[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;
        weights_flat_n7[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h10000;
        weights_flat_n7[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h10000;
        weights_flat_n7[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h10000;
        bias_n7 = 48'h000000040000;
    end
    
    // Instantiate neurons explicitly
    cordic_neuron #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .NUM_INPUTS(NUM_INPUTS)
    ) neuron_0 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inputs_flat(inputs_flat),
        .weights_flat(weights_flat_n0),
        .bias(bias_n0),
        .output_data(neuron_outputs[0]),
        .output_valid(neuron_valid[0])
    );
    
    cordic_neuron #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .NUM_INPUTS(NUM_INPUTS)
    ) neuron_1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inputs_flat(inputs_flat),
        .weights_flat(weights_flat_n1),
        .bias(bias_n1),
        .output_data(neuron_outputs[1]),
        .output_valid(neuron_valid[1])
    );
    
    cordic_neuron #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .NUM_INPUTS(NUM_INPUTS)
    ) neuron_2 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inputs_flat(inputs_flat),
        .weights_flat(weights_flat_n2),
        .bias(bias_n2),
        .output_data(neuron_outputs[2]),
        .output_valid(neuron_valid[2])
    );
    
    // Conditional instantiation for additional neurons (for hidden layer with 8 neurons)
    generate
        if (NUM_NEURONS > 3) begin : n3
            cordic_neuron #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .ACCUM_WIDTH(ACCUM_WIDTH),
                .OUTPUT_WIDTH(OUTPUT_WIDTH),
                .NUM_INPUTS(NUM_INPUTS)
            ) neuron_3 (
                .clk(clk),
                .rst(rst),
                .start(start),
                .inputs_flat(inputs_flat),
                .weights_flat(weights_flat_n3),
                .bias(bias_n3),
                .output_data(neuron_outputs[3]),
                .output_valid(neuron_valid[3])
            );
        end
        
        if (NUM_NEURONS > 4) begin : n4
            cordic_neuron #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .ACCUM_WIDTH(ACCUM_WIDTH),
                .OUTPUT_WIDTH(OUTPUT_WIDTH),
                .NUM_INPUTS(NUM_INPUTS)
            ) neuron_4 (
                .clk(clk),
                .rst(rst),
                .start(start),
                .inputs_flat(inputs_flat),
                .weights_flat(weights_flat_n4),
                .bias(bias_n4),
                .output_data(neuron_outputs[4]),
                .output_valid(neuron_valid[4])
            );
        end
        
        if (NUM_NEURONS > 5) begin : n5
            cordic_neuron #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .ACCUM_WIDTH(ACCUM_WIDTH),
                .OUTPUT_WIDTH(OUTPUT_WIDTH),
                .NUM_INPUTS(NUM_INPUTS)
            ) neuron_5 (
                .clk(clk),
                .rst(rst),
                .start(start),
                .inputs_flat(inputs_flat),
                .weights_flat(weights_flat_n5),
                .bias(bias_n5),
                .output_data(neuron_outputs[5]),
                .output_valid(neuron_valid[5])
            );
        end
        
        if (NUM_NEURONS > 6) begin : n6
            cordic_neuron #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .ACCUM_WIDTH(ACCUM_WIDTH),
                .OUTPUT_WIDTH(OUTPUT_WIDTH),
                .NUM_INPUTS(NUM_INPUTS)
            ) neuron_6 (
                .clk(clk),
                .rst(rst),
                .start(start),
                .inputs_flat(inputs_flat),
                .weights_flat(weights_flat_n6),
                .bias(bias_n6),
                .output_data(neuron_outputs[6]),
                .output_valid(neuron_valid[6])
            );
        end
        
        if (NUM_NEURONS > 7) begin : n7
            cordic_neuron #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .ACCUM_WIDTH(ACCUM_WIDTH),
                .OUTPUT_WIDTH(OUTPUT_WIDTH),
                .NUM_INPUTS(NUM_INPUTS)
            ) neuron_7 (
                .clk(clk),
                .rst(rst),
                .start(start),
                .inputs_flat(inputs_flat),
                .weights_flat(weights_flat_n7),
                .bias(bias_n7),
                .output_data(neuron_outputs[7]),
                .output_valid(neuron_valid[7])
            );
        end
    endgenerate
    
    // Flatten outputs
    genvar j;
    generate
        for (j = 0; j < NUM_NEURONS; j = j + 1) begin : flatten_outputs
            assign outputs_flat[(j+1)*OUTPUT_WIDTH-1 : j*OUTPUT_WIDTH] = neuron_outputs[j];
        end
    endgenerate
    
    // All active neurons must be valid
    assign layer_valid = &neuron_valid[NUM_NEURONS-1:0];

endmodule
