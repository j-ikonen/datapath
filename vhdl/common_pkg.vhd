library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package common is
    constant half_period : time := 10 ns;
    constant xlen_c : integer := 32;            --- The register width
    constant raw_c : integer := 5;            --- Register address width
    constant aluctrlw_c : integer := 4;         --- Width of ALU control signal
    constant iw_c : integer := 12;              --- Width of immediate

    type aluop_t is (
        alu_and, alu_or, alu_add, 
        alu_sub, alu_sll, alu_srl,
        alu_sla, alu_sra
    );

    --- Translate the operator input vector to a enumerated type.
    function slv2aluop(opvec : std_logic_vector(aluctrlw_c-1 downto 0)) return aluop_t;
    function aluop2slv(op : aluop_t) return std_logic_vector;

end package common;

-------------------------------------------------------------------------------

package body common is
    function slv2aluop(opvec : std_logic_vector(aluctrlw_c-1 downto 0)) return aluop_t is 
    begin
        return aluop_t'val(to_integer(unsigned(opvec)));
    end slv2aluop;

    function aluop2slv(op : aluop_t) return std_logic_vector is 
    begin
        return std_logic_vector(to_unsigned(aluop_t'pos(op), aluctrlw_c
));
    end aluop2slv;
    
    
end package body common;