library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all; --- aluop_t type and it's conversion function.

entity tb_alu is
end entity tb_alu;

architecture behaviour of tb_alu is
    type values_t is array (0 to 6, 0 to 2) of integer;
    type ops_t is array (0 to 6) of aluop_t;

    --- (var1 , var2, result)
    constant values_c : values_t := (
        (1, 3, 1),
        (1, 2, 3),
        (1, 1, 2),
        (2147483647, 2000000000, -147483649),
        (52, 16, 36),
        (2147483647, 2147483643, 4),
        (16, 52, -36)
    );
    --- Operator for the preceding values at same index
    constant ops_c : ops_t := (
        alu_and,
        alu_or,
        alu_add,
        alu_add,
        alu_sub,
        alu_sub,
        alu_sub
    );
    constant width_g : integer := 32;

    signal v1_in : std_logic_vector(width_g - 1 downto 0);
    signal v2_in : std_logic_vector(width_g - 1 downto 0);
    signal op_in : std_logic_vector(w_aluctrl_c - 1 downto 0);
    signal res_out : std_logic_vector(width_g - 1 downto 0);

begin

    i_alu : entity work.alu
        generic map(width_g => width_g)
        port map(
            v1_in   => v1_in,
            v2_in   => v2_in,
            op_in   => op_in,
            res_out => res_out
        );

    alutest : process
        variable res_v : integer;
    begin

        for i in 0 to values_c'length-1 loop
            --- Assign inputs
            v1_in <= std_logic_vector(to_signed(values_c(i, 0), width_g));
            v2_in <= std_logic_vector(to_signed(values_c(i, 1), width_g));
            op_in <= aluop2slv(ops_c(i));

            wait for 5 ns;

            --- Test output
            res_v := to_integer(signed(res_out));
            assert res_v = values_c(i, 2)
            report "incorrect result at index " & integer'image(i) & " (actual != expected): " &
                    integer'image(res_v) & "!=" & integer'image(values_c(i, 2))
                severity note;
        end loop;

        assert false report "test finished" severity note;
        wait;

    end process alutest;

end architecture behaviour;
