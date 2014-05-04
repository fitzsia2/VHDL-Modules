--------------------------------------------------------------------------------
-- Video Graphic Array Driver
--
-- This module interfaces with a memory device to display video at 640x480
--
-- Source code is based upon John Roach's design which is available at:
-- http://johnroach.info/2011/01/15/getting-vga-output-using-vga-and-a-spartan-3an-board/
--
-- Modified by Andrew Fitzsimons 2013
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
entity VGADriver is port(
      CLK_100M_IN    : in STD_LOGIC;
      D_BUG     : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
      CLK_OUT   : out STD_LOGIC := '0';
      ADR_READ  : out STD_LOGIC_VECTOR(25 downto 0) := (others => '0');
      CLK_IN    : in STD_LOGIC;
      D_IN      : in STD_LOGIC_VECTOR(63 downto 0);
      RED_OUT   : out STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
      GREEN_OUT : out STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
      BLUE_OUT  : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
      HS_OUT    : out STD_LOGIC := '1';
      VS_OUT    : out STD_LOGIC := '1';
      HORIZONTALCOUNT_O : out STD_LOGIC_VECTOR(9 downto 0);
      VGA_EN    : in STD_LOGIC
   );
end VGADriver;
--------------------------------------------------------------------------------
architecture Behavioral of VGADriver is

     TYPE STATE_TYPE is (READLOW, READHIGH);
     signal SReg  : STATE_TYPE := READLOW;
     signal SNext : STATE_TYPE := READHIGH;
     
     signal Clk_25            : STD_LOGIC := '0';
     signal Clk_50            : STD_LOGIC := '0';
     signal Color             : STD_LOGIC_VECTOR(2 downto 0);
     signal HorizontalCounter : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
     signal VerticalCounter   : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
     signal AdrRead_i         : STD_LOGIC_VECTOR(25 downto 0) := (others => '0');
     
     signal GetDataEN         : STD_LOGIC;
     signal PData             : STD_LOGIC_VECTOR(127 downto 0);
     signal c : NATURAL := 120;
     signal PixelIndex : NATURAL range 0 to 16;
     
     
     signal dbug_i : STD_LOGIC;
     signal dbug_i_2 : STD_LOGIC;
        
--------------------------------------------------------------------------------
-- Signal Assignment
begin
   CLK_OUT <= GetDataEN;
   ADR_READ <= AdrRead_i;
   
   HORIZONTALCOUNT_O <= HorizontalCounter;
   
   D_BUG(0) <= Clk_25;
   D_BUG(1) <= GetDataEN;
--   D_BUG(2) <= Clk_25;
   D_BUG(3) <= dbug_i_2;
--   D_BUG <= D_IN(3 downto 0);
   
