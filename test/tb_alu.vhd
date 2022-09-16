library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_alu is
end entity tb_alu;

architecture behaviour of tb_alu is
    type values_t is array (0 to 2, 0 to 2) of integer;
    constant values_c : values_t := ((1, 3, 1), (1, 2, 3), (1, 1, 2));
    constant width_g : integer := 32;

    signal v1_in : std_logic_vector(width_g - 1 downto 0);
    signal v2_in : std_logic_vector(width_g - 1 downto 0);
    signal op_in : std_logic_vector(3 downto 0);
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

        for i in 0 to 2 loop
            --- Assign inputs
            v1_in <= std_logic_vector(to_signed(values_c(i, 0), width_g));
            v2_in <= std_logic_vector(to_signed(values_c(i, 1), width_g));
            op_in <= std_logic_vector(to_unsigned(i, 4));

            wait for 5 ns;

            --- Test output
            res_v := to_integer(signed(res_out));
            assert res_v = values_c(i, 2) 
                report "incorrect result (actual != expected): " & integer'image(res_v) & "!=" & integer'image(values_c(i,2))
                severity note;
        end loop;

        assert false report "test finished" severity note;
        wait;

    end process alutest;

end architecture behaviour;
