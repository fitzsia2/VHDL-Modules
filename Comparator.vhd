---------------------------------------------------------------------------------
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
ENTITY Comparator IS
   PORT(
      A_INT_IN : in INTEGER;
      B_INT_IN : in INTEGER;
      GREATER : OUT STD_LOGIC := '0';
      LESS : OUT STD_LOGIC := '0';
      EQUAL : OUT STD_LOGIC := '0'
      );
END Comparator;

---------------------------------------------------------------------------------

ARCHITECTURE Behavioral OF Comparator IS
BEGIN

---------------------------------------------------------------------------------
-- 
PROCESS(A_INT_IN, B_INT_IN)
begin
   IF(A_INT_IN < B_INT_IN) THEN
      GREATER <= '0';
      LESS <= '1';
      EQUAL <= '0';
   ELSIF(A_INT_IN = B_INT_IN) THEN
      GREATER <= '0';
      LESS <= '0';
      EQUAL <= '1';
   ELSIF(A_INT_IN > B_INT_IN) THEN
      GREATER <= '1';
      LESS <= '0';
      EQUAL <= '0';
   ELSE
      GREATER <= '0';
      LESS <= '0';
      EQUAL <= '0';
   END IF;
end process;
---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
END Behavioral;
