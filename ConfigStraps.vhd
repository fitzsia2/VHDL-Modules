--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Port Descriptions
entity ConfigStraps is
    Port ( CE_L : in  STD_LOGIC;
           MODE : out  STD_LOGIC_VECTOR (2 downto 0);
           PHYAD : out  STD_LOGIC_VECTOR (2 downto 0);
           INT_L : out STD_LOGIC;
           RMIISEL : out  STD_LOGIC);
end ConfigStraps;

--------------------------------------------------------------------------------
-- Signal Descriptions
architecture Behavioral of ConfigStraps is
--   signal Ce_i : STD_LOGIC;

--------------------------------------------------------------------------------
-- Signal Assignments
begin

--------------------------------------------------------------------------------
--process(CE_L)
--begin
--   if(CE_L = '1') then
--      MODE <= "ZZZ";
--      PHYAD <= "ZZZ";
--      INT_L <= '1';
--      RMIISEL <= 'Z';
--   else
--      MODE <= "010";
--      PHYAD <= "000";
--      INT_L <= '1';
--      RMIISEL <= '0';
--   end if;
--end process;
--------------------------------------------------------------------------------
process(CE_L)
begin
   if(CE_L = '1') then
      MODE <= "010";
      PHYAD <= "ZZZ";
      INT_L <= 'Z';
      RMIISEL <= 'Z';
   else
      MODE <= "ZZZ";
      PHYAD <= "ZZZ";
      INT_L <= 'Z';
      RMIISEL <= 'Z';
   end if;
end process;

--------------------------------------------------------------------------------
end Behavioral;

