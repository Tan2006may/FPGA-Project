# Comparative Evaluation of MLP Architectures Using CORDIC+MAC IP and IEEE FP IP+LUT

## Introduction
This project explores the implementation and comparative analysis of two Multilayer Perceptron (MLP) neuron architectures on FPGA platforms. The goal is to balance computational precision, efficiency, and power consumption for neural network inference in real-time edge systems.

The two approaches evaluated are:
1. **IEEE FP IP + LUT**: Utilizes vendor-supplied IEEE 754 floating-point IP cores for multiplication combined with a BRAM-based Look-Up Table (LUT) for sigmoid activation.
2. **CORDIC-MAC**: Implements the sigmoid function approximation using an iterative CORDIC algorithm paired with pipelined MAC IPs for efficient weighted summation.

## Problem Statement
Design, synthesize, and compare two contrasting neuron architectures tailored for FPGA:
- **IEEE FP IP + LUT**: Focused on precision and dynamic range with floating-point computations and BRAM LUTs.
- **CORDIC-MAC**: Focused on low-power, resource-efficient FPGA implementation using iterative CORDIC logic and dedicated MAC IPs.

## Methodology
- RTL design in Verilog integrating IEEE FP and MAC IP cores with custom CORDIC logic
- Synthesis and implementation using Xilinx Vivado tools
- Detailed extraction and analysis of timing metrics: Worst Negative Slack (WNS), Hold Slack (WHS), Pulse Width Slack (WPWS)
- Resource usage evaluation across LUTs, Flip-Flops (FF), BRAMs, and IOs
- Power profiling (static and dynamic)
- Physical layout visualization for floorplanning and area utilization

## Design Details

### IEEE FP IP + LUT
- Prioritizes computational precision using IEEE 754 floating-point IP.
- Sigmoid function is approximated through LUT stored in BRAM.
- Efficient resource usage: 5.27% LUTs, 4.91% FFs, 2% BRAM.
- Timing margins are robust with no timing failures.
- Total on-chip power: 0.072 W (mostly static).
- Physical layout shows compact logic and concentrated BRAM blocks.

### CORDIC-MAC
- Replaces floating-point IP with iterative CORDIC algorithm for sigmoid approximation.
- Utilizes multiple pipelined MAC IP cores for parallel weighted summation.
- Higher logic utilization: 18.66% LUTs, 12.45% FFs, with zero BRAM usage.
- Timing margins similarly robust with no failures.
- Higher total on-chip power: 0.088 W due to increased dynamic logic activity.
- Floorplan shows wider logic distribution reflecting increased LUT/FF use.

## Discussion
- FPIP LUT architecture excels in accuracy, logic resource efficiency, and power consumption due to BRAM and floating-point advantages.
- CORDIC-MAC trades off higher logic usage and dynamic power for BRAM reduction, suitable for embedded, power-sensitive applications.
- Both meet timing requirements with zero failures.
- IO remains a power bottleneck in both designs, highlighting the need for efficient interface design.

## Conclusion
Both FPGA-based MLP implementations are practical for real-time edge neural inference. The choice depends on system design priorities:
- Use **FPIP LUT** for accuracy and power-efficient, resource-conservative implementations.
- Use **CORDIC-MAC** for low-memory, power-aware designs on constrained embedded platforms.

## References
- Design metrics and analyses derived from Xilinx Vivado post-implementation reports.
- Source code and detailed project files: [https://github.com/Tan2006may/FPGA-Project](https://github.com/Tan2006may/FPGA-Project)

