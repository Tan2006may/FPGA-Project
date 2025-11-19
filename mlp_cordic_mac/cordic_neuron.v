`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 09:19:45 PM
// Design Name: 
// Module Name: cordic_neuron
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

// cordic_neuron.v
// Single neuron using Multiply Adder (MAC) and CORDIC for activation

module cordic_neuron #(
    parameter INPUT_WIDTH = 20,      // Match your Multiply Adder A/B width
    parameter ACCUM_WIDTH = 48,      // Match your Multiply Adder C width
    parameter OUTPUT_WIDTH = 20,     // CORDIC output width
    parameter NUM_INPUTS = 4         // Number of inputs to this neuron
)(
    input wire clk,
    input wire rst,
    input wire start,                // Start computation
    input wire signed [INPUT_WIDTH*NUM_INPUTS-1:0] inputs_flat,   // FLATTENED INPUT
    input wire signed [INPUT_WIDTH*NUM_INPUTS-1:0] weights_flat,  // FLATTENED WEIGHTS
    input wire signed [ACCUM_WIDTH-1:0] bias,
    output reg signed [OUTPUT_WIDTH-1:0] output_data,
    output reg output_valid
);

    // Unflatten inputs and weights for internal use
    wire signed [INPUT_WIDTH-1:0] inputs [0:NUM_INPUTS-1];
    wire signed [INPUT_WIDTH-1:0] weights [0:NUM_INPUTS-1];
    
    genvar k;
    generate
        for (k = 0; k < NUM_INPUTS; k = k + 1) begin : unflatten_arrays
            assign inputs[k] = inputs_flat[(k+1)*INPUT_WIDTH-1 : k*INPUT_WIDTH];
            assign weights[k] = weights_flat[(k+1)*INPUT_WIDTH-1 : k*INPUT_WIDTH];
        end
    endgenerate

    // State machine
    localparam IDLE = 2'b00;
    localparam MAC_COMPUTE = 2'b01;
    localparam ACTIVATION = 2'b10;
    localparam DONE = 2'b11;
    
    reg [1:0] state, next_state;
    reg [7:0] mac_counter;
    
    // MAC signals
    reg signed [INPUT_WIDTH-1:0] mac_a;
    reg signed [INPUT_WIDTH-1:0] mac_b;
    reg signed [ACCUM_WIDTH-1:0] mac_c;
    wire signed [ACCUM_WIDTH-1:0] mac_p;
    reg mac_ce;
    
    // CORDIC signals
    reg signed [INPUT_WIDTH-1:0] cordic_in;
    wire signed [OUTPUT_WIDTH-1:0] cordic_out;
    wire cordic_valid;
    reg cordic_start;
    
    // Accumulator
    reg signed [ACCUM_WIDTH-1:0] accumulator;
    
    // State machine - sequential
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // State machine - combinational
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = MAC_COMPUTE;
            end
            MAC_COMPUTE: begin
                if (mac_counter >= NUM_INPUTS)
                    next_state = ACTIVATION;
            end
            ACTIVATION: begin
                if (cordic_valid)
                    next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // Datapath logic
    always @(posedge clk) begin
        if (rst) begin
            mac_counter <= 0;
            accumulator <= 0;
            mac_ce <= 0;
            cordic_start <= 0;
            output_valid <= 0;
            mac_a <= 0;
            mac_b <= 0;
            mac_c <= 0;
            cordic_in <= 0;
            output_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    mac_counter <= 0;
                    accumulator <= bias;  // Initialize with bias
                    mac_ce <= 0;
                    cordic_start <= 0;
                    output_valid <= 0;
                end
                
                MAC_COMPUTE: begin
                    if (mac_counter < NUM_INPUTS) begin
                        // Feed current input and weight to MAC
                        mac_a <= inputs[mac_counter];
                        mac_b <= weights[mac_counter];
                        mac_c <= accumulator;
                        mac_ce <= 1;
                        
                        // Wait a few cycles for MAC to compute, then update accumulator
                        if (mac_counter > 0) begin  // Skip first cycle (pipeline delay)
                            accumulator <= mac_p;
                        end
                        
                        mac_counter <= mac_counter + 1;
                    end else begin
                        // Final accumulation
                        accumulator <= mac_p;
                        mac_ce <= 0;
                    end
                end
                
                ACTIVATION: begin
                    if (!cordic_start) begin
                        // Scale accumulator to CORDIC input range [-1, 1]
                        // Extract most significant bits
                        cordic_in <= accumulator[ACCUM_WIDTH-1:ACCUM_WIDTH-INPUT_WIDTH];
                        cordic_start <= 1;
                    end
                    
                    if (cordic_valid) begin
                        output_data <= cordic_out;
                        cordic_start <= 0;
                    end
                end
                
                DONE: begin
                    output_valid <= 1;
                end
            endcase
        end
    end
    
    // Instantiate Multiply Adder IP (MAC)
    // Connect internal signals to IP ports
   xbip_multadd_0 MAC (
  .CLK(CLK),            // input wire CLK
  .CE(CE),              // input wire CE
  .SCLR(SCLR),          // input wire SCLR
  .A(A),                // input wire [11 : 0] A
  .B(B),                // input wire [11 : 0] B
  .C(C),                // input wire [47 : 0] C
  .SUBTRACT(SUBTRACT),  // input wire SUBTRACT
  .P(P),                // output wire [47 : 0] P
  .PCOUT(PCOUT)        // output wire [47 : 0] PCOUT
);

    // Instantiate CORDIC IP for tanh/sigmoid activation
    // Connect internal signals to IP ports
    cordic_0 CORDIC (
  .aclk(aclk),                                // input wire aclk
  .s_axis_phase_tvalid(s_axis_phase_tvalid),  // input wire s_axis_phase_tvalid
  .s_axis_phase_tdata(s_axis_phase_tdata),    // input wire [15 : 0] s_axis_phase_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),    // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(m_axis_dout_tdata)      // output wire [31 : 0] m_axis_dout_tdata
);

endmodule
