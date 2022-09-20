library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_pc is
end entity tb_pc;

architecture behaviour of tb_pc is
    constant addrw_c : integer := 32;
    constant half_period : time := 10 ns;

    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal en : std_logic := '0';
    signal amnt : std_logic_vector(addrw_c-1 downto 0) := (others => '0');
    signal pc : std_logic_vector(addrw_c-1 downto 0) := (others => '0');
    signal pc_int : natural := 0;
begin
    pc_int <= to_integer(unsigned(pc));

    i_pc : entity work.pc
        generic map (
            addrw_g => addrw_c,
            amax_g => 1023
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            en_in => en,
            amnt_in => amnt,
            pc_out => pc
        );

    clk_gen : process
    begin
        wait for half_period;
        clk <= not clk;
    end process clk_gen;

   test_pc: process
   begin
        report "begin test";
        rst_n <= '1' after 6 * half_period;
        wait until rst_n = '1' and clk = '1';

        wait until clk = '0';
        en <= '1';
        amnt <= std_logic_vector(to_unsigned(4, addrw_c));

        for i in 0 to 4 loop
            wait until clk = '1';
            wait until clk = '0';
            assert pc_int = (i+1)*4 
                report "actual:expected - " & natural'image(pc_int) & ":" & integer'image((i+1)*4)
                severity note;
        end loop;
        
        assert false report "end of test" severity note;
        wait;
   end process test_pc;
    
end architecture behaviour;