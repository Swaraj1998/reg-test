library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

use work.vivado_pkg.ALL;

entity reg is
    generic (
        NUM_LUTS : natural := 16;
        IN_WIDTH : natural := 6;
        OUT_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;
        ena : in std_logic;
        rst : in std_logic;
        --
        in_vec  : in std_logic_vector (IN_WIDTH-1 downto 0);
        out_vec : out std_logic_vector (OUT_WIDTH-1 downto 0)
    );
end entity reg;

architecture RTL of reg is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

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
            I0 => in_vec(0),
            I1 => in_vec(1),
            I2 => in_vec(2),
            I3 => in_vec(3),
            I4 => in_vec(4),
            I5 => in_vec(5),
            --
            O6 => O6,
            O5 => O5 );

        FDRE_O6_inst : FDRE
        generic map (
            INIT => '0' )
        port map (
            Q => out_vec(NUM_LUTS + N),
            C => clk,
            CE => ena,
            R => rst,
            D => O6 );

        FDRE_O5_inst : FDRE
        generic map (
            INIT => '0' )
        port map (
            Q => out_vec(N),
            C => clk,
            CE => ena,
            R => rst,
            D => O5 );
    end generate GEN_REG;

end architecture RTL;
