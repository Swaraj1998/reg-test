# reg-test
An implementation of resource-friendly custom register sets in Xilinx Zynq FPGA fabric which are accessed/modified using Partial Dynamic Reconfiguration in AXIOM Beta

## Instructions

On your local machine:
1. Install Vivado 2020.2. Make sure this version of Vivado is in your PATH.
2. Clone this repository with "--recursive" option in git and change directory to it
3. Run <code> $ ./build.sh </code>, which builds the design using Vivado and produces necessary database files
<br>i.e. <code>build/reg_slice_map.db</code> and <code>build/slice_lut_db_min.json</code>
4. Copy over the full bitstream file <code>build/reg_test.bin</code> to the Zynq device

On the Zynq device (AXIOM Beta):
1. Clone this repository with "--recursive" option in git and change directory to it
2. Configure the FPGA with the full bitstream file, you may use <code>scripts/xilinx-devcfg/devcfg.py</code> like this:
<br><code># python devcfg.py write reg_test.bin</code>, which uploads the bitfile <code>reg_test.bin</code> using the PCAP interface
3. <code>$ mkdir build </code> and copy over <code>build/reg_slice_map.db</code> and <code>build/slice_lut_db_min.json</code> to this build directory from your local machine
4. <code>$ cd scripts</code> and you can use the main script to read/write register values in the FPGA:
<br><code># reg.py REG_32_CONST 0 -r</code>, will read the value from the <code>REG_32_CONST</code> named register instance and 0th register index (from [0-31])
<br><code># reg.py REG_32_CONST 0 -w 0xdeadbeef</code>, will write the value "0xdeadbeef" to the specified register

## Scripts

- <code>xilinx-devcfg/devcfg.py</code>: Used to access the PCAP interface in Xilinx Zynq to read/write full/partial bitstreams
- <code>gen_partial_bitstream.py</code>: Generates partial bitstream from a full bitstream using the specified frame addresses
- <code>gen_slice_lut_db.py</code>: Generates a custom database file (i.e. scripts/slice_lut_db.json) from Project X-Ray's Zynq database for bitstream information
- <code>loc2addr.py</code>: Show frame addresses associated with a slice location (e.g. SLICE_X26Y114/A6LUT)
- <code>bitmod_init.py</code>: Tool to read/modify LUT INIT values in a Xilinx Zynq bitstream
- <code>reg2addr.py</code>: Show frame addresses that can configure a register instance (e.g. REG_32_CONST)
- <code>gen_slice_lut_db_min.py</code>: Generates a minimal database file (i.e. build/slice_lut_db_min.json) out of the master database file (i.e. scripts/slice_lut_db.json) as per the resources used by the design (after build)
- <code>bit2bin.py</code>: Reverse the endianness of a bit file to produce bin file
- <code>reg.py</code>: Main script to read/write register values from/to a register in the FPGA
<br><br>

> For more details, please refer to my final project report (submitted to my university for graduation on 15/05/2021) here: https://drive.google.com/file/d/1M6ZfTNf18en3QO0V77vp02iDad84V1jI/view?usp=sharing

