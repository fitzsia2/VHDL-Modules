---------------------------------------------------------------------------------
-- Module Is Currently Configured for RGB444
--    D0[7:4] - 'X'
--      [3:0] - 'R'
--    D1[7:4] - 'G'
--      [3:0] - 'B'
--    D2[7:4] - 'X'
--      [3:0] - 'R'
--    D3[7:4] - 'G'
--      [3:0] - 'B'
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity CamOperation is
	port(
	  CLK_IN    : in  STD_LOGIC;
     CE        : in STD_LOGIC;
     D_BUG     : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
   --CAMERA PORTS
     VSYNC     :in STD_LOGIC;
     HREF      :in STD_LOGIC;
     PCLK      :in STD_LOGIC;
     DATA      :in STD_LOGIC_VECTOR(7 downto 0);
     XCLK      :out STD_LOGIC := '0';
     ARST_L    :out STD_LOGIC := '1';
     PWDN      :out STD_LOGIC := '0';
	  CLK_OUT	:out STD_LOGIC := '0';
	  D0        :out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	  D1        :out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	  D2        :out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	  D3        :out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
     CAM_EN    :in STD_LOGIC);
      
end CamOperation;
---------------------------------------------------------------------------------
architecture Behavioral of CamOperation is
	TYPE STATE_TYPE is (S0, S1, S2, S3, INIT);

   signal Clk_10_i  : STD_LOGIC;
   signal ARst_i    : STD_LOGIC := '0';
   
   signal d_bug_i   : STD_LOGIC;
   signal d0_i : STD_LOGIC_VECTOR(7 downto 0);
   
---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   ARST_L <= not ARst_i;
   PWDN <= '0';
   XCLK <= Clk_10_i;
--   D0 <= d0_i;
   
   D_BUG(0) <= Clk_10_i;
   D_BUG(1) <= PCLK;
   D_BUG(2) <= VSYNC;

--   D_BUG <= d0_i(3 downto 0);
   
---------------------------------------------------------------------------------
-- Enable Camera
--
process(CE, CLK_IN)
variable cnt : STD_LOGIC_VECTOR(1 downto 0) := ( others => '0' );
begin
   if((CE = '0')) then
      Clk_10_i <= '1';
   elsif(CLK_IN'event and CLK_IN = '1') then
      if(cnt = "10") then
         cnt := "00";
         Clk_10_i <= not Clk_10_i;
      else
         cnt := cnt + '1';
      end if;
   end if;
end process;
--------------------------------------------------------------------------------
-- State Machine Description
--
process(HREF, VSYNC, PCLK)
variable cnt : INTEGER := 0;
begin
   if(HREF = '1' and VSYNC = '0') then
      if(PCLK'event and PCLK='1') then
         if(cnt = 0) then
            D0(7 downto 0) <= DATA(7 downto 0);
--            d0_i(7 downto 0) <= "00001111";
            CLK_OUT <= '0';
            D_BUG(3) <= '0';
            cnt := 1;
         elsif(cnt = 1) then
            D1(7 downto 0) <= DATA(7 downto 0);
--            D1(7 downto 0) <= "00000000";
            CLK_OUT <= '0';
            D_BUG(3) <= '0';
            cnt := 2;
         elsif(cnt = 2) then
            D2(7 downto 0) <= DATA(7 downto 0);
--            D2(7 downto 0) <= "00000000";
            CLK_OUT <= '0';
            D_BUG(3) <= '0';
            cnt := 3;
         elsif(cnt = 3) then
            D3(7 downto 0) <= DATA(7 downto 0);
--            D3(7 downto 0) <= "00000000";
            CLK_OUT <= '1';
            D_BUG(3) <= '1';
            cnt := 0;
         end if;
      else
         null;
      end if;
   else
      cnt := 0;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
