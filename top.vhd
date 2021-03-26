library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

use work.vivado_pkg.ALL;

entity top is
end entity top;

architecture RTL of top is
    attribute LOC : string;
    --attribute LOC of LUT5_inst : label is "SLICE_X0Y0";
    attribute DONT_TOUCH of LUT5_inst : label is "TRUE";
    attribute MARK_DEBUG of LUT5_inst : label is "TRUE";

    --signal emio_gpio_i : std_logic_vector (63 downto 0);
    --signal emio_gpio_o : std_logic_vector (63 downto 0);

    -- PS7 FTMT Debug Signals
    signal ftmt_f2p_debug : std_logic_vector (31 downto 0);
    signal ftmt_p2f_debug : std_logic_vector (31 downto 0);

    attribute MARK_DEBUG of ftmt_p2f_debug : signal is "TRUE";

begin
    ps7_stub_inst : entity work.ps7_stub
    port map (
        ftmt_f2p_debug => ftmt_f2p_debug,
        ftmt_p2f_debug => ftmt_p2f_debug );

    LUT5_inst : LUT5
    generic map (
        INIT => X"80000001" )
    port map (
        I0 => ftmt_p2f_debug(0),
        I1 => ftmt_p2f_debug(1),
        I2 => ftmt_p2f_debug(2),
        I3 => ftmt_p2f_debug(3),
        I4 => ftmt_p2f_debug(4),
        O => ftmt_f2p_debug(0) );

end architecture RTL;
