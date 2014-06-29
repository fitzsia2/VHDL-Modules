---------------------------------------------------------------------------------
-- VideoCam.vhd (Structure)
--
-- Top-Level Structure
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------
entity VideoCam is
   port(
         CLK100 : in std_logic;
         CAM_EN : in std_logic;
         VGA_EN : in std_logic;
         D_BUG : out std_logic_vector(15 downto 0) := (others => '0');
         -- Camera Signals
         CAM_SIOC : out std_logic := '0';
         CAM_SIOD : out std_logic := '0';
         CAM_VSYNC : in std_logic;
         CAM_HREF : in std_logic;
         CAM_PCLK : in std_logic;
         CAM_DATA : in std_logic_vector (7 downto 0);
         CAM_XCLK : out std_logic := '0';
         -- Memory Signals
         MEM_MT_CRE: out std_logic := '0';
         MEM_DATA : inout std_logic_vector (15 downto 0);
         MEM_ADR : out std_logic_vector (25 downto 0) := (others => '0');
         PCM_CS_L : out std_logic := '0';
         MEM_CS_L : out std_logic := '0';
         MEM_OE_L : out std_logic := '0';
         MEM_WR_L : out std_logic := '0';
         MEM_ADV_L : out std_logic := '0';
         MEM_CLK_L : out std_logic := '0';
         MEM_UB_L : out std_logic := '0';
         MEM_LB_L : out std_logic := '0';
         -- VGA Signals
         RED_OUT : out std_logic_vector(2 downto 0) := (others => '0');
         GREEN_OUT : out std_logic_vector(2 downto 0) := (others => '0');
         BLUE_OUT : out std_logic_vector(2 downto 1) := (others => '0');
         HS_OUT : out std_logic := '0';
         VS_OUT : out std_logic := '0';
         -- Ethernet Signals
         ETH_TXCLK : in std_logic;          
         ETH_RSTN_L : out std_logic := '0';
         ETH_MODE0_RXD0 : out std_logic := '0';
         ETH_CRS : inout std_logic;
         ETH_MODE1_RXD1 : out std_logic := '0';
         ETH_MODE2_COL : out std_logic := '0';
         ETH_TXD : out std_logic_vector(3 downto 0) := (others => '0');
         ETH_TXEN : out std_logic := '0';
         ETH_INT_L_TXER_TX4 : out std_logic := '0';
         ETH_AD0_RXER_RXD4 : out std_logic := '0';
         ETH_AD1_RXCLK : out std_logic := '0';
         ETH_AD2_RXD3 : out std_logic := '0';
         ETH_RMIISEL_RXD2 : out std_logic := '0';
         -- LED Signals
         LED_ARRAY_L : out std_logic_vector(7 downto 0) := (others => '0')
       );
end VideoCam;

