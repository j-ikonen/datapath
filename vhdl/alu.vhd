--- ALU
--- author: Joonas Ikonen <joonas.ikonen@protonmail.com>

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    generic (
        width_g : integer := 32
    );
    port (
        v1_in   : in std_logic_vector(width_g - 1 downto 0);
        v2_in   : in std_logic_vector(width_g - 1 downto 0);
        op_in   : in std_logic_vector(3 downto 0);
        res_out : out std_logic_vector(width_g - 1 downto 0)
    );
end entity alu;

-------------------------------------------------------------------------------

architecture rtl of alu is
    type aluop_t is (alu_and, alu_or, alu_add, alu_sub);

    --- Translate the operator input vector to a enumerated type.
    function to_enum(opvec : std_logic_vector) return aluop_t is
        variable opvec_v : std_logic_vector(3 downto 0);
    begin
        opvec_v := opvec;
        case opvec_v is
            when "0000" => return alu_and;
            when "0001" => return alu_or;
            when "0010" => return alu_add;
            when others => return alu_and;
        end case;
    end to_enum;

begin

    --- State machine for the different ALU operations.
    fsm : process (v1_in, v2_in, op_in)
        variable op_v : aluop_t;
    begin
        op_v := to_enum(op_in); -- Translate the bit vector to enumerated type
        case op_v is
            when alu_and => res_out <= v1_in and v2_in;
            when alu_or => res_out <= v1_in or v2_in;
            when alu_add => res_out <= std_logic_vector(resize(signed(v1_in) + signed(v2_in), width_g));

            when others => res_out <= (others => '0');
        end case;
    end process fsm;

end architecture rtl;
