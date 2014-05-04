---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity DataHold is
	port( ARST_L : in STD_LOGIC;
         CLK100 : in STD_LOGIC;
         CLK_IN : in STD_LOGIC;
         D_IN : in STD_LOGIC_VECTOR(15 downto 0);
         CLK_OUT : out STD_LOGIC;
         D_OUT : out STD_LOGIC_VECTOR(63 downto 0);
         D_BUG : out STD_LOGIC_VECTOR(3 downto 0)
         );
      
end DataHold;
---------------------------------------------------------------------------------
architecture Behavioral of DataHold is
   signal Arst       : STD_LOGIC;
   signal ClrPend : STD_LOGIC := '0';
   signal WPend : STD_LOGIC := '0';
   signal SampleCtrl : STD_LOGIC_VECTOR(4 downto 0) := "00000";
   signal SampleD0 : STD_LOGIC;
   signal SampleD1 : STD_LOGIC;
   signal SampleD2 : STD_LOGIC;
   signal SampleD3 : STD_LOGIC;
   signal d_i : STD_LOGIC_VECTOR(15 downto 0);
   
---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   Arst <= not ARST_L;
   SampleD0 <= SampleCtrl(0);
   SampleD1 <= SampleCtrl(1);
   SampleD2 <= SampleCtrl(2);
   SampleD3 <= SampleCtrl(3);
   CLK_OUT <= SampleCtrl(4);
   
   D_BUG(0) <= CLK_IN;
   D_BUG(1) <= D_IN(0);
   D_BUG(2) <= D_IN(1);
--   D_BUG <= D_IN(3 downto 0);
   
---------------------------------------------------------------------------------
-- 
--
process(ClrPend, CLK_IN)
begin
   if(ClrPend = '1') then
      WPend <= '0';
   elsif(CLK_IN'event and CLK_IN = '1') then
      WPend <= '1';
      d_i <= D_IN;
   end if;
end process;
--------------------------------------------------------------------------------
-- 
--
process(CLK100, WPend)
CONSTANT SAMPIDLE     : STD_LOGIC_VECTOR(4 downto 0) := "00000";
CONSTANT SAMPD0   : STD_LOGIC_VECTOR(4 downto 0) := "00001";
CONSTANT SAMPD1   : STD_LOGIC_VECTOR(4 downto 0) := "00010";
CONSTANT SAMPD2   : STD_LOGIC_VECTOR(4 downto 0) := "00100";
CONSTANT SAMPD3   : STD_LOGIC_VECTOR(4 downto 0) := "01000";
CONSTANT SAMPOUT   : STD_LOGIC_VECTOR(4 downto 0) := "10000";
variable cnt : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
if(CLK100'event and CLK100 = '1') then
   if(cnt = X"0" and WPend = '1') then
      cnt := cnt + '1';
      SampleCtrl <= SAMPD0;
      ClrPend <= '1';
   elsif(cnt = X"1" and WPend = '1') then
      cnt := cnt + '1';
      SampleCtrl <= SAMPD1;
      ClrPend <= '1';
   elsif(cnt = X"2" and WPend = '1') then
      cnt := cnt + '1';
      SampleCtrl <= SAMPD2;
      ClrPend <= '1';
   elsif(cnt = X"3" and WPend = '1') then
      cnt := cnt + '1';
      SampleCtrl <= SAMPD3;
      ClrPend <= '1';
   elsif(cnt = X"4") then
      cnt := X"0";
      SampleCtrl <= SAMPOUT;
      ClrPend <= '0';
   else
      SampleCtrl <= SAMPIDLE;
      ClrPend <= '0';
   end if;
else
   null;
end if;
end process;
----------------------------------------
process(SampleD0)
begin
   if(SampleD0'event and SampleD0 = '1') then
      D_OUT(15 downto 0) <= d_i;
   else
      null;
   end if;
end process;
------------------------------------------
process(SampleD1)
begin
   if(SampleD1'event and SampleD1 = '1') then
      D_OUT(31 downto 16) <= d_i;
   else
      null;
   end if;
end process;
------------------------------------------
process(SampleD2)
begin
   if(SampleD2'event and SampleD2 = '1') then
      D_OUT(47 downto 32) <= d_i;
   else
      null;
   end if;
end process;
------------------------------------------
process(SampleD3)
begin
   if(SampleD3'event and SampleD3 = '1') then
      D_OUT(63 downto 48) <= d_i;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
