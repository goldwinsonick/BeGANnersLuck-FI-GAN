# Frame Interpolation GAN

**Target Platform:** Xilinx Pynq-Z1 (XC7Z020)

**Design Constraints:** < 220 DSPs, < 4.9Mb BRAM

**Operation Mode:** Real-time Inference (Hardware), Training (Software/PyTorch)

## System Architecture

### 1. System Interface & Data Types

| Parameter | Specification | Notes |
| :--- | :--- | :--- |
| **Input Format** | 2 Frames ($I_{t-1}, I_{t+1}$) | Previous & Next Frame |
| **Input Dimension** | $32 \times 32$ pixels | Patch/Tile processing |
| **Color Space** | Grayscale (1 Channel) | Y-Channel (Luminance) only |
| **Data Precision** | **Fixed-Point Q6.10** | Signed 16-bit |
| **Bit Distribution** | `[15]`: Sign, `[14:10]`: Integer, `[9:0]`: Fractional | Range: -32.0 to +31.99 |
| **Input Tensor Shape** | `[Batch, 2, 32, 32]` | Channel 0: Prev, Channel 1: Next |
| **Output Tensor Shape** | `[Batch, 1, 32, 32]` | Channel 0: Interpolated Frame |

---

### 2. Generator Architecture (Micro U-Net)

The generator is a fully convolutional Auto-Encoder with skip connections (conceptually) or straight bottleneck (for simplicty). It uses strided convolutions for downsampling and transposed convolutions for upsampling.

**Total Estimated Parameters:** ~82,500
**Total Estimated DSP Usage:** ~140 - 160 DSPs (depending on implementation reuse).

#### Layer Specification Table

| Layer Name | Type | Kernel Size | Stride | Input Channels | Output Channels | Output Resolution | Activation | Logic / Hardware Notes |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Input** | - | - | - | 2 | - | $32 \times 32$ | - | Stream Interleaving / Concatenation |
| **Enc_1** | Conv2d | $3 \times 3$ | 1 | 2 | **16** | $32 \times 32$ | LeakyReLU (0.2) | Feature Extraction. Requires Line Buffer size 32. |
| **Enc_2** | Conv2d | $4 \times 4$ | 2 | 16 | **32** | $16 \times 16$ | LeakyReLU (0.2) | Downsampling. Skips every other pixel (Spatial Reduction). |
| **Enc_3** | Conv2d | $4 \times 4$ | 2 | 32 | **64** | $8 \times 8$ | LeakyReLU (0.2) | **Bottleneck**. Highest Semantic Info, Lowest Resolution. |
| **Dec_1** | TranspConv | $4 \times 4$ | 2 | 64 | **32** | $16 \times 16$ | ReLU | Upsampling. Inserts zeros then convolves. |
| **Dec_2** | TranspConv | $4 \times 4$ | 2 | 32 | **16** | $32 \times 32$ | ReLU | Upsampling back to original resolution. |
| **Output** | Conv2d | $3 \times 3$ | 1 | 16 | **1** | $32 \times 32$ | Tanh | Final Pixel Generation. Output Range [-1.0, 1.0]. |

---

### 3. Hardware Implementation Details (Verilog/HLS)

#### A. Memory Hierarchy (BRAM)
* **Line Buffers:**
    * Designed for **32 pixel width**.
    * Max depth needed: 3 rows (for 4x4 kernels).
    * Estimated usage: ~150 Kbits (Very Safe).
* **Weight Storage:**
    * Weights are pre-loaded into BRAM (ROM).
    * Total Weight Size: ~1.32 Mbits.
    * Weights must be converted from PyTorch `float32` to `Q6.10` hex before synthesis.

#### B. Computation Logic
* **Multiplication:** Uses hard macro DSP48E1 slices.
* **Activation Functions:**
    * **LeakyReLU:** Simple arithmetic logic (`if x < 0: x = x >> 3` approx).
    * **Tanh:** Implemented via Look-Up Table (LUT) stored in BRAM or logic approximation.
* **Padding:**
    * "Same" padding logic applied at boundaries to maintain 32x32 resolution at input/output layers.

---

### 4. Training Strategy (Python/PyTorch)

* **Dataset:** Vimeo90k subset
* **Preprocessing:**
    1.  Convert to Grayscale.
    2.  Crop random $32 \times 32$ patches.
    3.  Normalize pixel values to range `[-1.0, 1.0]` (to match Tanh output).
* **Loss Function:** L1 Loss (MAE) or MSE Loss between *Generated Frame* and *Ground Truth Frame*.
* **Epochs:** -

---

## Verilog Implementation

### 5. Verilog Implementation

