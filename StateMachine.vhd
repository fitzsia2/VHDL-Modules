---------------------------------------------------------------------------------
-- Data FlipFlop
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity DataFF is
  port(
        CLK_in : in std_logic;
        DATA_in : in std_logic;
        n_SRST_in : in std_logic;
        Q_out : out std_logic;
        n_Q_out : out std_logic
      );
end DataFF;

-----------------------------------------
-- Internal signal description
-----------------------------------------
architecture Behavioral of DataFF is
  signal SRst_i : std_logic := '0';

-----------------------------------------
begin
  Srst_i <= not n_SRST_in;

  -----------------------------------------
  -- Logic
  -----------------------------------------
  process( CLK_IN, n_SRST_in )
  begin
    if( CLK_IN'event and CLK_IN = '1' ) then
      if( SRst_i = '0' ) then
        Q <= '0';
        n_Q <= '1';
      else
        Q <= DATA_in;
        n_Q <= not DATA_in;
      end if;
    else
      null;
    end if;
  end process;
--------------------------------------------------------------------------------
end Behavioral;

