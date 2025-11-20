module fp_mlp_layer #(
    parameter DATA_WIDTH = 16,
    parameter N_INPUTS = 4,
    parameter N_NEURONS = 4,
    parameter ADDR_WIDTH = 8
)(
    input clk,
    input rst,
    input  [DATA_WIDTH*N_INPUTS-1:0]   layer_inputs,
    input  [DATA_WIDTH*N_INPUTS*N_NEURONS-1:0] layer_weights,
    input  [ADDR_WIDTH*N_NEURONS-1:0] lut_addrs,
    output [DATA_WIDTH*N_NEURONS-1:0] layer_outputs
);

    genvar i;
    wire [DATA_WIDTH-1:0] neuron_outputs [0:N_NEURONS-1];

    generate
        for (i = 0; i < N_NEURONS; i = i + 1) begin : NEURON_LOOP
            fp_neuron #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .N_INPUTS(N_INPUTS)
            ) neuron_inst (
                .clk(clk),
                .rst(rst),
                .inputs(layer_inputs),
                .weights(layer_weights[(i+1)*N_INPUTS*DATA_WIDTH-1 -: N_INPUTS*DATA_WIDTH]),
                .lut_addr(lut_addrs[(i+1)*ADDR_WIDTH-1 -: ADDR_WIDTH]),
                .output_neuron(neuron_outputs[i])
            );

            assign layer_outputs[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] = neuron_outputs[i];
        end
    endgenerate

endmodule
