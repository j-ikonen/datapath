library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity regfile is
    generic (
        raw_g  : integer := 5;
        xlen_g : integer := 32
    );
    port (
        clk   : in std_logic;
        rst_n : in std_logic;

        rs1_in : in std_logic_vector(raw_g - 1 downto 0);
        rs2_in : in std_logic_vector(raw_g - 1 downto 0);
        wa_in  : in std_logic_vector(raw_g - 1 downto 0);
        wd_in  : in std_logic_vector(xlen_g - 1 downto 0);
        wen_in : in std_logic;

        rd1_out : out std_logic_vector(xlen_g - 1 downto 0);
        rd2_out : out std_logic_vector(xlen_g - 1 downto 0)
    );
end entity regfile;

-------------------------------------------------------------------------------

architecture rtl of regfile is
    type rarray_t is array (0 to xlen_g - 1) of std_logic_vector(xlen_g - 1 downto 0);
    signal regs : rarray_t;
begin
    regs(0) <= (others => '0');
    rd1_out <= regs(to_integer(unsigned(rs1_in)));
    rd2_out <= regs(to_integer(unsigned(rs2_in)));
 
    write : process (clk, rst_n)
    begin
        if rst_n = '0' then
            regs <= (others => (others => '0'));

        elsif falling_edge(clk) then
            if wen_in = '1' then
                regs(to_integer(unsigned(wa_in))) <= wd_in;
            end if;
        end if;
    end process write;
end architecture rtl;
