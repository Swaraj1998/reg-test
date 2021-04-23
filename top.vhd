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

    -- PS7 FTMT Debug Signals
    signal ftmt_f2p_debug : std_logic_vector (31 downto 0);
    signal ftmt_p2f_debug : std_logic_vector (31 downto 0);

    attribute MARK_DEBUG of ftmt_f2p_debug : signal is "TRUE";
    attribute MARK_DEBUG of ftmt_p2f_debug : signal is "TRUE";

    alias clk : std_logic is ftmt_p2f_debug(31);
    alias ena : std_logic is ftmt_p2f_debug(30);
    alias rst : std_logic is ftmt_p2f_debug(29);

begin

    ps7_stub_inst : entity work.ps7_stub
    port map (
        ftmt_f2p_debug => ftmt_f2p_debug,
        ftmt_p2f_debug => ftmt_p2f_debug );

    reg_inst : entity work.reg
    port map (
        clk => clk,
        ena => ena,
        rst => rst,
        in_vec => ftmt_p2f_debug(5 downto 0),
        out_vec => ftmt_f2p_debug );

end architecture RTL;
