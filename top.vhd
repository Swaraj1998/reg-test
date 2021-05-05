library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

use work.vivado_pkg.ALL;

entity top is
end entity top;

architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    attribute REG_NAME : string;
    attribute REG_NAME of reg_inst : label is "REG_16_BOOL";
    attribute REG_NAME of reg_inst_1 : label is "REG_32_CONST";

    -- PS7 FTMT Debug Signals
    signal ftmt_f2p_debug : std_logic_vector (31 downto 0);
    signal ftmt_p2f_debug : std_logic_vector (31 downto 0);

    --attribute MARK_DEBUG of ftmt_f2p_debug : signal is "TRUE";
    --attribute MARK_DEBUG of ftmt_p2f_debug : signal is "TRUE";

    alias clk : std_logic is ftmt_p2f_debug(31);
    alias ena : std_logic is ftmt_p2f_debug(30);
    alias rst : std_logic is ftmt_p2f_debug(29);

    signal vec_tmp : std_logic_vector (31 downto 0);
    attribute MARK_DEBUG of vec_tmp : signal is "TRUE";

begin

    ps7_stub_inst : entity work.ps7_stub
    port map (
        ftmt_f2p_debug => ftmt_f2p_debug,
        ftmt_p2f_debug => ftmt_p2f_debug );

    reg_inst : entity work.reg
    generic map (
        IN_WIDTH => 1,
        OUT_WIDTH => 16 )
    port map (
        clk => clk,
        ena => ena,
        rst => rst,
        in_vec => ( 0 => ftmt_p2f_debug(0), others => '0' ),
        out_vec => ftmt_f2p_debug );

    reg_inst_1 : entity work.reg
    generic map (
        IN_WIDTH => 0,
        OUT_WIDTH => 32 )
    port map (
        clk => clk,
        ena => ena,
        rst => rst,
        in_vec => ( others => '0' ),
        out_vec => vec_tmp );

end architecture RTL;