architecture Structure of VideoCam is
   ------------------------------------------------------------------------------
   -- Signal Declarations
   ------------------------------------------------------------------------------
   constant MEMORYADDRESSBUSWIDTH : integer := 26;

   ------------------------------------------------------------------------------
   -- Signal Declarations
   ------------------------------------------------------------------------------
   signal Clk_20_i  : std_logic;

   -- DCM Signals
   signal clkfx_24m_i : std_logic; -- Camera Clock
   signal clkfx180_i : std_logic;
   signal freezedcm_i : std_logic := '0';
   signal progclk_i : std_logic := '0';
   signal progdata_i : std_logic := '0';
   signal progen_i : std_logic := '0';
   signal rst_i : std_logic := '0';

   -- PixelCounter signals
   signal PixelCounter_Count_i : std_logic_vector( MEMORYADDRESSBUSWIDTH-1 downto 0 ); -- Same size as PixelCounter generic N

   -- Cmp1 signals
   signal Cmp1_LT_i : std_logic; -- Used for disabling camera operation

   -- CamCtrl To YCbCrToRGB332
   signal CamCtrl_ClkOut_i : std_logic;
   signal CamCtrl_D0_i : std_logic_vector(7 downto 0);
   signal CamCtrl_D1_i : std_logic_vector(7 downto 0);
   signal CamCtrl_D2_i : std_logic_vector(7 downto 0);
   signal CamCtrl_D3_i : std_logic_vector(7 downto 0);

   -- YCbCrToRGB332 to DataHold1
   signal RGB332_Data_i : std_logic_vector(15 downto 0);
   signal RGB332_ClkOut_i : std_logic;

   --DataHold1 To MemCtrl
   signal DataHold1_Ack : std_logic;
   signal DataHold1_ClkOut : std_logic;
   signal DataHold1_DOUT_i : std_logic_vector(63 downto 0);
   
   -- Multiplexer to MemCtrl Address bus
   signal MemCtrl_WrAddressIn_i : std_logic_vector( MEMORYADDRESSBUSWIDTH-1 downto 0 );
   
   -- Multiplexer to MemCtrl Data bus
   signal MemCtrl_WrDataIn_i :std_logic_vector( 63 downto 0 );

   --MemCtrl To DataHold2
   signal MemCtrl_ClkOut_i : std_logic;
   signal MemCtrl_DOUT_i : std_logic_vector(15 downto 0);

   -- DataHold2 To VGADriver
   signal DataHold2_Ack_L : std_logic;
   signal DataHold2_ClkOut : std_logic;
   signal DataHold2_DOUT_i : std_logic_vector(63 downto 0);

   -- VGADriver To MemCtrl
   signal VGADriver_ClkOut_i : std_logic;
   signal VGADriver_Address_i : std_logic_vector(25 downto 0);

   -- Ethernet
   signal Eth_Rst_L_i : std_logic;
   signal Eth_TxClk_i : std_logic;
   signal Eth_Crs_i : std_logic;

   ------------------------------------------------------------------------------
   -- Component Declarations
   ------------------------------------------------------------------------------
   component Counter is
      generic(
               N : integer
             );
      port(
            EN_in : in std_logic;
            CLK_in : in std_logic;
            RST_in : in std_logic;
            COUNT_OUT : out std_logic_vector( N-1 downto 0 )
          );
   end component;

   component Comparator is
      generic(
               WIDTH_g : integer
             );
      port(
            A_in : in std_logic_vector( WIDTH_g-1 downto 0);
            B_in : in std_logic_vector( WIDTH_g-1 downto 0);
            EQ : out std_logic;
            NEQ : out std_logic;
            LT : out std_logic;
            LTE : out std_logic;
            GT : out std_logic;
            GTE : out std_logic
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

   component cam_ctrl is
      port(
            CLK_IN : in std_logic;
            CLK24M_IN : in std_logic;
            VSYNC : in std_logic;
            HREF : in std_logic;
            PCLK : in std_logic;
            DATA : in std_logic_vector(7 downto 0);
            CAM_EN : in std_logic;          
            SIOC : out std_logic;
            SIOD : out std_logic;
            D_BUG : out std_logic_vector(3 downto 0);
            XCLK : out std_logic;
            n_rst : out std_logic;
            PWDN : out std_logic;
            CLK_OUT : out std_logic;
            D0 : out std_logic_vector(7 downto 0);
            D1 : out std_logic_vector(7 downto 0);
            D2 : out std_logic_vector(7 downto 0);
            D3 : out std_logic_vector(7 downto 0)
          );
   end component;

   component DataHold_V2 is
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
   end component;

   component YcbCrToRGB332 is
      port(
            CLK100 : in  std_logic;
            CLK_IN : in std_logic;
            Y0 : in std_logic_vector(7 downto 0);
            Y1 : in std_logic_vector(7 downto 0);
            CB : in std_logic_vector(7 downto 0);
            CR : in std_logic_vector(7 downto 0);
            CLK_OUT : out std_logic;
            DATA : out std_logic_vector(15 downto 0);
            D_BUG : out std_logic_vector(3 downto 0)
          );
   end component;

   component CamDataAddressManager is
      generic(
               N : integer
             );
      port(
            ARST_in : in std_logic;
            CLK_in : in std_logic; -- Used for counting
            ADDRESS_out : out std_logic_vector( N-1 downto 0 ) := (others => '0')
          );
   end component;
            
   
   component MuxTwoToOne is
      generic(
               N : integer
             );
      port(
            A_in : in std_logic_vector( N-1 downto 0 );
            B_in : in std_logic_vector( N-1 downto 0 );
            SELECT_in : in std_logic;
            Y_out : out std_logic_vector( N-1 downto 0 )
          );
   end component;

   component mem_ctrl is
      port(
            CLK_IN : in std_logic;
            MEM_MT_CRE : out std_logic;
            WCLK : in std_logic;
            WADR_RST : in std_logic;
            ADR_in : in std_logic_vector(25 downto 0);
            D_IN : in std_logic_vector(63 downto 0);
            DATA_ACK_out : out std_logic;
            RCLK : in std_logic;
            ADR_READ : in std_logic_vector(25 downto 0);    
            MEM_DB : inout std_logic_vector(15 downto 0);      
            D_OUT : out std_logic_vector(15 downto 0);
            RCLK_OUT : out std_logic;
            D_BUG : out std_logic_vector(3 downto 0);
            PCM_CS_L : out std_logic;
            MEM_CS_L : out std_logic;
            MEM_OE_L : out std_logic;
            MEM_WR_L : out std_logic;
            MEM_ADV_L : out std_logic;
            MEM_CLK_L : out std_logic;
            MEM_UB_L : out std_logic;
            MEM_LB_L : out std_logic;
            MEM_ADR : out std_logic_vector(25 downto 0)
          );
   end component;

   component DataHold is
      port(
            ARST_L : in std_logic;
            CLK100 : in std_logic;
            CLK_IN : in std_logic;
            D_IN : in std_logic_vector(15 downto 0);
            CLK_OUT : out std_logic;
            D_OUT : out std_logic_vector(63 downto 0);
            D_BUG : out std_logic_vector(3 downto 0)
          );
   end component;

   component VGADriver is
      port(
            CLK_100M_IN : in std_logic;
            D_BUG : out std_logic_vector(3 downto 0);
            CLK_OUT : out std_logic;
            ADR_READ : out std_logic_vector(25 downto 0);
            CLK_IN : in std_logic;
            D_IN : in std_logic_vector(63 downto 0);
            RED_OUT : out std_logic_vector(2 downto 0);
            GREEN_OUT : out std_logic_vector(2 downto 0);
            BLUE_OUT : out std_logic_vector(1 downto 0);
            HS_OUT : out std_logic;
            VS_OUT : out std_logic;
            VGA_EN : in std_logic
          );
   end component;

   component mac_ctrl
      port(
            CLK100 : in std_logic;
            ETH_CRS : inout std_logic;
            ETH_TXCLK : in std_logic;          
            ETH_RSTN_L : out std_logic;
            ETH_MODE0_RXD0 : out std_logic;
            ETH_MODE1_RXD1 : out std_logic;
            ETH_MODE2_COL : out std_logic;
            ETH_TXD : out std_logic_vector(3 downto 0);
            ETH_TXEN : out std_logic;
            ETH_INT_L_TXER_TX4 : out std_logic;
            ETH_AD0_RXER_RXD4 : out std_logic;
            ETH_AD1_RXCLK : out std_logic;
            ETH_AD2_RXD3 : out std_logic;
            ETH_RMIISEL_RXD2 : out std_logic;
            D_BUG : out std_logic_vector(3 downto 0)
          );
   end component;

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Signal Assignments
Begin
   ETH_RSTN_L <= Eth_Rst_L_i;
   Eth_TxClk_i <= ETH_TXCLK;
   Eth_Crs_i <= ETH_CRS;
   ETH_CRS <= Eth_Crs_i;
   LED_ARRAY_L(0) <= Eth_Rst_L_i;
   LED_ARRAY_L(1) <= Eth_TxClk_i;
   LED_ARRAY_L(2) <= Eth_Crs_i;
   LED_ARRAY_L(7 downto 3) <= "00000";

   ---------------------------------------------------------------------------------
   -- Clock Management Resources
   --
   DCM_CLKGEN_CAMERA : DCM_CLKGEN
   generic map(
                 CLKFXDV_DIVIDE => 2,       -- CLKFXDV divide value (2, 4, 8, 16, 32)
                 CLKFX_DIVIDE => 50,         -- Divide value - D - (1-256)
                 CLKFX_MD_MAX => 0.12,       -- Specify maximum M/D ratio for timing anlysis
                 CLKFX_MULTIPLY => 6,       -- Multiply value - M - (2-256)
                 CLKIN_PERIOD => 10.00,       -- Input clock period specified in nS
                 SPREAD_SPECTRUM => "NONE", -- Spread Spectrum mode "NONE", "CENTER_LOW_SPREAD", "CENTER_HIGH_SPREAD",
                                            -- "VIDEO_LINK_M0", "VIDEO_LINK_M1" or "VIDEO_LINK_M2" 
                 STARTUP_WAIT => FALSE      -- Delay config DONE until DCM_CLKGEN LOCKED (TRUE/FALSE)
              )
   port map(
              CLKFX => clkfx_24m_i,         -- 1-bit output: Generated clock output
              CLKFX180 => open,   -- 1-bit output: Generated clock output 180 degree out of phase from CLKFX.
              CLKFXDV => open,     -- 1-bit output: Divided clock output
              LOCKED => open,       -- 1-bit output: Locked output
              PROGDONE => open,   -- 1-bit output: Active high output to indicate the successful re-programming
              STATUS => open,       -- 2-bit output: DCM_CLKGEN status
              CLKIN => CLK100,         -- 1-bit input: Input clock
              FREEZEDCM => freezedcm_i, -- 1-bit input: Prevents frequency adjustments to input clock
              PROGCLK => progclk_i,     -- 1-bit input: Clock input for M/D reconfiguration
              PROGDATA => progdata_i,   -- 1-bit input: Serial data input for M/D reconfiguration
              PROGEN => progen_i,       -- 1-bit input: Active high program enable
              RST => rst_i              -- 1-bit input: Reset input pin
           );

   ---------------------------------------------------------------------------------
   -- Connection Description
   --
   Cnt1: Counter
   generic map(
                 N => MEMORYADDRESSBUSWIDTH
              )
   port map(
              EN_in => '1', 
              CLK_in => CamCtrl_ClkOut_i,
              RST_in => '0',
              COUNT_OUT => PixelCounter_Count_i
           );

   Cmp1: Comparator
   generic map(
                 WIDTH_g => MEMORYADDRESSBUSWIDTH
              )
   port map(
              A_in => PixelCounter_Count_i,
              B_in => CONV_STD_LOGIC_VECTOR(640*480/4, MEMORYADDRESSBUSWIDTH), -- 640*480/4 is the number of CamCtrl_ClkOut_i clock cycles per frame
              EQ => open,
              NEQ => open,
              LT => Cmp1_LT_i, -- Used for disabling camera operation
              LTE => open,
              GT => open,
              GTE => open
           );

   CameraInterface: CAM_Ctrl
   port map(
              CLK_IN => CLK100,
              CLK24M_IN => clkfx_24m_i,
              SIOC => CAM_SIOC,
              SIOD => CAM_SIOD,
              VSYNC => CAM_VSYNC,
              HREF => CAM_HREF,
              PCLK => CAM_PCLK,
              DATA => CAM_DATA,
              CAM_EN => Cmp1_LT_i,
              XCLK => CAM_XCLK,
              n_rst => open,
              PWDN => open,
              CLK_OUT => CamCtrl_ClkOut_i,
              D0 => CamCtrl_D0_i,
              D1 => CamCtrl_D1_i,
              D2 => CamCtrl_D2_i,
              D3 => CamCtrl_D3_i,
              D_BUG => D_BUG(3 downto 0)
           );

   U4: DataHold_V2
   port map(
              ARST => DataHold1_Ack,
              CLK100 => CLK100,
              CLK_IN => CamCtrl_ClkOut_i,
              D0 => CamCtrl_D0_i,
              D1 => CamCtrl_D1_i,
              D2 => CamCtrl_D2_i,
              D3 => CamCtrl_D3_i,
              CLK_OUT => DataHold1_ClkOut,
              D_OUT => DataHold1_DOUT_i,
              D_BUG => D_BUG(7 downto 4)
           );

   DataAddressManager: CamDataAddressManager
   generic map(
                 N => MEMORYADDRESSBUSWIDTH
              )
   port map(
             ARST_in => CAM_VSYNC,
             CLK_in => CamCtrl_ClkOut_i,
             ADDRESS_out => MemCtrl_WrAddressIn_i
           );

   MemDataMux: MuxTwoToOne
   generic map(
                 N => 64
              )
   port map(
              A_in => DataHold1_DOUT_i,
              B_in => (others => '0'),
              SELECT_in => '0',
              Y_out => MemCtrl_WrDataIn_i
           );

   U5: MEM_Ctrl 
   port map(
              CLK_IN => CLK100,
              MEM_MT_CRE => MEM_MT_CRE,
              WCLK => DataHold1_ClkOut,
              D_IN => MemCtrl_WrDataIn_i,
              DATA_ACK_out => DataHold1_Ack,
              WADR_RST => CAM_VSYNC,
              ADR_in => MemCtrl_WrAddressIn_i, -- PixelCounter_Count_i 
              RCLK => VGADriver_ClkOut_i,
              ADR_READ => VGADriver_Address_i,
              RCLK_OUT => MemCtrl_ClkOut_i,
              D_OUT => MemCtrl_DOUT_i,
              PCM_CS_L => PCM_CS_L,
              MEM_CS_L => MEM_CS_L,
              MEM_OE_L => MEM_OE_L,
              MEM_WR_L => MEM_WR_L,
              MEM_ADV_L => MEM_ADV_L,
              MEM_CLK_L => MEM_CLK_L,
              MEM_UB_L => MEM_UB_L,
              MEM_LB_L => MEM_LB_L ,
              MEM_ADR => MEM_ADR,
              MEM_DB => MEM_DATA,
              D_BUG => open
           );

--   U6: DataHold
--   port map(
--              ARST_L => '1',
--              CLK100 => CLK100,
--              CLK_IN => MemCtrl_ClkOut_i,
--              D_IN => MemCtrl_DOUT_i,
--              CLK_OUT => DataHold2_ClkOut,
--              D_OUT => DataHold2_DOUT_i,
--              D_BUG => D_BUG(11 downto 8)
--           --D_BUG => open
--           );
--
--   U7: VGADriver
--   port map( 
--              CLK_100M_IN => CLK100,
--              CLK_OUT => VGADriver_ClkOut_i,
--              ADR_READ => VGADriver_Address_i,
--              CLK_IN => DataHold2_ClkOut,
--              D_IN => DataHold2_DOUT_i,
--              RED_OUT => RED_OUT,
--              GREEN_OUT => GREEN_OUT,
--              BLUE_OUT => BLUE_OUT,
--              HS_OUT => HS_OUT,
--              VS_OUT => VS_OUT,
--              VGA_EN => VGA_EN,
--              D_BUG => D_BUG(15 downto 12)
--           );

   U8: MAC_Ctrl
   port map(
              CLK100 => CLK100,
              ETH_RSTN_L => Eth_Rst_L_i,
              ETH_CRS => Eth_Crs_i,
              ETH_MODE0_RXD0 => ETH_MODE0_RXD0,
              ETH_MODE1_RXD1 => ETH_MODE1_RXD1,
              ETH_MODE2_COL => ETH_MODE2_COL,
              ETH_TXD => ETH_TXD,
              ETH_TXEN => ETH_TXEN,
              ETH_TXCLK => Eth_TxClk_i,
              ETH_INT_L_TXER_TX4 => ETH_INT_L_TXER_TX4,
              ETH_AD0_RXER_RXD4 => ETH_AD0_RXER_RXD4,
              ETH_AD1_RXCLK => ETH_AD1_RXCLK,
              ETH_AD2_RXD3 => ETH_AD2_RXD3,
              ETH_RMIISEL_RXD2 => ETH_RMIISEL_RXD2,
              D_BUG => open
           );

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
end Structure;
