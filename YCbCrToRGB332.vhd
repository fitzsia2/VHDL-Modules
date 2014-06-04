---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity YCbCrToRGB332 is port(
      CLK100		: in  STD_LOGIC;
      D_BUG       : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
      Y0          : in STD_LOGIC_VECTOR(7 downto 0);
      Y1          : in STD_LOGIC_VECTOR(7 downto 0);
      CB          : in STD_LOGIC_VECTOR(7 downto 0);
      CR          : in STD_LOGIC_VECTOR(7 downto 0);
      CLK_IN      : in STD_LOGIC;
      DATA        : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
      CLK_OUT     : out STD_LOGIC := '0'
      );
      
end YCbCrToRGB332;
---------------------------------------------------------------------------------
architecture Behavioral of YCbCrToRGB332 is
   signal Y0_i       : STD_LOGIC_VECTOR(7 downto 0);
   signal Y1_i       : STD_LOGIC_VECTOR(7 downto 0);
   signal Cb_i       : STD_LOGIC_VECTOR(7 downto 0);
   signal Cr_i       : STD_LOGIC_VECTOR(7 downto 0);
   signal data_i     : STD_LOGIC_VECTOR(15 downto 0);
   signal ClkOut_i   : STD_LOGIC := '0';
   signal ProcessRst : STD_LOGIC := '0';
   signal ConvPend   : STD_LOGIC := '0';
   signal d_bug_i   : STD_LOGIC := '0';
---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   CLK_OUT <= ClkOut_i;
   
   D_BUG(0) <= CLK_IN;
	D_BUG(1) <= ConvPend;  --Begin Conversion
   D_BUG(2) <= ProcessRst;   --Received Data Acknowledgement
   D_BUG(3) <= d_bug_i;   --Received Data Acknowledgement
   
--------------------------------------------------------------------------------
-- Capture Rising Edige of CLK_IN Process
--
process(CLK_IN, ProcessRst)
begin
   if(ProcessRst = '1') then
      ConvPend <= '0';
   elsif(CLK_IN'event and CLK_IN = '1') then
      ConvPend <= '1';
      Y0_i <= Y0;
      Y1_i <= Y1;
      Cb_i <= CB;
      Cr_i <= CR;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
-- Conversion Process
--
process(CLK100, CLK_IN)
CONSTANT RED_CONST     : STD_LOGIC_VECTOR(7 downto 0) := "01011111"; -- 0.371
CONSTANT GREEN_CONST_1 : STD_LOGIC_VECTOR(7 downto 0) := "10110011"; -- 0.698
CONSTANT GREEN_CONST_2 : STD_LOGIC_VECTOR(7 downto 0) := "01010110"; -- 0.336
CONSTANT BLUE_CONST    : STD_LOGIC_VECTOR(7 downto 0) := "10111100"; -- 0.732
variable temp_r1 : STD_LOGIC_VECTOR(7 downto 0)  := "00000000";
variable temp_r2 : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
variable temp_g1 : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
variable temp_g2 : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
variable temp_b1 : STD_LOGIC_VECTOR(7 downto 0)  := "00000000";
variable temp_b2 : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
variable red0    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
variable green0  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
variable blue0   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
variable red1    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
variable green1  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
variable blue1   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
variable cnt     : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin
   -----------------------------------------------
   -- Sample Data
   if(CLK100'event and CLK100 = '1') then
      if(cnt = "000") then
         if(ConvPend = '1') then
            ProcessRst <= '0';
            ClkOut_i <= '0';
            cnt := "001";
            d_bug_i <= not d_bug_i;
         else
            null;
         end if;
      -----------------------------------------------
      -- Step 1
      elsif(cnt = "001") then
         ProcessRst <= '1';
         ClkOut_i <= '0';
         cnt := "010";
         if(Cr_i < "10000000") then temp_r1(7 downto 0) := Cr_i - "10000000"; else temp_r1(7 downto 0) := (others => '0'); end if;
         if(Cb_i < "10000000") then temp_b1(7 downto 0) := Cb_i - "10000000"; else temp_b1(7 downto 0) := (others => '0'); end if;
      -----------------------------------------------
      -- Step 2
      elsif(cnt = "010") then
         ProcessRst <= '0';
         ClkOut_i <= '0';
         cnt := "011";
         temp_r2 := (temp_r1 * RED_CONST);
         temp_g1 := (temp_r1 * GREEN_CONST_1);
         temp_g2 := (temp_b1 * GREEN_CONST_2);
         temp_b2 := (temp_b1 * BLUE_CONST);
      -----------------------------------------------
      -- Step 3
      elsif(cnt = "011") then
         ProcessRst <= '0';
         ClkOut_i <= '0';
         cnt := "100";
         red0   := Y0_i + temp_r2(15 downto 8) + temp_r1(7 downto 0); -- RED
         green0 := Y0_i - temp_g1(15 downto 8) - temp_g2(15 downto 8); -- GREEN
         blue0  := Y0_i + temp_b2(15 downto 8) + temp_b1(7 downto 0); -- BLUE
         red1   := Y1_i + temp_r2(15 downto 8) + temp_r1(7 downto 0);
         green1 := Y1_i - temp_g1(15 downto 8) - temp_g2(15 downto 8);
         blue1  := Y1_i + temp_b2(15 downto 8) + temp_b1(7 downto 0);
      -----------------------------------------------
      -- Truncate Lower Bits to Compress into RGB332
      elsif(cnt = "100") then
         ProcessRst <= '0';
         ClkOut_i <= '0';
         cnt := "101";
         data_i(7 downto 5) <= red0(7 downto 5);
         data_i(4 downto 2) <= green0(7 downto 5);
         data_i(1 downto 0) <= blue0(7 downto 6);
         data_i(15 downto 13) <= red1(7 downto 5);
         data_i(12 downto 10) <= green1(7 downto 5);
         data_i(9 downto 8) <= blue1(7 downto 6);
      -----------------------------------------------
      -- Set Data Out
      elsif(cnt = "101") then
         ProcessRst <= '0';
         ClkOut_i <= '0';
         cnt := "110";
         DATA(15 downto 0) <= data_i(15 downto 0);
--         DATA(15 downto 8) <= "00011100";
--         DATA(7 downto 0) <= "00011100";
         
      -----------------------------------------------
      -- Set CLK_OUT
      elsif(cnt = "110") then
         ProcessRst <= '0';
         ClkOut_i <= '1';
         cnt := "000";
      -----------------------------------------------
      -- HANDLE ERRORS
      else
         null;
      end if; -- END CNT IF
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
