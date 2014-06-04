---------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
-- Port Declarations
---------------------------------------------------------------------------------
entity CamInit is
   port( 
      CLK_IN : in STD_LOGIC;
      CE : in STD_LOGIC;
      SIOC : out STD_LOGIC;
      SIOD : out STD_LOGIC;
      CE_OUT : out STD_LOGIC := '0';
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0)
      );
end CamInit;
---------------------------------------------------------------------------------
-- Internal Signal Declarations
---------------------------------------------------------------------------------
architecture Behavioral of CamInit is
   signal Clk_200K : STD_LOGIC := '0';

---------------------------------------------------------------------------------
-- Signal Assignments
---------------------------------------------------------------------------------
begin
   D_BUG(0) <= Clk_200K;
   D_BUG(1) <= '0';
   D_BUG(2) <= '0';
   D_BUG(3) <= '0';
   

---------------------------------------------------------------------------------
-- Process Descriptions
---------------------------------------------------------------------------------
process(CLK_IN)
CONSTANT END_OF_COUNT : STD_LOGIC_VECTOR(7 downto 0) := X"7D";
variable cnt : STD_LOGIC_VECTOR(7 downto 0) := X"00";
begin
   if(CLK_IN'event and CLK_IN = '1') then
      if(cnt = END_OF_COUNT) then
         Clk_200K <= not Clk_200K;
         cnt := X"00";
      else
         cnt := cnt + X"01";
      end if;
   else
      null;
   end if;
end process;
---------------------------------------------------------------------------------
-- Process Descriptions
---------------------------------------------------------------------------------
process(Clk_200K)
CONSTANT OV7670_ADDR : STD_LOGIC_VECTOR(6 downto 0) := "1000011";
CONSTANT OV7670_WRITE : STD_LOGIC := '0';
CONSTANT OV7670_DONTCARE : STD_LOGIC := '1';
CONSTANT OV7670_REGADDRCOM7 : STD_LOGIC_VECTOR(7 downto 0) := X"12";
CONSTANT OV7670_COM7DATA : STD_LOGIC_VECTOR(7 downto 0) := "00000100"; -- Enable Raw RGB Output
CONSTANT OV7670_REGADDRCOM15 : STD_LOGIC_VECTOR(7 downto 0) := X"40";
CONSTANT OV7670_COM15DATA : STD_LOGIC_VECTOR(7 downto 0) := "00010000";
CONSTANT OV7670_REGADDRRGB444 : STD_LOGIC_VECTOR(7 downto 0) := X"8C";
CONSTANT OV7670_RGB444DATA : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
variable cnt : STD_LOGIC_VECTOR(11 downto 0) := X"000";
begin
   if(Clk_200K'event and Clk_200K = '1') then
      if( cnt = X"00" ) then SIOD <= '0'; cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write Sequence 1 - Device ID to SCCD
      --
      elsif( cnt = X"001" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"002" ) then SIOD <= OV7670_ADDR(6); cnt := cnt + X"01";
      elsif( cnt = X"003" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"004" ) then cnt := cnt + X"01";
      elsif( cnt = X"005" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"006" ) then SIOD <= OV7670_ADDR(5); cnt := cnt + X"01";
      elsif( cnt = X"007" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"008" ) then  cnt := cnt + X"01";
      elsif( cnt = X"009" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"00A" ) then SIOD <= OV7670_ADDR(4); cnt := cnt + X"01";
      elsif( cnt = X"00B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"00C" ) then  cnt := cnt + X"01";
      elsif( cnt = X"00D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"00E" ) then SIOD <= OV7670_ADDR(3); cnt := cnt + X"01";
      elsif( cnt = X"00F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"010" ) then cnt := cnt + X"01";
      elsif( cnt = X"011" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"012" ) then SIOD <= OV7670_ADDR(2); cnt := cnt + X"01";
      elsif( cnt = X"013" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"014" ) then cnt := cnt + X"01";
      elsif( cnt = X"015" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"016" ) then SIOD <= OV7670_ADDR(1); cnt := cnt + X"01";
      elsif( cnt = X"017" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"018" ) then cnt := cnt + X"01";
      elsif( cnt = X"019" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"01A" ) then SIOD <= OV7670_ADDR(0); cnt := cnt + X"01";
      elsif( cnt = X"01B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"01C" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Indicate Write Sequence
      --
      elsif( cnt = X"01D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"01E" ) then SIOD <= OV7670_WRITE; cnt := cnt + X"01";
      elsif( cnt = X"01F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"020" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"021" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"022" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"023" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"024" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write Register Address to SIOD
      --
      elsif( cnt = X"025" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"026" ) then SIOD <= OV7670_REGADDRCOM7(7); cnt := cnt + X"01";
      elsif( cnt = X"027" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"028" ) then cnt := cnt + X"01";
      elsif( cnt = X"029" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"02A" ) then SIOD <= OV7670_REGADDRCOM7(6); cnt := cnt + X"01";
      elsif( cnt = X"02B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"02C" ) then cnt := cnt + X"01";
      elsif( cnt = X"02D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"02E" ) then SIOD <= OV7670_REGADDRCOM7(5); cnt := cnt + X"01";
      elsif( cnt = X"02F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"030" ) then cnt := cnt + X"01";
      elsif( cnt = X"031" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"032" ) then SIOD <= OV7670_REGADDRCOM7(4); cnt := cnt + X"01";
      elsif( cnt = X"033" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"034" ) then cnt := cnt + X"01";
      elsif( cnt = X"035" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"036" ) then SIOD <= OV7670_REGADDRCOM7(3); cnt := cnt + X"01";
      elsif( cnt = X"037" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"038" ) then cnt := cnt + X"01";
      elsif( cnt = X"039" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"03A" ) then SIOD <= OV7670_REGADDRCOM7(2); cnt := cnt + X"01";
      elsif( cnt = X"03B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"03C" ) then cnt := cnt + X"01";
      elsif( cnt = X"03D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"03E" ) then SIOD <= OV7670_REGADDRCOM7(1); cnt := cnt + X"01";
      elsif( cnt = X"03F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"040" ) then cnt := cnt + X"01";
      elsif( cnt = X"041" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"042" ) then SIOD <= OV7670_REGADDRCOM7(0); cnt := cnt + X"01";
      elsif( cnt = X"043" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"044" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"045" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"046" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"047" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"048" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write Data to SIOD
      --
      elsif( cnt = X"049" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"04A" ) then SIOD <= OV7670_COM7DATA(7); cnt := cnt + X"01";
      elsif( cnt = X"04B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"04C" ) then cnt := cnt + X"01";
      elsif( cnt = X"04D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"04E" ) then SIOD <= OV7670_COM7DATA(6); cnt := cnt + X"01";
      elsif( cnt = X"04F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"050" ) then cnt := cnt + X"01";
      elsif( cnt = X"051" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"052" ) then SIOD <= OV7670_COM7DATA(5); cnt := cnt + X"01";
      elsif( cnt = X"053" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"054" ) then cnt := cnt + X"01";
      elsif( cnt = X"055" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"056" ) then SIOD <= OV7670_COM7DATA(4); cnt := cnt + X"01";
      elsif( cnt = X"057" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"058" ) then cnt := cnt + X"01";
      elsif( cnt = X"059" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"05A" ) then SIOD <= OV7670_COM7DATA(3); cnt := cnt + X"01";
      elsif( cnt = X"05B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"05C" ) then cnt := cnt + X"01";
      elsif( cnt = X"05D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"05E" ) then SIOD <= OV7670_COM7DATA(2); cnt := cnt + X"01";
      elsif( cnt = X"05F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"060" ) then cnt := cnt + X"01";
      elsif( cnt = X"061" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"062" ) then SIOD <= OV7670_COM7DATA(1); cnt := cnt + X"01";
      elsif( cnt = X"063" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"064" ) then cnt := cnt + X"01";
      elsif( cnt = X"065" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"066" ) then SIOD <= OV7670_COM7DATA(0); cnt := cnt + X"01";
      elsif( cnt = X"067" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"068" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"069" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"06A" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"06B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"06C" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write Sequence 2 - Device ID to SCCD
      --
      elsif( cnt = X"06D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"06E" ) then SIOD <= OV7670_ADDR(6); cnt := cnt + X"01";
      elsif( cnt = X"06F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"070" ) then cnt := cnt + X"01";
      elsif( cnt = X"071" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"072" ) then SIOD <= OV7670_ADDR(5); cnt := cnt + X"01";
      elsif( cnt = X"073" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"074" ) then cnt := cnt + X"01";
      elsif( cnt = X"075" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"076" ) then SIOD <= OV7670_ADDR(4); cnt := cnt + X"01";
      elsif( cnt = X"077" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"078" ) then cnt := cnt + X"01";
      elsif( cnt = X"079" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"07A" ) then SIOD <= OV7670_ADDR(3); cnt := cnt + X"01";
      elsif( cnt = X"07B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"07C" ) then cnt := cnt + X"01";
      elsif( cnt = X"07D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"07E" ) then SIOD <= OV7670_ADDR(2); cnt := cnt + X"01";
      elsif( cnt = X"07F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"080" ) then cnt := cnt + X"01";
      elsif( cnt = X"081" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"082" ) then SIOD <= OV7670_ADDR(1); cnt := cnt + X"01";
      elsif( cnt = X"083" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"084" ) then cnt := cnt + X"01";
      elsif( cnt = X"085" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"086" ) then SIOD <= OV7670_ADDR(0); cnt := cnt + X"01";
      elsif( cnt = X"087" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"088" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Indicate Write Sequence
      --
      elsif( cnt = X"089" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"08A" ) then SIOD <= OV7670_WRITE; cnt := cnt + X"01";
      elsif( cnt = X"08B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"08C" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"08D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"08E" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"08F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"090" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write RGB Register Address to SIOD
      --
      elsif( cnt = X"091" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"092" ) then SIOD <= OV7670_REGADDRRGB444(7); cnt := cnt + X"01";
      elsif( cnt = X"093" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"094" ) then cnt := cnt + X"01";
      elsif( cnt = X"095" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"096" ) then SIOD <= OV7670_REGADDRRGB444(6); cnt := cnt + X"01";
      elsif( cnt = X"097" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"098" ) then cnt := cnt + X"01";
      elsif( cnt = X"099" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"09A" ) then SIOD <= OV7670_REGADDRRGB444(5); cnt := cnt + X"01";
      elsif( cnt = X"09B" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"09C" ) then cnt := cnt + X"01";
      elsif( cnt = X"09D" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"09E" ) then SIOD <= OV7670_REGADDRRGB444(4); cnt := cnt + X"01";
      elsif( cnt = X"09F" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0A0" ) then cnt := cnt + X"01";
      elsif( cnt = X"0A1" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0A2" ) then SIOD <= OV7670_REGADDRRGB444(3); cnt := cnt + X"01";
      elsif( cnt = X"0A3" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0A4" ) then cnt := cnt + X"01";
      elsif( cnt = X"0A5" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0A6" ) then SIOD <= OV7670_REGADDRRGB444(2); cnt := cnt + X"01";
      elsif( cnt = X"0A7" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0A8" ) then cnt := cnt + X"01";
      elsif( cnt = X"0A9" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0AA" ) then SIOD <= OV7670_REGADDRRGB444(1); cnt := cnt + X"01";
      elsif( cnt = X"0AB" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0AC" ) then cnt := cnt + X"01";
      elsif( cnt = X"0AD" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0AE" ) then SIOD <= OV7670_REGADDRRGB444(0); cnt := cnt + X"01";
      elsif( cnt = X"0AF" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0B0" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"0B1" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0B2" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"0B3" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0B4" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write COM15 Data to COM15 Register
      --
      elsif( cnt = X"0B5" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0B6" ) then SIOD <= OV7670_COM15DATA(7); cnt := cnt + X"01";
      elsif( cnt = X"0B7" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0B8" ) then cnt := cnt + X"01";
      elsif( cnt = X"0B9" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0BA" ) then SIOD <= OV7670_COM15DATA(6); cnt := cnt + X"01";
      elsif( cnt = X"0BB" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0BC" ) then cnt := cnt + X"01";
      elsif( cnt = X"0BD" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0BE" ) then SIOD <= OV7670_COM15DATA(5); cnt := cnt + X"01";
      elsif( cnt = X"0BF" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0C0" ) then cnt := cnt + X"01";
      elsif( cnt = X"0C1" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0C2" ) then SIOD <= OV7670_COM15DATA(4); cnt := cnt + X"01";
      elsif( cnt = X"0C3" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0C4" ) then cnt := cnt + X"01";
      elsif( cnt = X"0C5" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0C6" ) then SIOD <= OV7670_COM15DATA(3); cnt := cnt + X"01";
      elsif( cnt = X"0C7" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0C8" ) then cnt := cnt + X"01";
      elsif( cnt = X"0C9" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0CA" ) then SIOD <= OV7670_COM15DATA(2); cnt := cnt + X"01";
      elsif( cnt = X"0CB" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0CD" ) then cnt := cnt + X"01";
      elsif( cnt = X"0CE" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0CF" ) then SIOD <= OV7670_COM15DATA(1); cnt := cnt + X"01";
      elsif( cnt = X"0D0" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0D1" ) then cnt := cnt + X"01";
      elsif( cnt = X"0D2" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0D3" ) then SIOD <= OV7670_COM15DATA(0); cnt := cnt + X"01";
      elsif( cnt = X"0D4" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0D5" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"0D6" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0D7" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"0D8" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0D9" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write Sequence 3 - Device ID to SCCD
      --
      elsif( cnt = X"0DA" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0DB" ) then SIOD <= OV7670_ADDR(6); cnt := cnt + X"01";
      elsif( cnt = X"0DC" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0DD" ) then cnt := cnt + X"01";
      elsif( cnt = X"0DE" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0DF" ) then SIOD <= OV7670_ADDR(5); cnt := cnt + X"01";
      elsif( cnt = X"0E0" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0E1" ) then cnt := cnt + X"01";
      elsif( cnt = X"0E2" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0E3" ) then SIOD <= OV7670_ADDR(4); cnt := cnt + X"01";
      elsif( cnt = X"0E4" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0E5" ) then cnt := cnt + X"01";
      elsif( cnt = X"0E6" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0E7" ) then SIOD <= OV7670_ADDR(3); cnt := cnt + X"01";
      elsif( cnt = X"0E8" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0E9" ) then cnt := cnt + X"01";
      elsif( cnt = X"0EA" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0EB" ) then SIOD <= OV7670_ADDR(2); cnt := cnt + X"01";
      elsif( cnt = X"0EC" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0ED" ) then cnt := cnt + X"01";
      elsif( cnt = X"0EE" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0EF" ) then SIOD <= OV7670_ADDR(1); cnt := cnt + X"01";
      elsif( cnt = X"0F0" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0F1" ) then cnt := cnt + X"01";
      elsif( cnt = X"0F2" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0F3" ) then SIOD <= OV7670_ADDR(0); cnt := cnt + X"01";
      elsif( cnt = X"0F4" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0F5" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Indicate Write Sequence
      --
      elsif( cnt = X"0F6" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0F7" ) then SIOD <= OV7670_WRITE; cnt := cnt + X"01";
      elsif( cnt = X"0F8" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0F9" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"0FA" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0FB" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"0FC" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"0FD" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write COM15 Register Address to SIOD
      --
      elsif( cnt = X"0FE" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"0FF" ) then SIOD <= OV7670_REGADDRCOM15(7); cnt := cnt + X"01";
      elsif( cnt = X"100" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"101" ) then cnt := cnt + X"01";
      elsif( cnt = X"102" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"103" ) then SIOD <= OV7670_REGADDRCOM15(6); cnt := cnt + X"01";
      elsif( cnt = X"104" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"105" ) then cnt := cnt + X"01";
      elsif( cnt = X"106" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"107" ) then SIOD <= OV7670_REGADDRCOM15(5); cnt := cnt + X"01";
      elsif( cnt = X"108" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"109" ) then cnt := cnt + X"01";
      elsif( cnt = X"10A" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"10B" ) then SIOD <= OV7670_REGADDRCOM15(4); cnt := cnt + X"01";
      elsif( cnt = X"10C" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"10D" ) then cnt := cnt + X"01";
      elsif( cnt = X"10E" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"10F" ) then SIOD <= OV7670_REGADDRCOM15(3); cnt := cnt + X"01";
      elsif( cnt = X"110" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"111" ) then cnt := cnt + X"01";
      elsif( cnt = X"112" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"113" ) then SIOD <= OV7670_REGADDRCOM15(2); cnt := cnt + X"01";
      elsif( cnt = X"114" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"115" ) then cnt := cnt + X"01";
      elsif( cnt = X"116" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"117" ) then SIOD <= OV7670_REGADDRCOM15(1); cnt := cnt + X"01";
      elsif( cnt = X"118" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"119" ) then cnt := cnt + X"01";
      elsif( cnt = X"11A" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"11B" ) then SIOD <= OV7670_REGADDRCOM15(0); cnt := cnt + X"01";
      elsif( cnt = X"11C" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"11D" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"11E" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"11F" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"120" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"121" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Write COM15 Data to COM15 Register
      --
      elsif( cnt = X"122" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"123" ) then SIOD <= OV7670_RGB444DATA(7); cnt := cnt + X"01";
      elsif( cnt = X"124" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"125" ) then cnt := cnt + X"01";
      elsif( cnt = X"126" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"127" ) then SIOD <= OV7670_RGB444DATA(6); cnt := cnt + X"01";
      elsif( cnt = X"128" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"129" ) then cnt := cnt + X"01";
      elsif( cnt = X"12A" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"12B" ) then SIOD <= OV7670_RGB444DATA(5); cnt := cnt + X"01";
      elsif( cnt = X"12C" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"12D" ) then cnt := cnt + X"01";
      elsif( cnt = X"12E" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"12F" ) then SIOD <= OV7670_RGB444DATA(4); cnt := cnt + X"01";
      elsif( cnt = X"130" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"131" ) then cnt := cnt + X"01";
      elsif( cnt = X"132" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"133" ) then SIOD <= OV7670_RGB444DATA(3); cnt := cnt + X"01";
      elsif( cnt = X"134" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"135" ) then cnt := cnt + X"01";
      elsif( cnt = X"136" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"137" ) then SIOD <= OV7670_RGB444DATA(2); cnt := cnt + X"01";
      elsif( cnt = X"138" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"139" ) then cnt := cnt + X"01";
      elsif( cnt = X"13A" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"13B" ) then SIOD <= OV7670_RGB444DATA(1); cnt := cnt + X"01";
      elsif( cnt = X"13C" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"13D" ) then cnt := cnt + X"01";
      elsif( cnt = X"13E" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"13F" ) then SIOD <= OV7670_RGB444DATA(0); cnt := cnt + X"01";
      elsif( cnt = X"140" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"141" ) then cnt := cnt + X"01";
      
      --------------------------------------------------------------------------
      -- Don't Care Bit
      --
      elsif( cnt = X"142" ) then SIOC <= '0'; cnt := cnt + X"01";
      elsif( cnt = X"143" ) then SIOD <= OV7670_DONTCARE; cnt := cnt + X"01";
      elsif( cnt = X"144" ) then SIOC <= '1'; cnt := cnt + X"01";
      elsif( cnt = X"145" ) then cnt := cnt + X"01";
      
      
      elsif( cnt = X"2FF" ) then
         cnt := X"2FF";
         CE_OUT <= '1';
      else
         cnt := cnt + X"01";
      end if;
     
   else
      null;
   end if;
end process;
---------------------------------------------------------------------------------
end Behavioral;

