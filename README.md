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



