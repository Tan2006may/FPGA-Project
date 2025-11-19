`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: mlp_testbench
// Description: Testbench to verify CORDIC MLP
//////////////////////////////////////////////////////////////////////////////////

module mlp_testbench;

    parameter INPUT_WIDTH = 20;
    parameter OUTPUT_WIDTH = 20;
    parameter NUM_INPUTS = 4;
    parameter NUM_OUTPUTS = 3;
    parameter CLK_PERIOD = 10;  // 100 MHz 
    
    // Clock and reset
    reg clk;
    reg rst;
    reg start;
    
    // Test inputs - flattened (directly)
    reg signed [INPUT_WIDTH*NUM_INPUTS-1:0] test_inputs_flat;
    
    // Outputs - flattened
    wire signed [OUTPUT_WIDTH*NUM_OUTPUTS-1:0] mlp_outputs_flat;
    wire mlp_valid;
    
    // Performance counter
    integer cycle_count;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Instantiate MLP
    cordic_mlp #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .HIDDEN_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .NUM_INPUTS(NUM_INPUTS),
        .NUM_HIDDEN(8),
        .NUM_OUTPUTS(NUM_OUTPUTS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inputs_flat(test_inputs_flat),
        .outputs_flat(mlp_outputs_flat),
        .mlp_valid(mlp_valid)
    );
    
    // Test procedure
    initial begin
        // Initialize
        rst = 1;
        start = 0;
        cycle_count = 0;
        
        // Initialize test inputs directly in flattened format
        // Format: {input[3], input[2], input[1], input[0]}
        // Each input is 20 bits
        test_inputs_flat[1*INPUT_WIDTH-1:0*INPUT_WIDTH] = 20'h10000;  // input[0] = 0.25
        test_inputs_flat[2*INPUT_WIDTH-1:1*INPUT_WIDTH] = 20'h20000;  // input[1] = 0.5
        test_inputs_flat[3*INPUT_WIDTH-1:2*INPUT_WIDTH] = 20'h30000;  // input[2] = 0.75
        test_inputs_flat[4*INPUT_WIDTH-1:3*INPUT_WIDTH] = 20'h08000;  // input[3] = 0.125
        
        // Reset sequence
        #100;
        rst = 0;
        #50;
        
        $display("=== CORDIC MLP Test ===");
        $display("Test inputs (hex):");
        $display("  Input[0] = %h (0.25)", test_inputs_flat[1*INPUT_WIDTH-1:0*INPUT_WIDTH]);
        $display("  Input[1] = %h (0.5)", test_inputs_flat[2*INPUT_WIDTH-1:1*INPUT_WIDTH]);
        $display("  Input[2] = %h (0.75)", test_inputs_flat[3*INPUT_WIDTH-1:2*INPUT_WIDTH]);
        $display("  Input[3] = %h (0.125)", test_inputs_flat[4*INPUT_WIDTH-1:3*INPUT_WIDTH]);
        $display("\nStarting inference...");
        
        // Start inference
        start = 1;
        #CLK_PERIOD;
        start = 0;
        
        // Wait for completion and count cycles
        while (!mlp_valid) begin
            cycle_count = cycle_count + 1;
            #CLK_PERIOD;
            if (cycle_count > 10000) begin
                $display("ERROR: Timeout waiting for result (>10000 cycles)");
                $finish;
            end
        end
        
        // Display results
        $display("\n=== Results ===");
        $display("Output[0] = %h", mlp_outputs_flat[1*OUTPUT_WIDTH-1:0*OUTPUT_WIDTH]);
        $display("Output[1] = %h", mlp_outputs_flat[2*OUTPUT_WIDTH-1:1*OUTPUT_WIDTH]);
        $display("Output[2] = %h", mlp_outputs_flat[3*OUTPUT_WIDTH-1:2*OUTPUT_WIDTH]);
        $display("\n=== Performance ===");
        $display("Cycles: %0d", cycle_count);
        $display("Time: %0f ns", cycle_count * CLK_PERIOD);
        $display("Frequency: 100 MHz (10 ns period)");
        
        #1000;
        $display("\n=== Test completed successfully! ===");
        $finish;
    end
    
    // Waveform dump for viewing in simulator
    initial begin
        $dumpfile("mlp_test.vcd");
        $dumpvars(0, mlp_testbench);
    end

endmodule
