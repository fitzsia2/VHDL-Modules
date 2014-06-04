--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Port Descriptions
entity Timer100000 is
    Port ( CLK_IN : in  STD_LOGIC;
           ARST   : in STD_LOGIC;
           OUT_EN : out  STD_LOGIC := '0');
end Timer100000;

--------------------------------------------------------------------------------
-- Signal Description
architecture Behavioral of Timer100000 is

--------------------------------------------------------------------------------
-- Signal Assignments
begin

--------------------------------------------------------------------------------
process(CLK_IN, ARST)
CONSTANT END_OF_COUNT : STD_LOGIC_VECTOR(17 downto 0) := "011000011010100000"; -- 100000
variable cnt : STD_LOGIC_VECTOR(17 downto 0) := (others => '0');
begin
   if(ARST = '1') then
      cnt := (others => '0');
      OUT_EN <= '0';
   elsif(CLK_IN'event and CLK_IN = '1') then
      if(cnt < END_OF_COUNT) then
         cnt := cnt + 1;
         OUT_EN <= '0';
      else
         OUT_EN <= '1';
      end if;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;

