--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.EthConstants.ALL;
--------------------------------------------------------------------------------
entity Counter is
  generic(
           N : integer := 8
         );
  port(
        CLK_in : in std_logic;
        RST_in : in std_logic;
        COUNT_out : buffer std_logic_vector( N-1 downto 0 ) := (others => '0');
);
end Counter;

--------------------------------------------------------------------------------
architecture Behavioral of Counter is
  signal CountOut_i : std_logic_vector( (COUNT_OUT'length)-1 downto 0 );

--------------------------------------------------------------------------------
-- Signal Assignments
--
begin
  COUNT_out <= CountOut_i;

  ------------------------------------------------------------------------------
  -- Process Counter
  process( CLK_in, RST_in )
  begin
    if( RST_in = '1' ) then
      COUNT_out <= (others => '0');
    elsif( CLK_in'event and CLK_in = '1' ) then
      CountOut_i <= CountOut_i + '1';
    else
      null;
    end if;
  end process;

--------------------------------------------------------------------------------
end Behavioral;


