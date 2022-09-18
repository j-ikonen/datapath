library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all; --- aluop_t type and it's conversion function.

entity tb_alu is
end entity tb_alu;

architecture behaviour of tb_alu is
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';

    --- Signals to connect the regfile, default values at start to prevent passing metavalue to to_integer.
    signal rs1 : std_logic_vector(raw_c-1 downto 0) := (others => '0');
    signal rs2 : std_logic_vector(raw_c-1 downto 0) := (others => '0');
    signal wa : std_logic_vector(raw_c-1 downto 0) := (others => '0');
    signal wd : std_logic_vector(xlen_c-1 downto 0) := (others => '0');
    signal wen : std_logic := '0';
    signal rd1 : std_logic_vector(xlen_c-1 downto 0) := (others => '0');
    signal rd2 : std_logic_vector(xlen_c-1 downto 0) := (others => '0');

begin

    clk_gen : process
    begin
        wait for half_period;
        clk <= not clk;
    end process clk_gen;

    i_regfile : entity work.regfile
        generic map(
            raw_g  => raw_c,
            xlen_g => xlen_c
        )
        port map(
            clk   => clk,
            rst_n => rst_n,

            rs1_in => rs1,
            rs2_in => rs2,
            wa_in  => wa,
            wd_in  => wd,
            wen_in => wen,

            rd1_out => rd1,
            rd2_out => rd2
        );

    regfiletest : process
        variable res1_v : integer;
        variable res2_v : integer;
        variable expected_v : integer;
    begin

        rst_n <= '1' after 6 * half_period;
        wait until rst_n = '1' and clk = '1';
        report "error report in format: result1:result2:expected: @x(address)";
        --- Write to all registers
        for i in 0 to xlen_c - 1 loop
            if i = 0 then
                expected_v := 0;    --- Hardcoded zero at register x0
            else
                expected_v := xlen_c-i;
            end if;
            
            --- Write data
            wd <= std_logic_vector(to_signed(expected_v, xlen_c));
            wa <= std_logic_vector(to_unsigned(i, raw_c));
            wen <= '1';
            wait until clk = '0';
            wen <= '0';
            
            --- Read the written data
            rs1 <= std_logic_vector(to_unsigned(i, raw_c));
            rs2 <= std_logic_vector(to_unsigned(i, raw_c));
            wait until clk = '1';
            res1_v := to_integer(signed(rd1));
            res2_v := to_integer(signed(rd2));

            assert (res1_v = expected_v) and (res2_v = expected_v)
                report integer'image(res1_v) & ":" &
                    integer'image(res2_v) & ":" &
                    integer'image(expected_v) & " @x" &
                    integer'image(i)
                severity error;
        end loop;
        
        --- Test for retained data.
        rs1 <= std_logic_vector(to_unsigned(20, raw_c));
        rs2 <= std_logic_vector(to_unsigned(4, raw_c));
        wait for 5 ns;
        res1_v := to_integer(signed(rd1));
        res2_v := to_integer(signed(rd2));
        
        assert res1_v = 12 and res2_v = 28 
            report  "result1:result2:expected1:expected2 @x(address1):x(address2) :\n" &
                    integer'image(res1_v) & ":" &
                    integer'image(res2_v) & ":" &
                    integer'image(12) & ":" &
                    integer'image(28) & " @x" &
                    integer'image(20) & ":x" &
                    integer'image(4)
            severity note;
        
        assert false report "test finished" severity note;
        wait;

    end process regfiletest;

end architecture behaviour;
