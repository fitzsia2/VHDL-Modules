---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity DataHold_V2 is
	port( ARST : in STD_LOGIC;
         CLK100 : in STD_LOGIC;
         CLK_IN : in STD_LOGIC;
         D0 : in STD_LOGIC_VECTOR(7 downto 0);
         D1 : in STD_LOGIC_VECTOR(7 downto 0);
         D2 : in STD_LOGIC_VECTOR(7 downto 0);
         D3 : in STD_LOGIC_VECTOR(7 downto 0);
         CLK_OUT : out STD_LOGIC;
         D_OUT : out STD_LOGIC_VECTOR(63 downto 0);
         D_BUG : out STD_LOGIC_VECTOR(3 downto 0)
         );
      
end DataHold_V2;
---------------------------------------------------------------------------------
architecture Behavioral of DataHold_V2 is
   signal ClrPend :STD_LOGIC := '0';
   signal WPend :STD_LOGIC := '0';
   signal d0_i : STD_LOGIC_VECTOR(7 downto 0) := X"00";
   signal d1_i : STD_LOGIC_VECTOR(7 downto 0) := X"00";
   signal d2_i : STD_LOGIC_VECTOR(7 downto 0) := X"00";
   signal d3_i : STD_LOGIC_VECTOR(7 downto 0) := X"00";
   signal SampleCtrl : STD_LOGIC_VECTOR(4 downto 0) := "00000";
   signal SampleD0 : STD_LOGIC;
   signal SampleD1 : STD_LOGIC;
   signal SampleD2 : STD_LOGIC;
   signal SampleD3 : STD_LOGIC;
   
   signal d_bug_i : STD_LOGIC;
   
---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   SampleD0 <= SampleCtrl(0);
   SampleD1 <= SampleCtrl(1);
   SampleD2 <= SampleCtrl(2);
   SampleD3 <= SampleCtrl(3);
   CLK_OUT <= SampleCtrl(4);
   
   D_BUG(0) <= CLK_IN;
   D_BUG(1) <= d_bug_i;
   
   D_BUG(3) <= '0';
   
--   D_BUG(3 downto 0) <= D0(3 downto 0);
   
--------------------------------------------------------------------------------
-- 
--
process(ClrPend, CLK_IN)
begin
   if(ClrPend = '1') then
      WPend <= '0';
   elsif(CLK_IN'event and CLK_IN = '1') then
      WPend <= '1';
      d0_i <= D0;
      d1_i <= D1;
      d2_i <= D2;
      d3_i <= D3;
   end if;
end process;
--------------------------------------------------------------------------------
-- 
--
process(CLK100, WPend, ARST)
CONSTANT SAMPIDLE     : STD_LOGIC_VECTOR(4 downto 0) := "00000";
CONSTANT SAMP0   : STD_LOGIC_VECTOR(4 downto 0) := "00001";
CONSTANT SAMP1   : STD_LOGIC_VECTOR(4 downto 0) := "00010";
CONSTANT SAMP2   : STD_LOGIC_VECTOR(4 downto 0) := "00100";
CONSTANT SAMP3   : STD_LOGIC_VECTOR(4 downto 0) := "01000";
CONSTANT SAMPOUT   : STD_LOGIC_VECTOR(4 downto 0) := "10000";
variable cnt : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
if(CLK100'event and CLK100 = '1') then
   if(cnt = X"0" and WPend = '1') then
      cnt := cnt + '1';
      SampleCtrl <= SAMP0;
      ClrPend <= '1';
   elsif(cnt = X"1" and WPend = '1') then
      cnt := cnt + '1';
      SampleCtrl <= SAMP1;
      ClrPend <= '1';
--   elsif(cnt = X"2" and WPend = '1') then
--      cnt := cnt + '1';
--      SampleCtrl <= SAMP2;
--      ClrPend <= '1';
--   elsif(cnt = X"3" and WPend = '1') then
--      cnt := cnt + '1';
--      SampleCtrl <= SAMP3;
--      ClrPend <= '1';
   elsif(cnt = X"2") then
      cnt := X"0";
      SampleCtrl <= SAMPOUT;
      ClrPend <= '0';
   else
      if(ARST = '1') then
         cnt := X"0";
      else
         null;
      end if;
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
      D_OUT(7 downto 0) <= d0_i(7 downto 0);
      D_OUT(15 downto 8) <= d1_i(7 downto 0);
      D_OUT(23 downto 16) <= d2_i(7 downto 0);
      D_OUT(31 downto 24) <= d3_i(7 downto 0);
--      D_OUT(7 downto 5) <= d0_i(3 downto 1);
--      D_OUT(4 downto 2) <= d1_i(7 downto 5);
--      D_OUT(1 downto 0) <= d1_i(3 downto 2);
--      D_OUT(15 downto 13) <= d2_i(3 downto 1);
--      D_OUT(12 downto 10) <= d3_i(7 downto 5);
--      D_OUT(9 downto 8) <= d3_i(3 downto 2);
   else
      null;
   end if;
end process;
------------------------------------------
process(SampleD1)
begin
   if(SampleD1'event and SampleD1 = '1') then
      D_OUT(39 downto 32) <= d0_i(7 downto 0);
      D_OUT(47 downto 40) <= d1_i(7 downto 0);
      D_OUT(55 downto 48) <= d2_i(7 downto 0);
      D_OUT(63 downto 56) <= d3_i(7 downto 0);
--      D_OUT(23 downto 21) <= d0_i(3 downto 1);
--      D_OUT(20 downto 18) <= d1_i(7 downto 5);
--      D_OUT(17 downto 16) <= d1_i(3 downto 2);
--      D_OUT(31 downto 29) <= d2_i(3 downto 1);
--      D_OUT(28 downto 26) <= d3_i(7 downto 5);
--      D_OUT(23 downto 24) <= d3_i(3 downto 2);
   else
      null;
   end if;
end process;
--------------------------------------------
--process(SampleD2)
--begin
--   if(SampleD2'event and SampleD2 = '1') then
--      D_OUT(39 downto 37) <= d1_i(3 downto 1);
--      D_OUT(36 downto 34) <= d1_i(7 downto 5);
--      D_OUT(33 downto 32) <= d1_i(3 downto 2);
--      
--      D_OUT(47 downto 45) <= d2_i(3 downto 1);
--      D_OUT(44 downto 42) <= d3_i(7 downto 5);
--      D_OUT(41 downto 40) <= d3_i(3 downto 2);
--   else
--      null;
--   end if;
--end process;
--------------------------------------------
--process(SampleD3)
--begin
--   if(SampleD3'event and SampleD3 = '1') then
--      D_OUT(55 downto 53) <= d1_i(3 downto 1);
--      D_OUT(52 downto 50) <= d1_i(7 downto 5);
--      D_OUT(49 downto 48) <= d1_i(3 downto 2);
--      
--      D_OUT(63 downto 61) <= d2_i(3 downto 1);
--      D_OUT(60 downto 58) <= d3_i(7 downto 5);
--      D_OUT(57 downto 56) <= d3_i(3 downto 2);
--   else
--      null;
--   end if;
--end process;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Behavioral;
