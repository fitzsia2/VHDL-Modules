---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
entity Counter is
   generic(
      COUNTMAX : integer
      );
   port(
      CLK_IN : in std_logic;
      COUNT_OUT : out integer := 0;
      RST_OUT : out std_logic := '0');
end Counter;

---------------------------------------------------------------------------------
architecture Behavioral of Counter is
   signal CountOut_i : integer := 0;
   
---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   COUNT_OUT <= CountOut_i;

---------------------------------------------------------------------------------
-- Process Counter
--
process( CLK_IN )
begin
   if( CLK_IN'event and CLK_IN = '1' ) then
      if( CountOut_i = COUNTMAX ) then
         CountOut_i <= 0;
         RST_OUT <= '1';
      else
         CountOut_i <= CountOut_i + 1;
         RST_OUT <= '0';
      end if;
   end if;
end process;

---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
end Behavioral;


