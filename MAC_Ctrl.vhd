---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_ARITH.all;
use IEEE.std_logic_UNSIGNED.all;
Library UNISIM;
use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------
entity MAC_Ctrl is
   port(
          EN_in : in std_logic;
          CLK100 : in std_logic;
          ETH_CRS : inout std_logic;
          ETH_RSTN_L : out std_logic := '0';
          ETH_MODE0_RXD0 : out std_logic := '0';
          ETH_MODE1_RXD1 : out std_logic := '1';
          ETH_MODE2_COL : out std_logic := '0';
          ETH_TXD : out std_logic_vector(3 downto 0);
          ETH_TXEN : out std_logic;
          ETH_TXCLK : in std_logic;
--          ETH_TXDATA_IN : in std_logic_vector(3 downto 0);
          ETH_INT_L_TXER_TX4 : out std_logic;
          ETH_AD0_RXER_RXD4 : out std_logic := '1';
          ETH_AD1_RXCLK : out std_logic := '0';
          ETH_AD2_RXD3 : out std_logic := '0';
          ETH_RMIISEL_RXD2 : out std_logic := '0';
--          ETH_MDC : out std_logic; -- Not used in design
--          ETH_MDIO : out std_logic; -- Not used in design
--          ETH_TXER : out std_logic; -- Not used in design
          D_BUG : out std_logic_vector(3 downto 0)
       );
end MAC_Ctrl;
---------------------------------------------------------------------------------
architecture Structure of MAC_Ctrl is
   signal EnableConfig_i : std_logic := '0';
   signal InitComplete_i : std_logic;
   signal EnableOperation_i : std_logic := '0';
   signal Cfg_Int_L_TxEr_Tx4_i : std_logic;
   signal Op_Int_L_TxEr_Tx4_i : std_logic;
   
   -- DCM_SP
   signal Clk100_90Degrees_i : std_logic;
   signal ClkFB_i : std_logic;
   
   -- CRC signals
   signal Crc_Rst_i : std_logic;
   signal Crc_Data_i : std_logic_vector(7 downto 0);
   signal Crc_Init_i : std_logic;
   signal Crc_Data_Valid_i : std_logic;

---------------------------------------------------------------------------------
   
   component Timer10K is port(
      EN : in std_logic;
      CLK_IN : in std_logic;
      OUT_EN : out std_logic);
   end component;
   
   component ConfigStraps is port(
      CE_L  : in std_logic;
      MODE  : out std_logic_vector(2 downto 0);
      PHYAD : out std_logic_vector(2 downto 0);
      INT_L : out std_logic;
      RMIISEL : out std_logic);
   end component;

   component EthOperation is port(
      CE : in std_logic;
      CLK100 : in std_logic;
--      TX_DATA_IN : in std_logic_vector(3 downto 0);
      TXD : out std_logic_vector(3 downto 0);
      TXEN : out std_logic;
      TXCLK : in std_logic;
      TXER_TX4 : out std_logic;
      D_BUG : out std_logic_vector(3 downto 0);
      COL : out std_logic);
   end component;
   
   component CRC
   port(
      CLOCK : in std_logic;
      RESET : in std_logic;
      DATA : in std_logic_vector(7 downto 0);
      LOAD_INIT : in std_logic;
      CALC : in std_logic;
      D_VALID : in std_logic;          
      CRC : OUT std_logic_vector(7 downto 0);
      CRC_REG : OUT std_logic_vector(31 downto 0);
      CRC_VALID : OUT std_logic
      );
   end component;

   component DataFF is
      port(
            CLK_in : in std_logic;
            DATA_in : in std_logic;
            n_SRST_in : in std_logic;
            Q_out : out std_logic;
            n_Q_out : out std_logic
          );
   end component;
   
--   COMPONENT EthernetFrameBuilder
--   PORT(
--      CLOCK : in std_logic;
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
   ETH_INT_L_TXER_TX4 <= Cfg_Int_L_TxEr_Tx4_i when (EnableOperation_i = '0') else Op_Int_L_TxEr_Tx4_i;
   ETH_RSTN_L <= EnableConfig_i ;
   EnableOperation_i <= InitComplete_i and EN_in;
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
      CLKFX_DIVIDE => 2,                     -- Divide value on CLKFX outputs - D - (1-32)
      CLKFX_MULTIPLY => 2,                   -- Multiply value on CLKFX outputs - M - (2-32)
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

   U1: Timer10K
   port map(
      EN => '1',
      CLK_IN => CLK100,
      OUT_EN => EnableConfig_i
   );
      
   U2: Timer10K
   port map(
      EN => EnableConfig_i,
      CLK_IN => CLK100,
      OUT_EN => InitComplete_i
   );

   U3: ConfigStraps
   port map(
      CE_L => InitComplete_i,
      MODE(0) => ETH_MODE0_RXD0,
      MODE(1) => ETH_MODE1_RXD1,
      MODE(2) => ETH_MODE2_COL,
      PHYAD(0) => ETH_AD0_RXER_RXD4,
      PHYAD(1) => ETH_AD1_RXCLK,
      PHYAD(2) => ETH_AD2_RXD3,
      INT_L => Cfg_Int_L_TxEr_Tx4_i,
      RMIISEL => ETH_RMIISEL_RXD2
   );
      
   U4: EthOperation
   port map(
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
      
   CRC_Generator: CRC
   port map(
      CLOCK => CLK100,
      RESET => '1',
      DATA => X"00",
      LOAD_INIT => '0',
      CALC => '0',
      D_VALID => '0',
      CRC => open,
      CRC_REG => open,
      CRC_VALID => open
   );

---------------------------------------------------------------------------------
end Structure;

