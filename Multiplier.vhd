--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
entity Multiplier is
   generic(
             N : integer := 8
          );
   port(
          A_in : in std_logic_vector( N-1 downto 0 );
          B_in : in std_logic_vector( N-1 downto 0); -- Used for counting
          Y_out : out std_logic_vector( 2*N-1 downto 0 ) := (others => '0')
       );
end Multiplier;

--------------------------------------------------------------------------------
architecture Behavioral of Multiplier is

--------------------------------------------------------------------------------
-- Combinational logic description
--
begin
   Y_out <= A_in * B_in;
end;
