# FPGA-based MLP Implementation Using CORDIC/MAC IP and IEEE FP IP/LUT

---

## Table of Contents

1. [Overview](#overview)  
2. [Introduction](#introduction)  
3. [Methodology](#methodology)  
   3.1 [IEEE FP IP LUT Approach](#ieee-fp-ip-lut-approach)  
   3.2 [CORDIC-MAC Approach](#cordic-mac-approach)  
4. [Results](#results)  
5. [Discussion](#discussion)  
6. [Conclusion](#conclusion)  
7. [References](#references)  

---

## Overview

This project investigates two distinct FPGA-based neuron and Multilayer Perceptron (MLP) architectures. One design uses vendor-provided IEEE 754 floating-point multiplication IP combined with a Look-Up Table (LUT) implementation of the sigmoid activation function, while the other leverages hardware-optimized CORDIC (COordinate Rotation DIgital Computer) and MAC (Multiply-Accumulate) IP cores to achieve resource efficiency and speed.

Both designs are implemented, synthesized, and post-implementation hardware metrics such as timing, resource utilization, power, and physical layout are analyzed and compared.

---

## Introduction

Artificial neural networks are increasingly deployed on hardware for real-time and signal processing tasks, with FPGAs providing the parallelism and reconfigurability needed. Neurons compute weighted sums of inputs plus bias followed by a nonlinear activation like sigmoid.

An MLP consists of layers of such neurons, allowing complex function learning through nonlinear compositions. Efficient hardware implementations require balancing precision, resource usage, and speed.

---

## Methodology

### IEEE FP IP LUT Approach

- Uses FPGA vendor IEEE 754 floating-point multiplication IP for precise weighted sums.
- Implements sigmoid activation function using a precomputed BRAM-based LUT for fast evaluation.
- Emphasizes high numerical precision with modest memory usage.
- Operates within timing constraints with no failing endpoints.
- Utilizes minimal logic resources (LUTs, FFs), with some BRAM usage for LUT storage.

### CORDIC-MAC Approach

- Employs CORDIC algorithm hardware IP to compute nonlinear sigmoid function using iterative shift-add operations, reducing logic complexity.
- Uses pipelined MAC IP cores for high-throughput multiply-accumulate computations.
- Focuses on minimizing power and resource usage while maintaining throughput.
- Successfully meets timing constraints with efficient hardware utilization.
- Relies less on BRAM with slightly higher LUT and FF counts than the IEEE FP LUT approach.

---

## Results

| Metric               | IEEE FP IP LUT | CORDIC-MAC   |
|----------------------|----------------|--------------|
| LUTs Used            | 32             | 41           |
| Flip-Flops Used      | 33             | 69           |
| IO Used              | 66             | 64           |
| Worst Negative Slack (ns) | 7.776          | 7.632        |
| Worst Pulse Width Slack (ns) | 4.5            | 4.5          |
| Total On-Chip Power (W)    | 0.117          | 0.07         |
| Junction Temperature (°C)  | 25.6           | 25.3         |

- All timing constraints were met with comfortable slack values.
- The CORDIC-MAC approach achieves notable power savings compared to the IEEE FP IP LUT, at the cost of increased LUT and FF usage.
- IO utilization is a primary bottleneck in both designs.

---

## Discussion

The IEEE FP IP LUT design provides excellent numeric precision and is highly logic-efficient, thanks to dedicated floating-point units and BRAM-based sigmoid LUTs. However, it consumes more power primarily due to BRAM usage.

The CORDIC-MAC implementation is optimized for low power, reducing BRAM dependency by computing activation functions algorithmically. It requires more logic elements but achieves roughly 40% lower power consumption.

Both designs successfully meet post-synthesis timing and resource goals and can be chosen based on target application requirements: accuracy vs. power/efficiency trade-offs.

---

## Conclusion

Both FPGA-based neuron architectures have been fully implemented, synthesized, and verified, meeting all functional and timing criteria.

- Use IEEE FP IP LUT architecture when accuracy and maintainability are critical.
- Use CORDIC-MAC design for power-sensitive deployments and energy-efficient hardware.

---

## References

- Xilinx Vivado Implementation Reports
- FPGA vendor IP documentation
- CORDIC algorithm literature
- Neural network hardware design research

---


