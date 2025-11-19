module fp_neuron #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 8
)(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] inputs,
    input [DATA_WIDTH-1:0] weights,
    input [ADDR_WIDTH-1:0] lut_addr,
    output reg [DATA_WIDTH-1:0] output_neuron
);

wire [DATA_WIDTH-1:0] m_axis_result_tdata;
wire s_axis_a_tready, s_axis_b_tready, m_axis_result_tvalid;
wire s_axis_a_tvalid = 1'b1;
wire s_axis_b_tvalid = 1'b1;
wire m_axis_result_tready = 1'b1;

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

reg [DATA_WIDTH-1:0] sigmoid_lut [0:(1<<ADDR_WIDTH)-1];

initial $readmemh("sigmoid_lut.mem", sigmoid_lut);

always @(posedge clk or posedge rst) begin
    if (rst) output_neuron <= 0;
    else output_neuron <= sigmoid_lut[lut_addr];
end

endmodule
