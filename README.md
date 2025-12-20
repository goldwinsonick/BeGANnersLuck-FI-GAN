# BeGANnersLuck-FI-GAN : FPGA-based GAN Architecture
**Submission for VLSI System Design Final Exam & LSI Design Contest 2026**

This project aims to design an FPGA-based GAN Architecture for Frame Interpolation. This project is worked on for LSI Contest 2026 and VLSI System Design Final Exam.

## 👥 Team Members (Group 7)
* **Ihsan Hidayat Rafi** (13222065)
* **Goldwin Sonick** (13222067)
* **Ibrahim Hanif Mulyana** (13222111)

## 📌 Technical Specifications
* **Architecture:** Fully Connected Neural Network (Generator & Discriminator).
* **Data Format:** **Fixed-Point Q8.8** (1 sign, 7 integer, 8 fractional bits).
* **Optimization:** * **Pipelining:** 2-Stage pipeline (Hidden Layer → Output Layer) to increase throughput.
  * **Spatial Unrolling:** Parallel computation of neurons to maximize speed over area efficiency.
* **Verification:** Bit-true comparison against MATLAB reference model (Result Score: ~0.3008 vs MATLAB 0.3672).
* 
## 📂 Project Structure
```
BeGANnersLuck-FI-GAN
├── docs            (Documentation)
├── SimpleGAN
│   ├── matlab      (matlab file (from LSI website, extracted files)
│   └── verilog  
|        ├── data (Extracted csv)
|        ├── rtl (Verilog implementation)
|        ├── tb (Testbench)
|        ├── SimpleGAN.ipynb
|        └── Makefile
├── test/pwl   (Tugas PWL)
└── README.md
```

Project Links:
- [**HDL Project**](./project/hdl/README.md)