--------------------------------------------------------------------------------
-- Generate a 25Mhz / 50Mhz clock
process (CLK_100M_IN)
variable cnt : STD_LOGIC := '0';
begin 
	if (CLK_100M_IN'event and CLK_100M_IN='1') then
		Clk_50 <= not Clk_50;
		if (cnt = '0') then
			Clk_25 <= not Clk_25;
			cnt := '1';
		else
			cnt := '0';
		end if;
	end if;
end process;
--------------------------------------------------------------------------------
process (Clk_25, VGA_EN)
CONSTANT HFLYBACK   : STD_LOGIC_VECTOR(9 downto 0) := "0001100001";
CONSTANT VFPORCH    : STD_LOGIC_VECTOR(9 downto 0) := "0000000011";
CONSTANT HSYNCPULSE : STD_LOGIC_VECTOR(9 downto 0) := "1100100000";
CONSTANT VSYNCPULSE : STD_LOGIC_VECTOR(9 downto 0) := "1000001001";
CONSTANT HSTARTDISP : STD_LOGIC_VECTOR(9 downto 0) := "0010010000";
CONSTANT HENDDISP   : STD_LOGIC_VECTOR(9 downto 0) := "1100010000";
CONSTANT VSTARTDISP : STD_LOGIC_VECTOR(9 downto 0) := "0000100111";
CONSTANT VENDDISP   : STD_LOGIC_VECTOR(9 downto 0) := "1000000111";
CONSTANT REQREADSTART :STD_LOGIC_VECTOR(9 downto 0):= "0010001001";
CONSTANT REQREADEND   :STD_LOGIC_VECTOR(9 downto 0):= "1100001011";
begin
   if (Clk_25'event and Clk_25 = '1') then
   --------------------------------------------------------
   -- Get Data Before First Write
   --
   
      if(HorizontalCounter >= REQREADSTART)
         and (HorizontalCounter <= REQREADEND)
         and (HorizontalCounter(2 downto 0) = "001")
         and (VerticalCounter >= VSTARTDISP )
         and (VerticalCounter <  VENDDISP)
         and (VGA_EN = '1')
      then
         GetDataEN <= '1';
      else
         GetDataEN <= '0';
      end if;
      
   --------------------------------------------------------
   -- Check for valid display region
   --
      if (HorizontalCounter >= HSTARTDISP )
         and (HorizontalCounter < HENDDISP )
         and (VerticalCounter >= VSTARTDISP )
         and (VerticalCounter <  VENDDISP)
         and (VGA_EN = '1')
      then
         --------------------------------------------------------
         -- Increment Read Address after every other read
         --
         if(HorizontalCounter(2 downto 0) = "100") then
            AdrRead_i <= AdrRead_i + "100";
         else
            null;
         end if;
         
         --------------------------------------------------------
         -- Display Data
         --

         if(PixelIndex = 0) then
            RED_OUT <= PData(7 downto 5);
            GREEN_OUT <= PData(4 downto 2);
            BLUE_OUT <= PData(1 downto 0);
            c <= 0; PixelIndex <= 1; dbug_i <= '1';
         elsif(PixelIndex = 1) then
            RED_OUT <= PData(15 downto 13);
            GREEN_OUT <= PData(12 downto 10);
            BLUE_OUT <= PData(9 downto 8);
            c <= 8; PixelIndex <= 2; dbug_i <= '0';
         elsif(PixelIndex = 2) then
            RED_OUT <= PData(23 downto 21);
            GREEN_OUT <= PData(20 downto 18);
            BLUE_OUT <= PData(17 downto 16);
            c <= 16; PixelIndex <= 3; dbug_i <= '0';
         elsif(PixelIndex = 3) then
            RED_OUT <= PData(31 downto 29);
            GREEN_OUT <= PData(28 downto 26);
            BLUE_OUT <= PData(25 downto 24);
            c <= 24; PixelIndex <= 4; dbug_i <= '0';
         elsif(PixelIndex = 4) then
            RED_OUT <= PData(39 downto 37);
            GREEN_OUT <= PData(36 downto 34);
            BLUE_OUT <= PData(33 downto 32);
            c <= 32; PixelIndex <= 5; dbug_i <= '0';
         elsif(PixelIndex = 5) then
            RED_OUT <= PData(47 downto 45);
            GREEN_OUT <= PData(44 downto 42);
            BLUE_OUT <= PData(41 downto 40);
            c <= 40; PixelIndex <= 6; dbug_i <= '0';
         elsif(PixelIndex = 6) then
            RED_OUT <= PData(55 downto 53);
            GREEN_OUT <= PData(52 downto 50);
            BLUE_OUT <= PData(49 downto 48);
            c <= 48; PixelIndex <= 7; dbug_i <= '0';
         elsif(PixelIndex = 7) then
            RED_OUT <= PData(63 downto 61);
            GREEN_OUT <= PData(60 downto 58);
            BLUE_OUT <= PData(57 downto 56);
            c <= 56; PixelIndex <= 8; dbug_i <= '0';
         elsif(PixelIndex = 8) then
            RED_OUT <= PData(71 downto 69);
            GREEN_OUT <= PData(68 downto 66);
            BLUE_OUT <= PData(65 downto 64);
            c <= 64; PixelIndex <= 9; dbug_i <= '0';
         elsif(PixelIndex = 9) then
            RED_OUT <= PData(79 downto 77);
            GREEN_OUT <= PData(76 downto 74);
            BLUE_OUT <= PData(73 downto 72);
            c <= 72; PixelIndex <= 10; dbug_i <= '0';
         elsif(PixelIndex = 10) then
            RED_OUT <= PData(87 downto 85);
            GREEN_OUT <= PData(84 downto 82);
            BLUE_OUT <= PData(81 downto 80);
            c <= 80; PixelIndex <= 11; dbug_i <= '0';
         elsif(PixelIndex = 11) then
            RED_OUT <= PData(95 downto 93);
            GREEN_OUT <= PData(92 downto 90);
            BLUE_OUT <= PData(89 downto 88);
            c <= 88; PixelIndex <= 12; dbug_i <= '0';
         elsif(PixelIndex = 12) then
            RED_OUT <= PData(103 downto 101);
            GREEN_OUT <= PData(100 downto 98);
            BLUE_OUT <= PData(97 downto 96);
            c <= 96; PixelIndex <= 13; dbug_i <= '0';
         elsif(PixelIndex = 13) then
            RED_OUT <= PData(111 downto 109);
            GREEN_OUT <= PData(108 downto 106);
            BLUE_OUT <= PData(105 downto 104);
            c <= 104; PixelIndex <= 14; dbug_i <= '0';
         elsif(PixelIndex = 14) then
            RED_OUT <= PData(119 downto 117);
            GREEN_OUT <= PData(116 downto 114);
            BLUE_OUT <= PData(113 downto 112);
            c <= 112; PixelIndex <= 15; dbug_i <= '0';
         elsif(PixelIndex = 15) then
            RED_OUT <= PData(127 downto 125);
            GREEN_OUT <= PData(124 downto 122);
            BLUE_OUT <= PData(121 downto 120);
            c <= 120; PixelIndex <= 0; dbug_i <= '0';
         else
            null;
         end if;
         
      --------------------------------------------------------
      -- 
      --
      else
         red_out <= "000";
         green_out <= "000";
         blue_out <= "00";
      end if;

      --------------------------------------------------------
      -- 
      --
      if (HorizontalCounter > "0000000000" )
         and (HorizontalCounter < HFLYBACK ) -- 96+1
      then
         hs_out <= '0';
      else
         hs_out <= '1';
      end if;

      --------------------------------------------------------
      -- 
      --
      if (VerticalCounter > "0000000000" )
         and (VerticalCounter < VFPORCH )
      then
         vs_out <= '0';
         AdrRead_i <= (others => '0');
      else
         vs_out <= '1';
      end if;

      --------------------------------------------------------
      -- 
      --
      if (HorizontalCounter=HSYNCPULSE) then
         VerticalCounter <= VerticalCounter + "0000000001";
         HorizontalCounter <= "0000000000";
      else
         HorizontalCounter <= HorizontalCounter + "0000000001";
      end if;

      --------------------------------------------------------
      -- 
      --
      if (VerticalCounter=VSYNCPULSE) then
         VerticalCounter <= "0000000000";
      else
         null;
      end if;
   end if;
end process;


process(AdrRead_i)
begin
--                   000000000100101011111111100
--   if(AdrRead_i = "000000000100101011111111100") then
   if(AdrRead_i = 000000000000000000000000000) then
      dbug_i_2 <= '1';
   else
      dbug_i_2 <= '0';
   end if;
end process;


--------------------------------------------------------------------------------
process(CLK_IN)
variable cnt : STD_LOGIC := '0';
begin
   if(CLK_IN'event and CLK_IN = '1') then
      if(cnt = '0') then
         PData(63 downto 0) <= D_IN(63 downto 0);
         cnt := '1';
         D_BUG(2) <= '0';
      else
         PData(127 downto 64) <= D_IN(63 downto 0);
         cnt := '0';
         D_BUG(2) <= '1';
      end if;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
