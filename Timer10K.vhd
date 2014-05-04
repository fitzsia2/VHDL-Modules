--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Port Descriptions
entity Timer10K is
    Port ( EN : in STD_LOGIC;
           CLK_IN : in  STD_LOGIC;
           OUT_EN : out  STD_LOGIC := '0');
end Timer10K;

--------------------------------------------------------------------------------
-- Signal Description
architecture Behavioral of Timer10K is

--------------------------------------------------------------------------------
-- Signal Assignments
begin

--------------------------------------------------------------------------------
process(CLK_IN)
CONSTANT ENDOFCOUNT : INTEGER := 250000;
--CONSTANT ENDOFCOUNT : INTEGER := 2000;
variable cnt : INTEGER := 0;
begin
   if(EN = '1') then
      if(CLK_IN'event and CLK_IN = '1') then
         if(cnt < ENDOFCOUNT) then
            cnt := cnt + 1;
            OUT_EN <= '0';
         else
            OUT_EN <= '1';
         end if;
      else
         null;
      end if;
   else
      OUT_EN <= '0';
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;

