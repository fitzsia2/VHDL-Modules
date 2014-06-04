---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------
entity MAC_Ctrl is
   port ( CLK100 : in STD_LOGIC;
          ETH_CRS           : inout STD_LOGIC;
          ETH_RSTN_L        : out STD_LOGIC := '0';
          ETH_MODE0_RXD0    : out STD_LOGIC := '0';
          ETH_MODE1_RXD1    : out STD_LOGIC := '1';
          ETH_MODE2_COL     : out STD_LOGIC := '0';
          ETH_TXD           : out STD_LOGIC_VECTOR(3 downto 0);
          ETH_TXEN          : out STD_LOGIC;
          ETH_TXCLK         : in STD_LOGIC;
--          ETH_TXDATA_IN     : in STD_LOGIC_VECTOR(3 downto 0);
          ETH_INT_L_TXER_TX4: out STD_LOGIC;
          ETH_AD0_RXER_RXD4 : out STD_LOGIC := '1';
          ETH_AD1_RXCLK     : out STD_LOGIC := '0';
          ETH_AD2_RXD3      : out STD_LOGIC := '0';
          ETH_RMIISEL_RXD2  : out STD_LOGIC := '0';
--          ETH_MDC           : out STD_LOGIC; -- Not used in design
--          ETH_MDIO          : out STD_LOGIC; -- Not used in design
--          ETH_TXER          : out STD_LOGIC; -- Not used in design
          D_BUG             : out STD_LOGIC_VECTOR(3 downto 0));
end MAC_Ctrl;
---------------------------------------------------------------------------------
architecture Structure of MAC_Ctrl is
   signal EnableConfig_i : STD_LOGIC := '0';
   signal EnableOperation_i : STD_LOGIC := '0';
   signal Cfg_Int_L_TxEr_Tx4_i : STD_LOGIC;
   signal Op_Int_L_TxEr_Tx4_i : STD_LOGIC;
   
   -- DCM_SP
   signal Clk100_90Degrees_i : STD_LOGIC;
   signal ClkFB_i : STD_LOGIC;
   
   -- CRC signals
   signal Crc_Rst_i : STD_LOGIC;
   signal Crc_Data_i : STD_LOGIC_VECTOR(7 downto 0);
   signal Crc_Init_i : STD_LOGIC;
   signal Crc_Data_Valid_i : STD_LOGIC;

---------------------------------------------------------------------------------
   
   component Timer10K is port(
      EN : in STD_LOGIC;
      CLK_IN : in STD_LOGIC;
      OUT_EN : out STD_LOGIC);
   end component;
   
   component ConfigStraps is port(
      CE_L  : in STD_LOGIC;
      MODE  : out STD_LOGIC_VECTOR(2 downto 0);
      PHYAD : out STD_LOGIC_VECTOR(2 downto 0);
      INT_L : out STD_LOGIC;
      RMIISEL : out STD_LOGIC);
   end component;

   component EthOperation is port(
      CE : in STD_LOGIC;
      CLK100 : in STD_LOGIC;
--      TX_DATA_IN : in STD_LOGIC_VECTOR(3 downto 0);
      TXD : out STD_LOGIC_VECTOR(3 downto 0);
      TXEN : out STD_LOGIC;
      TXCLK : in STD_LOGIC;
      TXER_TX4 : out STD_LOGIC;
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
      COL : out STD_LOGIC);
   end component;
   
   COMPONENT CRC
   PORT(
      CLOCK : IN std_logic;
      RESET : IN std_logic;
      DATA : IN std_logic_vector(7 downto 0);
      LOAD_INIT : IN std_logic;
      CALC : IN std_logic;
      D_VALID : IN std_logic;          
      CRC : OUT std_logic_vector(7 downto 0);
      CRC_REG : OUT std_logic_vector(31 downto 0);
      CRC_VALID : OUT std_logic
      );
   END COMPONENT;
   
--   COMPONENT EthernetFrameBuilder
--   PORT(
--      CLOCK : IN std_logic;
--      RESET_OUT : OUT std_logic;
--      DATA_OUT : OUT std_logic_vector(7 downto 0);
--      INIT_CRC : OUT std_logic;
--      CALC_OUT : OUT std_logic;
--      D_VALID_OUT : OUT std_logic
--   );
--   END COMPONENT;
   
      
---------------------------------------------------------------------------------
-- Signal Assignment
begin
   ETH_INT_L_TXER_TX4 <= Cfg_Int_L_TxEr_Tx4_i WHEN (EnableOperation_i = '0') ELSE Op_Int_L_TxEr_Tx4_i;
   ETH_RSTN_L <= EnableConfig_i ;
   ETH_CRS <= 'Z';
                                     
