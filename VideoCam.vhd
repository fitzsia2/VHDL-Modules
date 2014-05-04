---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------
entity VideoCam is port (
   CLK100    : in  STD_LOGIC;
   CAM_EN    : in STD_LOGIC;
   VGA_EN    : in STD_LOGIC;
   D_BUG     : out STD_LOGIC_VECTOR(15 downto 0);
   -- Camera Signals
   CAM_SIOC  : out STD_LOGIC;
   CAM_SIOD  : out STD_LOGIC;
   CAM_VSYNC : in  STD_LOGIC;
   CAM_HREF  : in  STD_LOGIC;
   CAM_PCLK  : in  STD_LOGIC;
   CAM_DATA  : in  STD_LOGIC_VECTOR (7 downto 0);
   CAM_XCLK  : out  STD_LOGIC;
   -- Memory Signals
   MEM_MT_CRE: out STD_LOGIC;
   MEM_DATA  : inout  STD_LOGIC_VECTOR (15 downto 0);
   MEM_ADR   : out  STD_LOGIC_VECTOR (25 downto 0);
   PCM_CS_L  : out  STD_LOGIC;
   MEM_CS_L  : out  STD_LOGIC;
   MEM_OE_L  : out  STD_LOGIC;
   MEM_WR_L  : out  STD_LOGIC;
   MEM_ADV_L : out  STD_LOGIC;
   MEM_CLK_L : out  STD_LOGIC;
   MEM_UB_L  : out  STD_LOGIC;
   MEM_LB_L  : out  STD_LOGIC;
   -- VGA Signals
   RED_OUT   : out STD_LOGIC_VECTOR(2 downto 0);
   GREEN_OUT : out STD_LOGIC_VECTOR(2 downto 0);
   BLUE_OUT  : out STD_LOGIC_VECTOR(2 downto 1);
   HS_OUT    : out STD_LOGIC;
   VS_OUT    : out STD_LOGIC;
   -- Ethernet Signals
   ETH_TXCLK : IN std_logic;          
   ETH_RSTN_L : OUT std_logic;
   ETH_MODE0_RXD0 : OUT std_logic;
   ETH_CRS : INOUT std_logic;
   ETH_MODE1_RXD1 : OUT std_logic;
   ETH_MODE2_COL : OUT std_logic;
   ETH_TXD : OUT std_logic_vector(3 downto 0);
   ETH_TXEN : OUT std_logic;
   ETH_INT_L_TXER_TX4 : OUT std_logic;
   ETH_AD0_RXER_RXD4 : OUT std_logic;
   ETH_AD1_RXCLK : OUT std_logic;
   ETH_AD2_RXD3 : OUT std_logic;
   ETH_RMIISEL_RXD2 : OUT std_logic;
   -- LED Signals
   LED_ARRAY_L : OUT std_logic_vector(7 downto 0)
   );
end VideoCam;

architecture Structure of VideoCam is
---------------------------------------------------------------------------------
-- Signal Declarations

   signal Clk_20_i  : STD_LOGIC;
   
   -- DCM Signals
   signal clkfx_24m_i : STD_LOGIC; -- Camera Clock
   signal clkfx180_i : STD_LOGIC;
   signal freezedcm_i : STD_LOGIC := '0';
   signal progclk_i : STD_LOGIC := '0';
   signal progdata_i : STD_LOGIC := '0';
   signal progen_i : STD_LOGIC := '0';
   signal rst_i : STD_LOGIC := '0';
   
   -- CamCtrl To YCbCrToRGB332
   signal CamCtrl_ClkOut_i :STD_LOGIC;
   signal CamCtrl_D0_i :STD_LOGIC_VECTOR(7 downto 0);
   signal CamCtrl_D1_i :STD_LOGIC_VECTOR(7 downto 0);
   signal CamCtrl_D2_i :STD_LOGIC_VECTOR(7 downto 0);
   signal CamCtrl_D3_i :STD_LOGIC_VECTOR(7 downto 0);
   
   -- YCbCrToRGB332 to DataHold1
   signal RGB332_Data_i :STD_LOGIC_VECTOR(15 downto 0);
   signal RGB332_ClkOut_i :STD_LOGIC;
   
   --DataHold1 To MemCtrl
   signal DataHold1_Ack_L :STD_LOGIC;
   signal DataHold1_ClkOut :STD_LOGIC;
   signal DataHold1_DOUT_i :STD_LOGIC_VECTOR(63 downto 0);

   --MemCtrl To DataHold2
   signal MemCtrl_ClkOut_i : STD_LOGIC;
   signal MemCtrl_DOUT_i :STD_LOGIC_VECTOR(15 downto 0);
   
   -- DataHold2 To VGADriver
   signal DataHold2_Ack_L :STD_LOGIC;
   signal DataHold2_ClkOut :STD_LOGIC;
   signal DataHold2_DOUT_i :STD_LOGIC_VECTOR(63 downto 0);
   
   -- VGADriver To MemCtrl
   signal VGADriver_ClkOut_i :STD_LOGIC;
   signal VGADriver_Address_i :STD_LOGIC_VECTOR(25 downto 0);
   
   -- Ethernet
   signal Eth_Rst_L_i : STD_LOGIC;
   signal Eth_TxClk_i : STD_LOGIC;
   signal Eth_Crs_i : STD_LOGIC;

