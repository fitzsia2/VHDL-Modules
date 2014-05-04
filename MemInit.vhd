---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity MemInit is
   port(
      CE : in STD_LOGIC;
      CLK_IN : in STD_LOGIC;
      MEM_ADR : out STD_LOGIC_VECTOR(25 downto 0) := (others => 'Z');
      MEM_CS_L : out STD_LOGIC := 'Z';
      MEM_ADV_L : out STD_LOGIC := 'Z';
      MEM_OE_L : out STD_LOGIC := 'Z';
      MEM_WR_L : out STD_LOGIC := 'Z';
      MEM_UB_L : out STD_LOGIC := 'Z';
      MEM_LB_L : out STD_LOGIC := 'Z';
      MEM_CRE : out STD_LOGIC := '0';
      OUT_EN : out STD_LOGIC := 'Z';
      D_BUG : out STD_LOGIC_VECTOR(15 downto 0)
      );
end MemInit;

--------------------------------------------------------------------------------
-- Internal Hardware Signals
--------------------------------------------------------------------------------
architecture Behavioral of MemInit is
   signal Clk_1_i : STD_LOGIC := '0';

--------------------------------------------------------------------------------
-- Signal Assignments
--------------------------------------------------------------------------------
begin


--------------------------------------------------------------------------------
-- 
--
process(CLK_IN)
variable cnt : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin
   if( CLK_IN'event and CLK_IN = '1' ) then
      if( cnt < "101" ) then
         cnt := cnt + '1';
      else
         cnt := "000";
         Clk_1_i <= not CLK_1_i;
      end if;
   else
      null;
   end if;
end process;
--------------------------------------------------------------------------------
-- 
--
process(CE, Clk_1_i)                                 -- 98765432109876543210
CONSTANT BCR1 : STD_LOGIC_VECTOR(25 downto 0) := "00000010000001010100011001";
variable cnt : STD_LOGIC_VECTOR(3 downto 0) := X"0";
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
      OUT_EN <= '0';
   -------------------------------------
   -- Begin Initialization
   -------------------------------------
   elsif(Clk_1_i'event and Clk_1_i = '1') then
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
         OUT_EN <= '1';
   -------------------------------------
   -- Trap
   -------------------------------------
      else
         null;
      end if;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;

