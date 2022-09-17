--- ALU
--- author: Joonas Ikonen <joonas.ikonen@protonmail.com>

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all; --- aluop_t type and it's conversion function.

entity alu is
    generic (
        width_g : integer := 32
    );
    port (
        v1_in   : in std_logic_vector(width_g - 1 downto 0);
        v2_in   : in std_logic_vector(width_g - 1 downto 0);
        op_in   : in std_logic_vector(w_aluctrl_c - 1 downto 0);
        res_out : out std_logic_vector(width_g - 1 downto 0)
    );
end entity alu;

-------------------------------------------------------------------------------

architecture rtl of alu is
begin

    --- State machine for the different ALU operations.
    fsm : process (v1_in, v2_in, op_in)
        variable op_v : aluop_t;
    begin
        op_v := slv2aluop(op_in); -- Translate the bit vector to enumerated type
        case op_v is
            when alu_and => res_out <= v1_in and v2_in;
            when alu_or => res_out <= v1_in or v2_in;
            when alu_add => res_out <= std_logic_vector(resize(signed(v1_in) + signed(v2_in), width_g));
            when alu_sub => res_out <= std_logic_vector(resize(signed(v1_in) - signed(v2_in), width_g));
            when alu_sll => res_out <= std_logic_vector(shift_left(unsigned(v1_in), to_integer(unsigned(v2_in))));
            when alu_srl => res_out <= std_logic_vector(shift_right(unsigned(v1_in), to_integer(unsigned(v2_in))));
            when alu_sla => res_out <= std_logic_vector(shift_left(signed(v1_in), to_integer(unsigned(v2_in))));
            when alu_sra => res_out <= std_logic_vector(shift_right(signed(v1_in), to_integer(unsigned(v2_in))));
            when others => res_out <= (others => '0');
        end case;
    end process fsm;

end architecture rtl;
