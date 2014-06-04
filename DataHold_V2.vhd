---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity DataHold_V2 is
  port(
        ARST : in std_logic;
        CLK100 : in std_logic;
        CLK_IN : in std_logic;
        D0 : in std_logic_vector(7 downto 0);
        D1 : in std_logic_vector(7 downto 0);
        D2 : in std_logic_vector(7 downto 0);
        D3 : in std_logic_vector(7 downto 0);
        CLK_OUT : out std_logic;
        D_OUT : out std_logic_vector(63 downto 0);
        D_BUG : out std_logic_vector(3 downto 0)
      );

end DataHold_V2;
---------------------------------------------------------------------------------
architecture Behavioral of DataHold_V2 is
  signal ClrPend : std_logic := '0';
  signal WPend : std_logic := '0';
  signal d0_i : std_logic_vector(7 downto 0) := X"00";
  signal d1_i : std_logic_vector(7 downto 0) := X"00";
  signal d2_i : std_logic_vector(7 downto 0) := X"00";
  signal d3_i : std_logic_vector(7 downto 0) := X"00";
  signal SampleCtrl : std_logic_vector(4 downto 0) := "00000";
  signal SampleD0 : std_logic;
  signal SampleD1 : std_logic;
  signal SampleD2 : std_logic;
  signal SampleD3 : std_logic;

  signal d_bug_i : std_logic;

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
    constant SAMPIDLE : std_logic_vector(4 downto 0) := "00000";
    constant SAMP0 : std_logic_vector(4 downto 0) := "00001";
    constant SAMP1 : std_logic_vector(4 downto 0) := "00010";
    constant SAMP2 : std_logic_vector(4 downto 0) := "00100";
    constant SAMP3 : std_logic_vector(4 downto 0) := "01000";
    constant SAMPOUT : std_logic_vector(4 downto 0) := "10000";
    variable cnt : std_logic_vector(3 downto 0) := "0000";
  begin
    if( ARST = '1' ) then
      cnt = X"0";
      SampleCtrl <= SAMPIDLE;
      ClrPend <= '1';
    if(CLK100'event and CLK100 = '1') then
      if(cnt = X"0" and WPend = '1') then
        cnt := cnt + '1';
        SampleCtrl <= SAMP0;
        ClrPend <= '1';
      elsif(cnt = X"1" and WPend = '1') then
        cnt := cnt + '1';
        SampleCtrl <= SAMP1;
        ClrPend <= '1';
      elsif(cnt = X"2") then
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
      D_OUT(7 downto 0) <= d0_i(7 downto 0);
      D_OUT(15 downto 8) <= d1_i(7 downto 0);
      D_OUT(23 downto 16) <= d2_i(7 downto 0);
      D_OUT(31 downto 24) <= d3_i(7 downto 0);
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
    else
      null;
    end if;
  end process;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Behavioral;
