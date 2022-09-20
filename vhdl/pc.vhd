library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc is
    generic (
        addrw_g : integer := 32;
        amax_g : integer := 1023
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en_in : in std_logic;
        amnt_in : in std_logic_vector(addrw_g-1 downto 0);
        pc_out : out std_logic_vector(addrw_g-1 downto 0)
    );
end entity pc;

-------------------------------------------------------------------------------

architecture rtl of pc is
    signal pc_r : integer range 0 to amax_g;
begin
    --- Set the program counter register to pc output.
    pc_out <= std_logic_vector(to_unsigned(pc_r, addrw_g));

    --- Increment the program counter if enable is high.
   increment_pc: process(clk, rst_n)
   begin
    if rst_n = '0' then
        pc_r <= 0;

    elsif rising_edge(clk) then
        if en_in = '1' then
            pc_r <= pc_r + to_integer(unsigned(amnt_in));
        else
            pc_r <= pc_r;
        end if;
    end if;
   end process increment_pc;
    
end architecture rtl;