--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Port Descriptions
entity Timer150000 is
  port(
        CLK_IN : in std_logic;
        ARST : in std_logic;
        OUT_EN : out std_logic := '0'
      );
end Timer150000;

--------------------------------------------------------------------------------
-- Signal Description
architecture Behavioral of Timer150000 is

--------------------------------------------------------------------------------
-- Signal Assignments
begin

--------------------------------------------------------------------------------
  process(CLK_IN, ARST)
    constant END_OF_COUNT : std_logic_vector(17 downto 0) := "100100100111110000";
    variable cnt : std_logic_vector(17 downto 0) := (others => '0');
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
      tnd if;
    else
      null;
    end if;
  end process;
--------------------------------------------------------------------------------
end Behavioral;

