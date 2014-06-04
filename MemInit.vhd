--------------------------------------------------------------------------------
-- MemInit.vhd
--
-- Configures the Micron M45W8MW16 for 4 word, 150ns write cycles.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity MemInit is
  port(
        CE : in std_logic;
        CLK_IN : in std_logic;
        MEM_ADR : out std_logic_vector(25 downto 0) := (others => 'Z');
        MEM_CS_L : out std_logic := 'Z';
        MEM_ADV_L : out std_logic := 'Z';
        MEM_OE_L : out std_logic := 'Z';
        MEM_WR_L : out std_logic := 'Z';
        MEM_UB_L : out std_logic := 'Z';
        MEM_LB_L : out std_logic := 'Z';
        MEM_CRE : out std_logic := '0';
        DONE_out : out std_logic := 'Z';
        D_BUG : out std_logic_vector(15 downto 0)
      );
end MemInit;

architecture Behavioral of MemInit is
  ------------------------------------------------------------------------------
  -- Internal Hardware Signals
  ------------------------------------------------------------------------------
  signal Clk_div_5 : STD_LOGIC := '0';

--------------------------------------------------------------------------------
-- Signal Assignments
--------------------------------------------------------------------------------
begin

  ------------------------------------------------------------------------------
  -- Initialization process
  ------------------------------------------------------------------------------
  process(CE, Clk_div_5)                                 -- 98765432109876543210
    constant BCR1 : std_logic_vector(25 downto 0) := "00000010000001010100011001";
    variable cnt : std_logic_vector(3 downto 0) := X"0";
  begin
    -------------------------------------
    -- Wait for Power up
    -------------------------------------
    if(CE = '0') then
      MEM_ADR <= (others => 'Z');
      MEM_ADV_L <= 'Z';
      MEM_OE_L <= 'Z';
      MEM_WR_L <= 'Z';
      MEM_UB_L <= 'Z';
      MEM_LB_L <= 'Z';
      MEM_CRE <= '0';
      DONE_out <= '0';
    -------------------------------------
    -- Begin Initialization
    -------------------------------------
    elsif(Clk_div_5'event and Clk_div_5 = '1') then
      if( cnt = X"0" ) then
        cnt := cnt + '1';
        MEM_ADR(25 downto 0) <= BCR1;
        MEM_CS_L <= '1';
        MEM_CRE <= '1';
        MEM_ADV_L <= '1';
        MEM_WR_L <= '1';
      elsif( cnt = X"1" ) then
        cnt := cnt + '1';
        MEM_CS_L <= '0';
        MEM_ADV_L <= '0';
        MEM_WR_L <= '0';
      -------------------------------------
      -- Set Outputs to High-Z
      -------------------------------------
      elsif( cnt = X"2" ) then
        cnt := cnt + '1';
        MEM_ADR(25 downto 0) <= (others => 'Z');
        MEM_CRE <= 'Z';
        MEM_ADV_L <= 'Z';
        MEM_WR_L <= 'Z';
      -------------------------------------
      -- Enable Normal Operation
      -------------------------------------
      elsif( cnt = X"3" ) then
        cnt := cnt + '1';
        DONE_out <= '1';
      -------------------------------------
      -- Trap
      -------------------------------------
      else
        null;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Clock divider (div 5)
  ------------------------------------------------------------------------------
  process(CLK_IN)
    variable cnt : std_logic_vector(2 downto 0) := "000";
  begin
    if( CLK_IN'event and CLK_IN = '1' ) then
      if( cnt < "101" ) then
        cnt := cnt + '1';
      else
        cnt := "000";
        Clk_div_5 <= not CLK_1_i;
      end if;
    else
      null;
    end if;
  end process;

--------------------------------------------------------------------------------
end Behavioral;

