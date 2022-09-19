library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.common.all;

entity tb_decode is
end entity tb_decode;

architecture behaviour of tb_decode is
    
begin
    
    i_decode : entity work.decode 
    generic map ()
    port map ();
    
end architecture behaviour;