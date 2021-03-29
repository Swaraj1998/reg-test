library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

use work.vivado_pkg.ALL;

entity top is
    generic (
        NUM_LUTS : natural := 16
    );
end entity top;

architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    -- PS7 FTMT Debug Signals
    signal ftmt_f2p_debug : std_logic_vector (31 downto 0);
    signal ftmt_p2f_debug : std_logic_vector (31 downto 0);

    attribute MARK_DEBUG of ftmt_p2f_debug : signal is "TRUE";

    alias clk : std_logic is ftmt_p2f_debug(31); 
    alias ena : std_logic is ftmt_p2f_debug(30);
    alias rst : std_logic is ftmt_p2f_debug(29);

    --

    signal O6_vec : std_logic_vector (15 downto 0);
    signal O5_vec : std_logic_vector (15 downto 0);

    type T_INIT_VAL is array (0 to NUM_LUTS-1)
        of bit_vector (63 downto 0);
    constant INIT_VAL : T_INIT_VAL := (
            X"AAAAAAAAAAAAAAAA",
            X"CCCCCCCCCCCCCCCC",
            X"F0F0F0F0F0F0F0F0",
            X"FF00FF00FF00FF00",
            X"FFFF0000FFFF0000",
            X"AAAAAAAAAAAAAAAA",
            X"CCCCCCCCCCCCCCCC",
            X"F0F0F0F0F0F0F0F0",
            X"FF00FF00FF00FF00",
            X"FFFF0000FFFF0000",
            X"AAAAAAAAAAAAAAAA",
            X"CCCCCCCCCCCCCCCC",
            X"F0F0F0F0F0F0F0F0",
            X"FF00FF00FF00FF00",
            X"FFFF0000FFFF0000",
            X"AAAAAAAAAAAAAAAA" );

begin

    ps7_stub_inst : entity work.ps7_stub
    port map (
        ftmt_f2p_debug => ftmt_f2p_debug,
        ftmt_p2f_debug => ftmt_p2f_debug );

    GEN_REG : for N in 0 to NUM_LUTS-1 generate
        attribute DONT_TOUCH of LUT6_2_inst : label is "TRUE";
        attribute DONT_TOUCH of FDRE_O6_inst : label is "TRUE";
        attribute DONT_TOUCH of FDRE_O5_inst : label is "TRUE";
    begin
        LUT6_2_inst : LUT6_2
        generic map (
            INIT => INIT_VAL(N) )
        port map (
            I0 => ftmt_p2f_debug(0),
            I1 => ftmt_p2f_debug(1),
            I2 => ftmt_p2f_debug(2),
            I3 => ftmt_p2f_debug(3),
            I4 => ftmt_p2f_debug(4),
            I5 => ftmt_p2f_debug(5),
            --
            O6 => O6_vec(N),
            O5 => O5_vec(N) );

        FDRE_O6_inst : FDRE
        generic map (
            INIT => '0' )
        port map (
            Q => ftmt_f2p_debug(NUM_LUTS + N),
            C => clk,
            CE => ena,
            R => rst,
            D => O6_vec(N) );

        FDRE_O5_inst : FDRE
        generic map (
            INIT => '0' )
        port map (
            Q => ftmt_f2p_debug(N),
            C => clk,
            CE => ena,
            R => rst,
            D => O5_vec(N) );
    end generate GEN_REG;

end architecture RTL;
