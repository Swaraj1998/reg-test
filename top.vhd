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

    attribute MARK_DEBUG of ftmt_f2p_debug : signal is "TRUE";
    attribute MARK_DEBUG of ftmt_p2f_debug : signal is "TRUE";

    alias clk : std_logic is ftmt_p2f_debug(31);
    alias ena : std_logic is ftmt_p2f_debug(30);
    alias rst : std_logic is ftmt_p2f_debug(29);

    --
    type T_INIT_VAL is array (0 to NUM_LUTS-1)
        of bit_vector (63 downto 0);
    constant INIT_VAL : T_INIT_VAL := (
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001",
            X"0000000000000001" );

    --
    type T_NUM_CHAR is array (0 to 9) of string (1 to 1);
    constant NUM_CHAR : T_NUM_CHAR :=
        ("0","1","2","3","4","5","6","7","8","9");

    function itoa (x : integer) return string is
        variable n : integer := x;
    begin
        if n < 0 then return "-" & itoa(-n);
        elsif n < 10 then return NUM_CHAR(n);
        else return itoa(n/10) & NUM_CHAR(n rem 10);
        end if;
    end function itoa;

begin

    ps7_stub_inst : entity work.ps7_stub
    port map (
        ftmt_f2p_debug => ftmt_f2p_debug,
        ftmt_p2f_debug => ftmt_p2f_debug );

    GEN_REG : for N in 0 to NUM_LUTS-1 generate
        attribute DONT_TOUCH of LUT6_2_inst : label is "TRUE";
        attribute DONT_TOUCH of FDRE_O6_inst : label is "TRUE";
        attribute DONT_TOUCH of FDRE_O5_inst : label is "TRUE";
        --
        signal O6 : std_logic;
        signal O5 : std_logic;
        --
        constant rloc_str : string := "X0" & "Y" & itoa(N/4);
        attribute RLOC of LUT6_2_inst : label is rloc_str; 
        attribute RLOC of FDRE_O6_inst : label is rloc_str; 
        attribute RLOC of FDRE_O5_inst : label is rloc_str; 
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
            O6 => O6,
            O5 => O5 );

        FDRE_O6_inst : FDRE
        generic map (
            INIT => '0' )
        port map (
            Q => ftmt_f2p_debug(NUM_LUTS + N),
            C => clk,
            CE => ena,
            R => rst,
            D => O6 );

        FDRE_O5_inst : FDRE
        generic map (
            INIT => '0' )
        port map (
            Q => ftmt_f2p_debug(N),
            C => clk,
            CE => ena,
            R => rst,
            D => O5 );
    end generate GEN_REG;

end architecture RTL;