The hardware design follows a **Streaming Architecture** (Pipeline) approach to maximize throughput and minimize memory usage. The system does not store intermediate frames in DDR memory; instead, data flows directly from one layer to the next via local buffers (FIFOs and Line Buffers).

#### A. Module Hierarchy & Description

| Module Name | Filename | Description |
| --- | --- | --- |
| **Top Level** | `generator.v` | The top-level wrapper that instantiates all layers (Encoders and Decoders) and handles the global wiring (Valid/Ready signals and Data streams). |
| **Line Buffer** | `line_buffer.v` | A shift-register based RAM module. Stores `(Kernel_Size - 1)` rows of pixels. Instantiated multiple times within convolution modules to form the sliding window (e.g., 3 instances for 4x4 kernel). |
| **Conv Unit (3x3)** | `conv2d_3x3.v` | Performs standard convolution with Stride 1. Used for the Input Layer and Output Layer. Contains 9 Multipliers (DSPs) and an Adder Tree. |
| **Conv Unit (4x4)** | `conv2d_4x4.v` | The primary computation unit. Supports **Stride 1** (for Decoder) and **Stride 2** (for Encoder downsampling). Contains 16 Multipliers (DSPs). |
| **Upsampler** | `upsampler.v` | **Zero-Insertion Logic.** Converts a 16x16 input stream into a 32x32 sparse stream by inserting zeros horizontally and vertically. Used prior to convolution in the Decoder stages to achieve Transposed Convolution. |
| **FIFO** | `fifo.v` | **Synchronous FIFO.** Acts as a buffer/bridge between layers, specifically between the Encoder and Upsampler, to handle backpressure (flow control) when the Upsampler pauses to insert zero rows. |
| **Activation** | `activation_*.v` | `activation_leaky.v` uses shift logic (`val >>> 3`) for negative inputs. `activation_tanh.v` uses a ROM-based Look-Up Table (LUT) initialized via `.mem` file. |
| **Math Core** | `qmult.v` | Signed Fixed-Point (Q6.10) multiplier wrapper. Synthesizes to DSP48E1 slices. |
| **Weight ROMs** | `w_layerX.v` | Hardcoded `assign` statements generated via Python. Provides simultaneous parallel access to all kernel weights (9 or 16 weights) in a single clock cycle. |

#### B. Data Flow Strategy

1. **Streaming Interface:**
* Data is passed between modules using a `valid`, `data`, and (optional) `ready` handshake interface.
* **Encoders:** Perform downsampling. Input data rate is full, output `valid` signal is high only 25% of the time (due to Stride 2 skipping pixels).
* **Decoders:** Perform upsampling. Input data rate is slow, output `valid` signal is restored to full rate via the Upsampler.


2. **Transposed Convolution Implementation (Upsampler + Conv):**
* Instead of complex sub-pixel logic, we utilize a **"Zero Insertion + Standard Convolution"** strategy for feasibility.
* **Step 1:** The `upsampler.v` receives data and inserts zero padding (Horizontal: `Data -> 0 -> Data`; Vertical: `Row_Data -> Row_Zero`).
* **Step 2:** The `conv2d_4x4.v` (configured with Stride 1) processes this sparse stream. The non-zero weights in the kernel "smear" the pixel values into the zero positions, effectively performing interpolation.


3. **Memory Management:**
* **Line Buffers:** Use "Inferred RAM" style arrays in Verilog. The synthesis tool (Vivado) automatically maps these to Distributed RAM (LUTRAM) or Block RAM (BRAM) based on size.
* **Weights:** Implemented as logic constants to ensure high-bandwidth parallel access without the bottleneck of BRAM read ports.



#### C. Resource Estimation Breakdown

* **DSP Usage:**
* Enc1 (3x3): 9 DSPs
* Enc2 (4x4): 16 DSPs
* Enc3 (4x4): 16 DSPs
* Dec1 (4x4): 16 DSPs
* Dec2 (4x4): 16 DSPs
* Out (3x3): 9 DSPs
* **Total:** **82 DSPs** (Well within the 220 DSP limit of Pynq-Z1).


* **BRAM Usage:**
* Minimal usage. Primary consumption comes from Tanh LUTs and FIFO buffers. Line buffers are small enough to likely fit in LUTRAM, leaving BRAM available for system-level frame buffering if needed.

#### D. Project Structure

The project is structured as below.

```
verilog
├── build/          (.vcd)
├── data/
│   ├── test_1/      (.csv)
│   ├── test_2/      (.csv)
│   ├── test_...
│   └── memory/     (.mem)
├── rtl/            (.v)
├── tb              (.v)
├── Makefile
└── FIGAN.ipynb     (Python Notebook File)
```
