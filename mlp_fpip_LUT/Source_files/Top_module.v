`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 10:28:20 AM
// Design Name: 
// Module Name: Top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_module(
    input wire clk
    );
    wire [63:0] layer_inputs;
    wire [63:0] layer_outputs;
    wire [255:0] layer_weights;
    wire rst;
   vio_0 your_instance_name (
      .clk(clk),                // input wire clk
      .probe_in0(layer_outputs),    // input wire [63 : 0] probe_in0
      .probe_out0(layer_inputs),  // output wire [63 : 0] probe_out0
      .probe_out1(rst),  // output wire [0 : 0] probe_out1
      .probe_out2(layer_weights)  // output wire [255 : 0] probe_out2
);



    fp_mlp_layer#(
        .DATA_WIDTH(16),
        .N_INPUTS(4),
        .N_NEURONS(4),
        .ADDR_WIDTH(8)
        ) mlp_instance (
            .clk(clk),
            .layer_inputs(layer_inputs),
            .layer_outputs(layer_outputs),
            .layer_weights(layer_weights),
            .rst(rst)
            );
                
endmodule
