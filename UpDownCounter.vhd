--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.EthConstants.ALL;
--------------------------------------------------------------------------------
entity UpDownCounter is
   generic(
             N : integer := 8
          );
   port(
          EN_in : in std_logic;
          DIRECTION_in : in std_logic; -- '0' for up, '1' for down
          CLK_in : in std_logic;
          RST_in : in std_logic; -- Asynchronous reset
          COUNT_out : out std_logic_vector( N-1 downto 0 ) := (others => '0')
       );
end UpDownCounter;

--------------------------------------------------------------------------------
architecture Behavioral of UpDownCounter is
   signal CountOut_i : std_logic_vector( (COUNT_OUT'length)-1 downto 0 ) := (others => '0');

--------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   COUNT_out <= CountOut_i;

   -----------------------------------------------------------------------------
   -- Counter Description
   --
   process( CLK_in, RST_in )
   begin
      if( RST_in = '1' ) then
         CountOut_i <= (others => '0');
      elsif( CLK_in'event and CLK_in = '1' ) then
         if( EN_in = '1' ) then
            if( DIRECTION_in = '0' ) then
               CountOut_i <= CountOut_i + '1';
            elsif( DIRECTION_in = '1' ) then
               CountOut_i <= CountOut_i - '1';
            else -- Invalid state
               null;
            end if;
         else -- Chip Disabled
            null;
         end if;
      else -- No clock event
         null;
      end if;
   end process;

--------------------------------------------------------------------------------
end Behavioral;


