library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all; --- aluop_t type and it's conversion function.

entity tb_regfile is
end entity tb_regfile;

architecture behaviour of tb_regfile is
    constant ntests_c : integer := 17;

    type values_t is array (0 to ntests_c-1, 0 to 3) of integer;
    type ops_t is array (0 to ntests_c-1) of aluop_t;

    --- (var1 , var2, result)
    constant values_c : values_t := (
        (aluop_t'pos(alu_and), 1, 3, 1),
        (aluop_t'pos(alu_or), 1, 2, 3),

        (aluop_t'pos(alu_add), 1, 1, 2),
        (aluop_t'pos(alu_add), 2147483647, 2000000000, -147483649),

        (aluop_t'pos(alu_sub), 52, 16, 36),
        (aluop_t'pos(alu_sub), 2147483647, 2147483643, 4),
        (aluop_t'pos(alu_sub), 16, 52, -36),

        (aluop_t'pos(alu_sla), 54, 5, 1728),
        (aluop_t'pos(alu_sla), -54, 5, -1728),
        (aluop_t'pos(alu_sla), -555555555, 5, -597908576),

        (aluop_t'pos(alu_sra), 54, 2, 13),
        (aluop_t'pos(alu_sra), -54, 2, -14),
        (aluop_t'pos(alu_sra), -555555555, 5, -17361112),

        (aluop_t'pos(alu_sll), 54, 5, 1728),
        (aluop_t'pos(alu_sll), -54, 5, -1728),

        (aluop_t'pos(alu_srl), -555555555, 5, 116856616),
        (aluop_t'pos(alu_srl), -54, 2, 1073741810)
    );

    --- Signals to connect ALU, default values at start to prevent passing metavalue to to_integer.
    signal v1_in : std_logic_vector(xlen_c - 1 downto 0) := (others => '0');
    signal v2_in : std_logic_vector(xlen_c - 1 downto 0) := (others => '0');
    signal op_in : std_logic_vector(aluctrlw_c - 1 downto 0) := (others => '0');
    signal res_out : std_logic_vector(xlen_c - 1 downto 0);

begin

    i_alu : entity work.alu
        generic map(width_g => xlen_c)
        port map(
            v1_in   => v1_in,
            v2_in   => v2_in,
            op_in   => op_in,
            res_out => res_out
        );

    alutest : process
        variable res_v : integer;
    begin

        for i in 0 to ntests_c-1 loop
            --- Assign inputs
            v1_in <= std_logic_vector(to_signed(values_c(i, 1), xlen_c));
            v2_in <= std_logic_vector(to_signed(values_c(i, 2), xlen_c));
            op_in <= aluop2slv(aluop_t'val(values_c(i, 0)));

            wait for 5 ns;

            --- Test output
            res_v := to_integer(signed(res_out));
            assert res_v = values_c(i, 3)
                report "incorrect result at index " & 
                        integer'image(i) & 
                        " (actual != expected): " &
                        integer'image(res_v) & 
                        "!=" & 
                        integer'image(values_c(i, 3))
                severity note;
        end loop;

        assert false report "test finished" severity note;
        wait;

    end process alutest;

end architecture behaviour;
