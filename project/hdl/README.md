# HDL Project

## Project Structure
``` bash
Tugas1/
├── rtl/         # Verilog source modules (and32.v, or32.v, etc.)
├── tb/          # Testbenches for each module (and32_tb.v, or32_tb.v, etc.)
├── build/       # Output folder for compiled testbenches and waveform files (.vcd)
├── Makefile     # Automation script for build/run/wave/clean
└── README.md    # Documentation
```

## Dependencies

To compile, simulate, and see the wave, we'll use **iverilog** and **gtkwave**.
``` bash
sudo apt update
sudo apt install iverilog
sudo apt install gtkwave
```

## Verilog Process

Run these commands to **build**, **run**, and visualize the **waveform**.
``` bash
# Compile the veriolog code
iverilog -o build/<module>_tb tb/<module>_tb.v rtl/<module>.v
# Run the simulation
vvp build/<module>_tb
# See the waveform result
gtkwave build/<module>_tb.vcd
```

For example, if we want to build, run, and visualize and32 module,
``` bash
iverilog -o build/and32_tb tb/and32_tb.v rtl/and32.v
vvp build/and32_tb
gtkwave build/and32_tb.vcd
```

## Makefile Script
We'll simplify the process by creating a **Makefile** script that runs the compile, simulate, and waveform process.

### Makefile Commands
- **Build:**
  ```bash
  make build MODULE=<module>
  ```
- **Run (Build, Run):**
  ```bash
  make run MODULE=<module>
  ```
- **Waveform (Build, Run, Wave):**
  ```bash
  make wave MODULE=<module>
  ```
- **Clean (Clear the build folder):**
  ```bash
  make clean
  ```