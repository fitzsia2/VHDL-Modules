---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity ChipSelect is
   PORT(
      SELECT_B : IN std_logic;
      A0 : IN std_logic;
      A1 : IN std_logic;
      B0 : IN std_logic;
      B1 : IN std_logic;
      Q0 : OUT std_logic;
      Q1 : OUT std_logic
      );
end ChipSelect;

--------------------------------------------------------------------------------
-- Internal Hardware Signals
--------------------------------------------------------------------------------
architecture Behavioral of ChipSelect is

--------------------------------------------------------------------------------
-- Signal Assignments
--------------------------------------------------------------------------------
begin
      Q0 <= (B0 and SELECT_B) or (A0 and not SELECT_B);
      Q1 <= (B1 and SELECT_B) or (A1 and not SELECT_B);
end Behavioral;

