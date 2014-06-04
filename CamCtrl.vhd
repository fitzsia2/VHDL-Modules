---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity CamCtrl is
	port(
    CLK20     : in  STD_LOGIC;
    D_BUG     : out STD_LOGIC_VECTOR(3 downto 0);
    --CAMERA PORTS
    VSYNC     :in STD_LOGIC;
    HREF      :in STD_LOGIC;
    PCLK      :in STD_LOGIC;
    DATA      :in STD_LOGIC_VECTOR(7 downto 0);
    SIOC      :out STD_LOGIC;
    SIOD      :out STD_LOGIC;
    XCLK      :out STD_LOGIC;
    EXPORT	   :out STD_LOGIC;
    Y0        :out STD_LOGIC_VECTOR(7 downto 0);
    Y1        :out STD_LOGIC_VECTOR(7 downto 0);
    CB        :out STD_LOGIC_VECTOR(7 downto 0);
    CR        :out STD_LOGIC_VECTOR(7 downto 0);
    CAM_EN    :in STD_LOGIC
    );
end CamCtrl;
---------------------------------------------------------------------------------
-- Internal Signal Declarations
---------------------------------------------------------------------------------
architecture Behavioral of CamCtrl is
  TYPE STATE_TYPE is (S0, S1, S2, S3);

  signal SampCtrl  :STD_LOGIC_VECTOR(4 downto 0);
  signal Y0Clk     :STD_LOGIC;
  signal CBClk     :STD_LOGIC;
  signal Y1Clk     :STD_LOGIC;
  signal CRClk     :STD_LOGIC;
  signal SReg		  : STATE_TYPE := S0;
  signal SNext	  : STATE_TYPE := S0;
---------------------------------------------------------------------------------
-- Signal Assignments
---------------------------------------------------------------------------------
begin
   SIOC <= '0';
   SIOD <= '0';

   EXPORT <= SampCtrl(4);
   CRClk <= SampCtrl(3);
   Y1Clk <= SampCtrl(2);
   CBClk <= SampCtrl(1);
   Y0Clk <= SampCtrl(0);
   
   D_BUG(0) <= PCLK;
   D_BUG(1) <= SampCtrl(4);
   D_BUG(2) <= HREF;
   D_BUG(3) <= VSYNC;
   
---------------------------------------------------------------------------------
-- Enable Camera
---------------------------------------------------------------------------------
process(CAM_EN, CLK20)
begin
if(CAM_EN = '1') then
   XCLK <= CLK20;
else
   XCLK <= '0';
end if;
end process;
--------------------------------------------------------------------------------
-- State Machine Description
---------------------------------------------------------------------------------
process(HREF,VSYNC,PCLK,SNext,CAM_EN)
begin
   if(HREF = '1' and VSYNC = '0')
      and(PCLK'event and PCLK='1')
   then
      SReg <= SNext;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
-- Description of State Machine
--
process(SReg, SNext)
CONSTANT SAMPLEY0 : STD_LOGIC_VECTOR(4 downto 0) := "00001";
CONSTANT SAMPLECB : STD_LOGIC_VECTOR(4 downto 0) := "00010";
CONSTANT SAMPLEY1 : STD_LOGIC_VECTOR(4 downto 0) := "00100";
CONSTANT SAMPLECR : STD_LOGIC_VECTOR(4 downto 0) := "11000";
begin
   case SReg is
      when S0 =>
         SampCtrl <= SAMPLECB;
         SNext <= S1;
      when S1 =>
         SampCtrl <= SAMPLEY0;
         SNext <= S2;
      when S2 =>
         SampCtrl <= SAMPLECR;
         SNext <= S3;
      when S3 =>
         SampCtrl <= SAMPLEY1;
         SNext <= S0;
      when others =>
         SNext <= S0;
      end case;
end process;
--------------------------------------------------------------------------------
-- 
--
process(Y0Clk, CBClk, Y1Clk, CRClk, DATA)
begin
   if(Y0Clk'event and Y0Clk='1') then
      Y0 <= DATA;
   else
      null;
   end if;
   if(CBClk'event and CBClk='1') then
      CB <= DATA;
   else
      null;
   end if;
   if(Y1Clk'event and Y1Clk='1') then
      Y1 <= DATA;
   else
      null;
   end if;
   if(CRClk'event and CRClk='1') then
      CR <= DATA;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
