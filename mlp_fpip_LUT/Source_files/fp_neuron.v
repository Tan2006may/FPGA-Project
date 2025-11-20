module fp_neuron #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 8,
    parameter N_INPUTS  = 4
)(
    input clk,
    input rst,
    input [DATA_WIDTH*N_INPUTS-1:0] inputs,
    input [DATA_WIDTH*N_INPUTS-1:0] weights,
    input [ADDR_WIDTH-1:0] lut_addr,
    output reg [DATA_WIDTH-1:0] output_neuron
);

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] acc;
    reg [DATA_WIDTH-1:0] inp_vec [0:N_INPUTS-1];
    reg [DATA_WIDTH-1:0] wgt_vec [0:N_INPUTS-1];
    reg [3:0] idx; // for up to 16 inputs
    wire [DATA_WIDTH-1:0] m_axis_result_tdata;
    wire s_axis_a_tready, s_axis_b_tready, m_axis_result_tvalid;

    reg s_axis_a_tvalid, s_axis_b_tvalid;
    reg [DATA_WIDTH-1:0] s_axis_a_tdata, s_axis_b_tdata;
    reg start_mult;

    reg [DATA_WIDTH-1:0] sigmoid_lut [0:(1<<ADDR_WIDTH)-1];
    initial $readmemh("sigmoid_lut.mem", sigmoid_lut);

    floating_point_0 mult (
        .aclk(clk),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tdata(s_axis_a_tdata),
        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
        .s_axis_b_tdata(s_axis_b_tdata),
        .m_axis_result_tvalid(m_axis_result_tvalid),
        .m_axis_result_tready(1'b1),
        .m_axis_result_tdata(m_axis_result_tdata)
    );

    // Unpack input and weight vectors
    integer i;
    always @(*) begin
        for (i = 0; i < N_INPUTS; i = i + 1) begin
            inp_vec[i] = inputs[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
            wgt_vec[i] = weights[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
        end
    end

    // FSM for sequential MAC operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            idx   <= 0;
            acc   <= 0;
            output_neuron <= 0;
            s_axis_a_tvalid <= 0;
            s_axis_b_tvalid <= 0;
        end else begin
            case (state)
                0: begin // Idle: start new MAC cycle
                    idx <= 0;
                    acc <= 0;
                    s_axis_a_tvalid <= 1;
                    s_axis_b_tvalid <= 1;
                    s_axis_a_tdata  <= inp_vec[0];
                    s_axis_b_tdata  <= wgt_vec[0];
                    state <= 1;
                end
                1: begin // Wait Mult Result
                    if (m_axis_result_tvalid) begin
                        acc <= acc + m_axis_result_tdata;
                        idx <= idx + 1;
                        if (idx == N_INPUTS-1) begin
                            state <= 2; // Done MACs, go to LUT
                        end else begin
                            // Load next pair into multiplier
                            s_axis_a_tdata <= inp_vec[idx+1];
                            s_axis_b_tdata <= wgt_vec[idx+1];
                        end
                    end
                end
                2: begin // LUT output, finish
                    output_neuron <= sigmoid_lut[acc[DATA_WIDTH-1 -: ADDR_WIDTH]];
                    state <= 0; // Repeat cycle
                end
            endcase
        end
    end

endmodule