---------------------------------------------------------------------------------
-- Component Signal Assignment
---------------------------------------------------------------------------------
   
   -- DCM_SP: Digital Clock Manager
   --         Spartan-6
   -- Xilinx HDL Language Template, version 14.3
   DCM_SP_inst : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0,                   -- CLKDV divide value
                                             -- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      CLKFX_DIVIDE => 1,                     -- Divide value on CLKFX outputs - D - (1-32)
      CLKFX_MULTIPLY => 1,                   -- Multiply value on CLKFX outputs - M - (2-32)
      CLKIN_DIVIDE_BY_2 => FALSE,            -- CLKIN divide by two (TRUE/FALSE)
      CLKIN_PERIOD => 10.0,                  -- Input clock period specified in nS
      CLKOUT_PHASE_SHIFT => "NONE",          -- Output phase shift (NONE, FIXED, VARIABLE)
      CLK_FEEDBACK => "NONE",                  -- Feedback source (NONE, 1X, 2X)
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      DFS_FREQUENCY_MODE => "LOW",           -- Unsupported - Do not change value
      DLL_FREQUENCY_MODE => "LOW",           -- Unsupported - Do not change value
      DSS_MODE => "NONE",                    -- Unsupported - Do not change value
      DUTY_CYCLE_CORRECTION => TRUE,         -- Unsupported - Do not change value
      FACTORY_JF => X"c080",                 -- Unsupported - Do not change value
      PHASE_SHIFT => 0,                      -- Amount of fixed phase shift (-255 to 255)
      STARTUP_WAIT => FALSE                  -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   port map (
      CLK0 => open,                  -- 1-bit output: 0 degree clock output
      CLK180 => open,                -- 1-bit output: 180 degree clock output
      CLK270 => open,                -- 1-bit output: 270 degree clock output
      CLK2X => open,                 -- 1-bit output: 2X clock frequency clock output
      CLK2X180 => open,              -- 1-bit output: 2X clock frequency, 180 degree clock output
      CLK90 => Clk100_90Degrees_i,   -- 1-bit output: 90 degree clock output
      CLKDV => open,                 -- 1-bit output: Divided clock output
      CLKFX => open,                 -- 1-bit output: Digital Frequency Synthesizer output (DFS)
      CLKFX180 => open,              -- 1-bit output: 180 degree CLKFX output
      LOCKED => open,                -- 1-bit output: DCM_SP Lock Output
      PSDONE => open,                -- 1-bit output: Phase shift done output
      STATUS => open,                -- 8-bit output: DCM_SP status output
      CLKFB => ClkFB_i,              -- 1-bit input: Clock feedback input
      CLKIN => CLK100,               -- 1-bit input: Clock input
      DSSEN => '0',                  -- 1-bit input: Unsupported, specify to GND.
      PSCLK => open,                 -- 1-bit input: Phase shift clock input
      PSEN => open,                  -- 1-bit input: Phase shift enable
      PSINCDEC => open,              -- 1-bit input: Phase shift increment/decrement input
      RST => '0'                     -- 1-bit input: Active high reset input
   ); -- End of DCM_SP_inst instantiation

   U1: Timer10K port map(
      EN => '1',
      CLK_IN => CLK100,
      OUT_EN => EnableConfig_i);
      
   U2: Timer10K port map(
      EN => EnableConfig_i,
      CLK_IN => CLK100,
      OUT_EN => EnableOperation_i);

   U3: ConfigStraps port map(
      CE_L => EnableOperation_i,
      MODE(0) => ETH_MODE0_RXD0,
      MODE(1) => ETH_MODE1_RXD1,
      MODE(2) => ETH_MODE2_COL,
      PHYAD(0) => ETH_AD0_RXER_RXD4,
      PHYAD(1) => ETH_AD1_RXCLK,
      PHYAD(2) => ETH_AD2_RXD3,
      INT_L => Cfg_Int_L_TxEr_Tx4_i,
      RMIISEL => ETH_RMIISEL_RXD2);
      
   U4: EthOperation port map(
      CE => EnableOperation_i,
      CLK100 => CLK100,
      TXD(3 downto 0) => ETH_TXD,
      TXEN => ETH_TXEN,
      TXCLK => ETH_TXCLK,
      TXER_TX4 => Op_Int_L_TxEr_Tx4_i,
      COL => ETH_MODE2_COL,
      D_BUG(3 downto 0) => D_BUG(3 downto 0)
   );
      
--   EthernetFrameBuilder : EthernetFrameBuilder PORT MAP(
--      CLOCK => CLOCK100,
--      RESET_OUT => Crc_Rst_i,
--      DATA_OUT(7 downto 0) => Crc_Data_i(7 downto 0),
--      INIT_CRC => Crc_Init_i,
--      CALC_OUT => Crc_Calc_i,
--      D_VALID_OUT => Crc_Data_Valid_i
--   );
      
   CRC_Generator: CRC PORT MAP(
      CLOCK => CLK100,
      RESET => '1',
      DATA => X"00",
      LOAD_INIT => '0',
      CALC => '0',
      D_VALID => '0',
      CRC => OPEN,
      CRC_REG => OPEN,
      CRC_VALID => OPEN
   );

---------------------------------------------------------------------------------
end Structure;

