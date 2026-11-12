Classical CAN 2.0A Protocol Controller Simulation

Verilog HDL | Arduino Uno | Python | Xilinx Vivado

Overview

This project implements an educational simulation of a Classical CAN 2.0A (Controller Area Network) protocol controller using Verilog HDL.

The project demonstrates CAN frame construction, CRC-15 generation, bit stuffing, serial transmission, receiver loopback capture, and identifier-based arbitration.

An Arduino Uno generates simulated vehicle sensor measurements, while Python collects the data through USB serial communication and converts it into test vectors for Verilog simulation in Xilinx Vivado.

The primary objective is to understand CAN protocol fundamentals and demonstrate digital communication system design using HDL-based simulation.

Project scope: This is a simulation-based educational implementation. It does not use a physical CAN transceiver or establish communication over a real CAN bus.


<img width="1226" height="1283" alt="CAN Controller System Flowchart" src="https://github.com/user-attachments/assets/78fa0638-b80d-4bf6-87cf-a498b5489e19" />


**Features**

Classical CAN 2.0A standard frame format.

Standard 11-bit CAN identifier.

Data payload support of up to 8 bytes.

CRC-15 generation using polynomial 0x4599.

CAN bit stuffing after five consecutive identical bits.

Serial CAN frame transmission using Verilog.

Receiver loopback capture for simulation verification.

Basic CAN identifier arbitration.

Arduino-based sensor data generation.

Python-based serial data acquisition and test-vector generation.

Behavioral simulation using Xilinx Vivado.
