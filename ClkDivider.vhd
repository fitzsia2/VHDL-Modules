----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
----------------------------------------------------------------------------------
entity ClkDivider is
    Port ( CLK_IN   : in  STD_LOGIC;
           CLK_OUT  : out STD_LOGIC);
end ClkDivider;
----------------------------------------------------------------------------------
-- Signal Declarations
architecture Behavioral of ClkDivider is
   signal clk_i_1 : STD_LOGIC;
   signal clk_i_2 : STD_LOGIC;
   
----------------------------------------------------------------------------------
-- Signal Assignments
begin
   CLK_OUT <= clk_i_2;

----------------------------------------------------------------------------------
-- Process Description
process(CLK_IN)
begin
   if(CLK_IN'event and CLK_IN = '1') then
      clk_i_1 <= not clk_i_1;
      if(clk_i_1'event and clk_i_1 = '1') then
         clk_i_2 <= not clk_i_2;
      else
         null;
      end if;
   else
      null;
   end if;
end process;
end Behavioral;

