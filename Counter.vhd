---------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
ENTITY Counter IS
   GENERIC(
      COUNTMAX : INTEGER
      );
   PORT(
      CLK_IN : in std_logic;
      COUNT_OUT : out INTEGER := 0;
      RST_OUT : out std_logic := '0');
end Counter;

---------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF Counter IS
   SIGNAL CountOut_i : INTEGER := 0;
   
---------------------------------------------------------------------------------
-- Signal Assignments
--
BEGIN
   COUNT_OUT <= CountOut_i;

---------------------------------------------------------------------------------
-- Process Counter
--
PROCESS( CLK_IN )
BEGIN
   IF( CLK_IN'event AND CLK_IN = '1' ) THEN
      IF( CountOut_i = COUNTMAX ) THEN
         CountOut_i <= 0;
         RST_OUT <= '1';
      ELSE
         CountOut_i <= CountOut_i + 1;
         RST_OUT <= '0';
      END IF;
   END IF;
END PROCESS;

---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
END Behavioral;


