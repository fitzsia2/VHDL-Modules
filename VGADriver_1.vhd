--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
 
entity VGADriver is port(
   CLK_100M_IN : in STD_LOGIC;
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
     signal PData             : STD_LOGIC_VECTOR(191 downto 0);
     signal PixelIndex : NATURAL range 0 to 23;
     
     signal dbug_i : STD_LOGIC;
        
--------------------------------------------------------------------------------
-- Signal Assignment
--------------------------------------------------------------------------------
begin
   CLK_OUT <= GetDataEN;
   ADR_READ <= AdrRead_i;
   
   D_BUG(1) <= GetDataEN;
--   D_BUG(2) <= Clk_25;
   
--------------------------------------------------------------------------------
-- Generate a 25Mhz / 50Mhz clock
--------------------------------------------------------------------------------
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
-- Display Process
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
CONSTANT REQREADSTART :STD_LOGIC_VECTOR(9 downto 0):= "0010001000";
CONSTANT REQREADEND   :STD_LOGIC_VECTOR(9 downto 0):= "1100001011";
begin
   if (Clk_25'event and Clk_25 = '1') then
   --------------------------------------------------------
   -- Get Data Before First Write
   --
      if(HorizontalCounter >= REQREADSTART)
         and (HorizontalCounter <= REQREADEND)
         and (HorizontalCounter(2 downto 0) = "000")
         and (VerticalCounter >= VSTARTDISP )
         and (VerticalCounter <  VENDDISP)
         and (VGA_EN = '1')
      then
         GetDataEN <= '1';
      else
         GetDataEN <= '0';
      end if;
      
      if(HorizontalCounter >= REQREADSTART)
         and (HorizontalCounter <= REQREADEND)
         and (HorizontalCounter(2 downto 0) = "010")
         and (VerticalCounter >= VSTARTDISP )
         and (VerticalCounter <  VENDDISP)
         and (VGA_EN = '1')
      then
         AdrRead_i <= AdrRead_i + "100";
         D_BUG(3) <= '1';
      else
         D_BUG(3) <= '0';
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
         D_BUG(0) <= '1';
      --------------------------------------------------------
      -- Display Data
      --
         if(PixelIndex = 0) then RED_OUT <= PData(7 downto 5); GREEN_OUT <= PData(4 downto 2); BLUE_OUT <= PData(1 downto 0);
            PixelIndex <= 1; dbug_i <= '1';
         elsif(PixelIndex = 1) then RED_OUT <= PData(15 downto 13); GREEN_OUT <= PData(12 downto 10); BLUE_OUT <= PData(9 downto 8);
            PixelIndex <= 2; dbug_i <= '0';
         elsif(PixelIndex = 2) then RED_OUT <= PData(23 downto 21); GREEN_OUT <= PData(20 downto 18); BLUE_OUT <= PData(17 downto 16);
            PixelIndex <= 3; dbug_i <= '0';
         elsif(PixelIndex = 3) then RED_OUT <= PData(31 downto 29); GREEN_OUT <= PData(28 downto 26); BLUE_OUT <= PData(25 downto 24);
            PixelIndex <= 4; dbug_i <= '0';
         elsif(PixelIndex = 4) then RED_OUT <= PData(39 downto 37); GREEN_OUT <= PData(36 downto 34); BLUE_OUT <= PData(33 downto 32);
            PixelIndex <= 5; dbug_i <= '0';
         elsif(PixelIndex = 5) then RED_OUT <= PData(47 downto 45); GREEN_OUT <= PData(44 downto 42); BLUE_OUT <= PData(41 downto 40);
            PixelIndex <= 6; dbug_i <= '0';
         elsif(PixelIndex = 6) then RED_OUT <= PData(55 downto 53); GREEN_OUT <= PData(52 downto 50); BLUE_OUT <= PData(49 downto 48);
            PixelIndex <= 7; dbug_i <= '0';
         elsif(PixelIndex = 7) then RED_OUT <= PData(63 downto 61); GREEN_OUT <= PData(60 downto 58); BLUE_OUT <= PData(57 downto 56);
            PixelIndex <= 8; dbug_i <= '0';
         elsif(PixelIndex = 8) then RED_OUT <= PData(71 downto 69); GREEN_OUT <= PData(68 downto 66); BLUE_OUT <= PData(65 downto 64);
            PixelIndex <= 9; dbug_i <= '0';
         elsif(PixelIndex = 9) then RED_OUT <= PData(79 downto 77); GREEN_OUT <= PData(76 downto 74); BLUE_OUT <= PData(73 downto 72);
            PixelIndex <= 10; dbug_i <= '0';
         elsif(PixelIndex = 10) then RED_OUT <= PData(87 downto 85); GREEN_OUT <= PData(84 downto 82); BLUE_OUT <= PData(81 downto 80);
            PixelIndex <= 11; dbug_i <= '0';
         elsif(PixelIndex = 11) then RED_OUT <= PData(95 downto 93); GREEN_OUT <= PData(92 downto 90); BLUE_OUT <= PData(89 downto 88);
            PixelIndex <= 12; dbug_i <= '0';
         elsif(PixelIndex = 12) then RED_OUT <= PData(103 downto 101); GREEN_OUT <= PData(100 downto 98); BLUE_OUT <= PData(97 downto 96);
            PixelIndex <= 13; dbug_i <= '0';
         elsif(PixelIndex = 13) then RED_OUT <= PData(111 downto 109); GREEN_OUT <= PData(108 downto 106); BLUE_OUT <= PData(105 downto 104);
            PixelIndex <= 14; dbug_i <= '0';
         elsif(PixelIndex = 14) then RED_OUT <= PData(119 downto 117); GREEN_OUT <= PData(116 downto 114); BLUE_OUT <= PData(113 downto 112);
            PixelIndex <= 15; dbug_i <= '0';
         elsif(PixelIndex = 15) then RED_OUT <= PData(127 downto 125); GREEN_OUT <= PData(124 downto 122); BLUE_OUT <= PData(121 downto 120);
            PixelIndex <= 16; dbug_i <= '0';
         elsif(PixelIndex = 16) then RED_OUT <= PData(135 downto 133); GREEN_OUT <= PData(132 downto 130); BLUE_OUT <= PData(129 downto 128);
            PixelIndex <= 17; dbug_i <= '0';
         elsif(PixelIndex = 17) then RED_OUT <= PData(143 downto 141); GREEN_OUT <= PData(140 downto 138); BLUE_OUT <= PData(137 downto 136);
            PixelIndex <= 18; dbug_i <= '0';
         elsif(PixelIndex = 18) then RED_OUT <= PData(151 downto 149); GREEN_OUT <= PData(148 downto 146); BLUE_OUT <= PData(145 downto 144);
            PixelIndex <= 19; dbug_i <= '0';
         elsif(PixelIndex = 19) then RED_OUT <= PData(159 downto 157); GREEN_OUT <= PData(156 downto 154); BLUE_OUT <= PData(153 downto 152);
            PixelIndex <= 20; dbug_i <= '0';
         elsif(PixelIndex = 20) then RED_OUT <= PData(167 downto 165); GREEN_OUT <= PData(164 downto 162); BLUE_OUT <= PData(161 downto 160);
            PixelIndex <= 21; dbug_i <= '0';
         elsif(PixelIndex = 21) then RED_OUT <= PData(175 downto 173); GREEN_OUT <= PData(172 downto 170); BLUE_OUT <= PData(169 downto 168);
            PixelIndex <= 22; dbug_i <= '0';
         elsif(PixelIndex = 22) then RED_OUT <= PData(183 downto 181); GREEN_OUT <= PData(180 downto 178); BLUE_OUT <= PData(177 downto 176);
            PixelIndex <= 23; dbug_i <= '0';
         elsif(PixelIndex = 23) then RED_OUT <= PData(191 downto 189); GREEN_OUT <= PData(188 downto 186); BLUE_OUT <= PData(185 downto 184);
            PixelIndex <= 0; dbug_i <= '0';
         else
            null;
         end if;
         
   --------------------------------------------------------
   -- Display black when not in active display domain
   --------------------------------------------------------
      else
         red_out <= "000";
         green_out <= "000";
         blue_out <= "00";
         D_BUG(0) <= '0';
      end if;

   --------------------------------------------------------
   -- Set HSYNC low for flyback
   --------------------------------------------------------
      if (HorizontalCounter > "0000000000" )
         and (HorizontalCounter < HFLYBACK ) -- 96+1
      then
         hs_out <= '0';
      else
         hs_out <= '1';
      end if;

   --------------------------------------------------------
   -- Set VSYNC low for front porch
   --------------------------------------------------------
      if (VerticalCounter > "0000000000" )
         and (VerticalCounter < VFPORCH )
      then
         vs_out <= '0';
         AdrRead_i <= (others => '0');
      else
         vs_out <= '1';
      end if;

   --------------------------------------------------------
   -- Reset HorizontalCounter after line
   --------------------------------------------------------
      if (HorizontalCounter=HSYNCPULSE) then
         VerticalCounter <= VerticalCounter + "0000000001";
         HorizontalCounter <= "0000000000";
      else
         HorizontalCounter <= HorizontalCounter + "0000000001";
      end if;

   --------------------------------------------------------
   -- Reset VerticalCounter after frame
   --------------------------------------------------------
      if (VerticalCounter = VSYNCPULSE) then
         VerticalCounter <= "0000000000";
      else
         null;
      end if;
   end if;
end process;
--------------------------------------------------------------------------------
process(CLK_IN)
variable cnt : STD_LOGIC_VECTOR(1 downto 0) := "00";
begin
   if(CLK_IN'event and CLK_IN = '1') then
      if(cnt = "00") then
         PData(63 downto 0) <= D_IN(63 downto 0);
         cnt := "01";
         D_BUG(2) <= '0';
      elsif(cnt = "01") then
         PData(127 downto 64) <= D_IN(63 downto 0);
         cnt := "11";
         D_BUG(2) <= '1';
      elsif(cnt = "11") then
         PData(191 downto 128) <= D_IN(63 downto 0);
         cnt := "00";
         D_BUG(2) <= '1';
      end if;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;