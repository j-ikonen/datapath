library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all;

entity decode is
    port (
        instr_in    : in std_logic_vector(xlen_c - 1 downto 0);
        rs1_out     : out std_logic_vector(raw_c - 1 downto 0);
        rs2_out     : out std_logic_vector(raw_c - 1 downto 0);
        rd_out      : out std_logic_vector(raw_c - 1 downto 0);
        aluctrl_out : out std_logic_vector(aluctrlw_c - 1 downto 0);
        imm_out     : out std_logic_vector(iw_c - 1 downto 0);
    );
end entity decode;

-------------------------------------------------------------------------------

architecture rtl of decode is
    
begin
    
    
    
end architecture rtl;
