----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
----------------------------------------------------------------------------------
entity Clk100ToClk20 is
    Port ( CLK100 : in  STD_LOGIC;
           CLK20  : out STD_LOGIC);
end Clk100ToClk20;
----------------------------------------------------------------------------------
-- Signal Declarations
architecture Behavioral of Clk100ToClk20 is
   
----------------------------------------------------------------------------------
-- Signal Assignments
begin
----------------------------------------------------------------------------------
-- Process Description
process(CLK100)
variable cnt : INTEGER := 0;
begin
   if(CLK100'event and CLK100 = '1') then
      if(cnt < 4) then
         cnt := cnt + 1;
      else
         cnt := 0;
      end if;
      
      if(cnt < 3) then
         CLK20 <= '1';
      else
         CLK20 <= '0';
      end if;
   else
      null;
   end if;
end process;
end Behavioral;

