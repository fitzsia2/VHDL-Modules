---------------------------------------------------------------------------------
-- Data FlipFlop
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity DataFF is
port(
    CLK : in std_logic;
    SRST : in std_logic;
    SET : in std_logic;
    Q : out std_logic;
    Q_NOT : out std_logic;
);
end DataFF;

-----------------------------------------
-- Internal signal description
-----------------------------------------
architecture Behavioral of DataFF is

-----------------------------------------
begin
-----------------------------------------
-- Logic
-----------------------------------------
process( CLK, SRST )
begin
    if( CLK'event && CLK = '1' ) then
        if( SRST = '1' ) then
            Q <= '0';
            Q_NOT <= '1';
        else
            Q <= '1';
            Q_NOT <= '0';
        end if;
    else
        null;
    end if;
end process
--------------------------------------------------------------------------------
end Behavioral;