---------------------------------------------------------------------------------
-- Component Declarations
---------------------------------------------------------------------------------
	COMPONENT CAM_Ctrl
	PORT(
		CLK_IN : IN std_logic;
      CLK24M_IN : IN std_logic;
		VSYNC : IN std_logic;
		HREF : IN std_logic;
		PCLK : IN std_logic;
		DATA : IN std_logic_vector(7 downto 0);
		CAM_EN : IN std_logic;          
		SIOC : OUT std_logic;
		SIOD : OUT std_logic;
		D_BUG : OUT std_logic_vector(3 downto 0);
		XCLK : OUT std_logic;
		ARST_L : OUT std_logic;
		PWDN : OUT std_logic;
		CLK_OUT : OUT std_logic;
		D0 : OUT std_logic_vector(7 downto 0);
		D1 : OUT std_logic_vector(7 downto 0);
		D2 : OUT std_logic_vector(7 downto 0);
		D3 : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
   
   component DataHold_V2 is port(
      ARST : in STD_LOGIC;
      CLK100 : in STD_LOGIC;
      CLK_IN : in STD_LOGIC;
      D0 : in STD_LOGIC_VECTOR(7 downto 0);
      D1 : in STD_LOGIC_VECTOR(7 downto 0);
      D2 : in STD_LOGIC_VECTOR(7 downto 0);
      D3 : in STD_LOGIC_VECTOR(7 downto 0);
      CLK_OUT : out STD_LOGIC;
      D_OUT : out STD_LOGIC_VECTOR(63 downto 0);
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0)
      );
   end component;
   
   component YcbCrToRGB332 is port(
      CLK100		: in  STD_LOGIC;
      CLK_IN      : in STD_LOGIC;
      Y0          : in STD_LOGIC_VECTOR(7 downto 0);
      Y1          : in STD_LOGIC_VECTOR(7 downto 0);
      CB          : in STD_LOGIC_VECTOR(7 downto 0);
      CR          : in STD_LOGIC_VECTOR(7 downto 0);
      CLK_OUT     : out STD_LOGIC;
      DATA        : out STD_LOGIC_VECTOR(15 downto 0);
      D_BUG       : out STD_LOGIC_VECTOR(3 downto 0)
      );
   end component;
   
	COMPONENT MEM_CTRL
	PORT(
		CLK_IN : IN std_logic;
      MEM_MT_CRE : OUT std_logic;
		WCLK : IN std_logic;
		WADR_RST : IN std_logic;
		D_IN : IN std_logic_vector(63 downto 0);
		RCLK : IN std_logic;
		ADR_READ : IN std_logic_vector(25 downto 0);    
		MEM_DB : INOUT std_logic_vector(15 downto 0);      
		D_OUT : OUT std_logic_vector(15 downto 0);
		RCLK_OUT : OUT std_logic;
		D_BUG : OUT std_logic_vector(3 downto 0);
		PCM_CS_L : OUT std_logic;
		MEM_CS_L : OUT std_logic;
		MEM_OE_L : OUT std_logic;
		MEM_WR_L : OUT std_logic;
		MEM_ADV_L : OUT std_logic;
		MEM_CLK_L : OUT std_logic;
		MEM_UB_L : OUT std_logic;
		MEM_LB_L : OUT std_logic;
		MEM_ADR : OUT std_logic_vector(25 downto 0)
		);
	END COMPONENT;
   
   component DataHold is port(
      ARST_L : in STD_LOGIC;
      CLK100 : in STD_LOGIC;
      CLK_IN : in STD_LOGIC;
      D_IN : in STD_LOGIC_VECTOR(15 downto 0);
      CLK_OUT : out STD_LOGIC;
      D_OUT : out STD_LOGIC_VECTOR(63 downto 0);
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0)
      );
   end component;
   
   component VGADriver is port(
      CLK_100M_IN : in STD_LOGIC;
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
      CLK_OUT : out STD_LOGIC;
      ADR_READ : out STD_LOGIC_VECTOR(25 downto 0);
      CLK_IN : in STD_LOGIC;
      D_IN : in STD_LOGIC_VECTOR(63 downto 0);
      RED_OUT : out STD_LOGIC_VECTOR(2 downto 0);
      GREEN_OUT : out STD_LOGIC_VECTOR(2 downto 0);
      BLUE_OUT : out STD_LOGIC_VECTOR(1 downto 0);
      HS_OUT : out STD_LOGIC;
      VS_OUT : out STD_LOGIC;
      VGA_EN : in STD_LOGIC
      );
   end component;
   
	COMPONENT MAC_Ctrl
	PORT(
		CLK100 : IN std_logic;
      ETH_CRS : INOUT std_logic;
		ETH_TXCLK : IN std_logic;          
		ETH_RSTN_L : OUT std_logic;
		ETH_MODE0_RXD0 : OUT std_logic;
		ETH_MODE1_RXD1 : OUT std_logic;
		ETH_MODE2_COL : OUT std_logic;
		ETH_TXD : OUT std_logic_vector(3 downto 0);
		ETH_TXEN : OUT std_logic;
		ETH_INT_L_TXER_TX4 : OUT std_logic;
		ETH_AD0_RXER_RXD4 : OUT std_logic;
		ETH_AD1_RXCLK : OUT std_logic;
		ETH_AD2_RXD3 : OUT std_logic;
		ETH_RMIISEL_RXD2 : OUT std_logic;
		D_BUG : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
   
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Signal Assignments
Begin
--   D_BUG(8) <= clkfx_i;
--   D_BUG(9) <= clkfx180_i;
--   D_BUG(10) <= '1';
--   D_BUG(11) <= '1';
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
   generic map (
      CLKFXDV_DIVIDE => 2,       -- CLKFXDV divide value (2, 4, 8, 16, 32)
      CLKFX_DIVIDE => 50,         -- Divide value - D - (1-256)
      CLKFX_MD_MAX => 0.12,       -- Specify maximum M/D ratio for timing anlysis
      CLKFX_MULTIPLY => 6,       -- Multiply value - M - (2-256)
      CLKIN_PERIOD => 10.00,       -- Input clock period specified in nS
      SPREAD_SPECTRUM => "NONE", -- Spread Spectrum mode "NONE", "CENTER_LOW_SPREAD", "CENTER_HIGH_SPREAD",
                                 -- "VIDEO_LINK_M0", "VIDEO_LINK_M1" or "VIDEO_LINK_M2" 
      STARTUP_WAIT => FALSE      -- Delay config DONE until DCM_CLKGEN LOCKED (TRUE/FALSE)
   )
   port map (
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
U1: CAM_Ctrl
   port map( CLK_IN => CLK100,
             CLK24M_IN => clkfx_24m_i,
             SIOC => CAM_SIOC,
             SIOD => CAM_SIOD,
             VSYNC => CAM_VSYNC,
             HREF => CAM_HREF,
             PCLK => CAM_PCLK,
             DATA => CAM_DATA,
             CAM_EN => CAM_EN,
             XCLK => CAM_XCLK,
             ARST_L => open,
             PWDN => open,
             CLK_OUT => CamCtrl_ClkOut_i,
             D0 => CamCtrl_D0_i,
             D1 => CamCtrl_D1_i,
             D2 => CamCtrl_D2_i,
             D3 => CamCtrl_D3_i,
             D_BUG => D_BUG(3 downto 0)
             );
      
U3: DataHold_V2
   port map( ARST => CAM_VSYNC,
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

U4: MEM_Ctrl 
   PORT MAP( CLK_IN => CLK100,
             MEM_MT_CRE => MEM_MT_CRE,
             WCLK => DataHold1_ClkOut,
             D_IN => DataHold1_DOUT_i,
             WADR_RST => CAM_VSYNC,
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
      
U5: DataHold
   port map( ARST_L => '1',
             CLK100 => CLK100,
             CLK_IN => MemCtrl_ClkOut_i,
             D_IN => MemCtrl_DOUT_i,
             CLK_OUT => DataHold2_ClkOut,
             D_OUT => DataHold2_DOUT_i,
             D_BUG => D_BUG(11 downto 8)
--             D_BUG => open
             );

U6: VGADriver
   port map( 
	CLK_100M_IN => CLK100,
	CLK_OUT => VGADriver_ClkOut_i,
	ADR_READ => VGADriver_Address_i,
	CLK_IN => DataHold2_ClkOut,
	D_IN => DataHold2_DOUT_i,
	RED_OUT => RED_OUT,
	GREEN_OUT => GREEN_OUT,
	BLUE_OUT => BLUE_OUT,
	HS_OUT => HS_OUT,
	VS_OUT => VS_OUT,
	VGA_EN => VGA_EN,
	D_BUG => D_BUG(15 downto 12)
	);

Inst_MAC_Ctrl: MAC_Ctrl PORT MAP(
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
