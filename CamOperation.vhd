---------------------------------------------------------------------------------
-- CamOperation.vhd
--
-- Driver for OV7670
-- Camera MUST be intialized for RGB444 data ouptput
---------------------------------------------------------------------------------
-- Data is output as:
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity CamOperation is
  port(
        CLK100M_IN : in std_logic;
        CLK24M_IN : in std_logic;
        CE : in std_logic;
        D_BUG : out std_logic_vector(3 downto 0) := (others => '0');
        --CAMERA PORTS
        VSYNC : in std_logic;
        HREF : in std_logic;
        PCLK : in std_logic;
        DATA : in std_logic_vector(7 downto 0);
        XCLK : out std_logic := '0';
        n_rst : out std_logic := '1';
        PWDN : out std_logic := '0';
        CLK_OUT	: out std_logic := '0';
        D0 : out std_logic_vector(7 downto 0) := (others => '0');
        D1 : out std_logic_vector(7 downto 0) := (others => '0');
        D2 : out std_logic_vector(7 downto 0) := (others => '0');
        D3 : out std_logic_vector(7 downto 0) := (others => '0');
        CAM_EN : in std_logic
      );

end CamOperation;
---------------------------------------------------------------------------------
architecture Behavioral of CamOperation is
  signal XClk_i : std_logic;
  signal ClrPend : std_logic := '0';
  signal WPend : std_logic := '0';
  signal SampleCtrl : std_logic_vector(4 downto 0) := "00000";
  signal SampleD0 : std_logic;
  signal SampleD1 : std_logic;
  signal SampleD2 : std_logic;
  signal SampleD3 : std_logic;
  signal d_i : std_logic_vector(7 downto 0);   
  signal d_bug_i : std_logic;

---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
  PWDN <= '0';
  XCLK <= XClk_i;
  SampleD0 <= SampleCtrl(0);
  SampleD1 <= SampleCtrl(1);
  SampleD2 <= SampleCtrl(2);
  SampleD3 <= SampleCtrl(3);
  CLK_OUT <= SampleCtrl(4);

  D_BUG(0) <= XClk_i;
  D_BUG(1) <= PCLK;
  D_BUG(2) <= VSYNC;
  D_BUG(3) <= HREF;


--   XClk_i <= '0' WHEN (CE = '0') ELSE CLK24M_IN;

---------------------------------------------------------------------------------
-- Enable Camera
--
  process(CE, CLK100M_IN)
    variable cnt : std_logic_vector(1 downto 0) := ( others => '0' );
  begin
    if(CE = '0') then
      XClk_i <= '1';
    elsif(CLK100M_IN'event and CLK100M_IN = '1') then
      if(cnt = "10") then
        cnt := "00";
        XClk_i <= not XClk_i;
      else
        cnt := cnt + '1';
      end if;
    end if;
  end process;
---------------------------------------------------------------------------------
-- 
--
  process(ClrPend, PCLK, HREF, VSYNC)
  begin
    if(ClrPend = '1') then
      WPend <= '0';
    elsif(PCLK'event and PCLK = '1')
    and (HREF = '1' and VSYNC = '0')
    then
      WPend <= '1';
      d_i <= DATA;
    end if;
  end process;
--------------------------------------------------------------------------------
-- 
--
  process(CLK100M_IN, WPend, VSYNC)
    constant SAMPIDLE : std_logic_vector(4 downto 0) := "00000";
    constant SAMPD0 : std_logic_vector(4 downto 0) := "00001";
    constant SAMPD1 : std_logic_vector(4 downto 0) := "00010";
    constant SAMPD2 : std_logic_vector(4 downto 0) := "00100";
    constant SAMPD3 : std_logic_vector(4 downto 0) := "01000";
    constant SAMPOUT : std_logic_vector(4 downto 0) := "10000";
    variable cnt : std_logic_vector(3 downto 0) := "0000";
  begin
    if(CLK100M_IN'event and CLK100M_IN = '1') then
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
        if(VSYNC = '1') then
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
      D0 <= d_i;
    else
      null;
    end if;
  end process;
------------------------------------------
  process(SampleD1)
  begin
    if(SampleD1'event and SampleD1 = '1') then
      D1 <= d_i;
    else
      null;
    end if;
  end process;
------------------------------------------
  process(SampleD2)
  begin
    if(SampleD2'event and SampleD2 = '1') then
      D2 <= d_i;
    else
      null;
    end if;
  end process;
------------------------------------------
  process(SampleD3)
  begin
    if(SampleD3'event and SampleD3 = '1') then
      D3 <= d_i;
    else
      null;
    end if;
  end process;
--------------------------------------------------------------------------------
end Behavioral;
