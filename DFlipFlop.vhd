---------------------------------------------------------------------------------
-- Data FlipFlop
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity DataFF is
   port(
          PRESET_in : in std_logic;
          CLEAR_in : in std_logic;
          CLK_in : in std_logic;
          D_in : in std_logic;
          Q_out : out std_logic := '0';
          n_Q_out : out std_logic := '1'
);
end DataFF;

-----------------------------------------
-- Internal signal description
-----------------------------------------
architecture Behavioral of DataFF is
begin

-----------------------------------------
-- Logic
-----------------------------------------
process( PRESET_in, CLEAR_in, CLK_IN )
begin
   if( CLEAR_in = '1' ) then
      Q_out <= '0';
      n_Q_out <= '1';
   elsif( PRESET_in = '1' ) then
      Q_out <= '1';
      n_Q_out <= '0';
   elsif( CLK_IN'event and CLK_IN = '1' ) then
      Q_out <= D_in;
      n_Q_out <= not D_in;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;

