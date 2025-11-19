module fp_mlp_layer #(
    parameter DATA_WIDTH = 16,
    parameter N_INPUTS = 4,      // reduced inputs
    parameter N_NEURONS = 4,     // reduced neurons
    parameter ADDR_WIDTH = 8
)(
    input clk,
    input rst,
    input  [DATA_WIDTH*N_INPUTS-1:0] layer_inputs,
    input  [DATA_WIDTH*N_INPUTS*N_NEURONS-1:0] layer_weights,
    input  [ADDR_WIDTH*N_NEURONS-1:0] lut_addrs,
    output [DATA_WIDTH*N_NEURONS-1:0] layer_outputs
);

genvar i, j;
wire [DATA_WIDTH-1:0] neuron_outputs [0:N_NEURONS-1];

generate
    for (i = 0; i < N_NEURONS; i = i + 1) begin : NEURON_LOOP

        wire [DATA_WIDTH-1:0] mul_results [0:N_INPUTS-1];
        reg [DATA_WIDTH-1:0] accumulator;
        wire [ADDR_WIDTH-1:0] lut_addr_calc;

        for (j = 0; j < N_INPUTS; j = j + 1) begin : MULT_LOOP
            wire [DATA_WIDTH-1:0] in, wgt;
            wire [DATA_WIDTH-1:0] m_axis_result_tdata;
            wire s_axis_a_tready, s_axis_b_tready, m_axis_result_tvalid;
            wire s_axis_a_tvalid = 1'b1;
            wire s_axis_b_tvalid = 1'b1;
            wire m_axis_result_tready = 1'b1;

            assign in = layer_inputs[(j+1)*DATA_WIDTH-1 -: DATA_WIDTH];
            assign wgt = layer_weights[((i*N_INPUTS) + j + 1)*DATA_WIDTH-1 -: DATA_WIDTH];

           floating_point_0 your_instance_name (
  .aclk(aclk),                                  // input wire aclk
  .s_axis_a_tvalid(s_axis_a_tvalid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(s_axis_a_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(s_axis_a_tdata),              // input wire [15 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(s_axis_b_tvalid),            // input wire s_axis_b_tvalid
  .s_axis_b_tready(s_axis_b_tready),            // output wire s_axis_b_tready
  .s_axis_b_tdata(s_axis_b_tdata),              // input wire [15 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(m_axis_result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(m_axis_result_tready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(m_axis_result_tdata)    // output wire [15 : 0] m_axis_result_tdata
);

            assign mul_results[j] = m_axis_result_tdata;
        end

        integer k;
        always @(posedge clk or posedge rst) begin
            if (rst) accumulator <= 0;
            else begin
                accumulator <= 0;
                for (k = 0; k < N_INPUTS; k = k + 1)
                    accumulator <= accumulator + mul_results[k];
            end
        end

        assign lut_addr_calc = accumulator[DATA_WIDTH-1 -: ADDR_WIDTH];

        fp_neuron #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) neuron_inst (
            .clk(clk),
            .rst(rst),
            .inputs(accumulator),
            .weights(32'h3F800000), // unity
            .lut_addr(lut_addr_calc),
            .output_neuron(neuron_outputs[i])
        );

        assign layer_outputs[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] = neuron_outputs[i];
    end
endgenerate

endmodule
