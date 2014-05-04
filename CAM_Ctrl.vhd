--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity CAM_Ctrl is port(
		CLK_IN : in STD_LOGIC;
      CLK24M_IN : in STD_LOGIC;
		SIOC : out STD_LOGIC;
		SIOD : out STD_LOGIC;
		VSYNC : in STD_LOGIC;
		HREF : in STD_LOGIC;
		PCLK : in STD_LOGIC;
		DATA : in STD_LOGIC_VECTOR(7 downto 0);
		CAM_EN : in STD_LOGIC;          
		D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
		XCLK : out STD_LOGIC;
		ARST_L : out STD_LOGIC;
		PWDN : out STD_LOGIC;
		CLK_OUT : out STD_LOGIC;
		D0 : out STD_LOGIC_VECTOR(7 downto 0);
		D1 : out STD_LOGIC_VECTOR(7 downto 0);
		D2 : out STD_LOGIC_VECTOR(7 downto 0);
		D3 : out STD_LOGIC_VECTOR(7 downto 0)
		);
end CAM_Ctrl;
--------------------------------------------------------------------------------
-- Internal Hardware Signals
--------------------------------------------------------------------------------
architecture Structure of CAM_Ctrl is
   signal InitEnable_i : STD_LOGIC;
   signal OpEnable_i : STD_LOGIC;

--------------------------------------------------------------------------------
-- Internal Hardware Components
--------------------------------------------------------------------------------=
component Timer150000 is port(
      CLK_IN : in STD_LOGIC;
      ARST   : in STD_LOGIC;
      OUT_EN : out STD_LOGIC
      );
   end component;
   
component CamInit is port(
      CLK_IN : in STD_LOGIC;
      CE : in STD_LOGIC;
      SIOC : out STD_LOGIC;
      SIOD : out STD_LOGIC;
      CE_OUT : out STD_LOGIC;
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0)
      );
   end component;

component CamOperation is port(
      CLK100M_IN : in STD_LOGIC;
      CLK24M_IN : in STD_LOGIC;
      CE : in STD_LOGIC;
      VSYNC : in STD_LOGIC;
      HREF : in STD_LOGIC;
      PCLK : in STD_LOGIC;
      DATA : in STD_LOGIC_VECTOR(7 downto 0);
      CAM_EN : in STD_LOGIC;          
      D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
      XCLK : out STD_LOGIC;
      ARST_L : out STD_LOGIC;
      PWDN : out STD_LOGIC;
      CLK_OUT : out STD_LOGIC;
      D0 : out STD_LOGIC_VECTOR(7 downto 0);
      D1 : out STD_LOGIC_VECTOR(7 downto 0);
      D2 : out STD_LOGIC_VECTOR(7 downto 0);
      D3 : out STD_LOGIC_VECTOR(7 downto 0)
      );
   end component;
--------------------------------------------------------------------------------
-- Internal Signal Assignments
--------------------------------------------------------------------------------
begin

--------------------------------------------------------------------------------
-- Internal Hardware Assignments
--------------------------------------------------------------------------------
U1: Timer150000 port map(
      CLK_IN => CLK_IN,
      ARST => '0',
      OUT_EN => InitEnable_i
      );

U2: CamInit port map(
      CLK_IN => CLK_IN,
      CE => InitEnable_i,
      SIOC => SIOC,
      SIOD => SIOD,
      CE_OUT => OpEnable_i,
      D_BUG => open
      );

U3: CamOperation port map(
		CLK100M_IN => CLK_IN,
      CLK24M_IN => CLK24M_IN,
      CE => OpEnable_i,
		VSYNC => VSYNC,
		HREF => HREF,
		PCLK => PCLK,
		DATA => DATA,
		XCLK => XCLK,
		ARST_L => ARST_L,
		PWDN => PWDN,
		CLK_OUT => CLK_OUT,
		D0 => D0,
		D1 => D1,
		D2 => D2,
		D3 => D3,
		CAM_EN => CAM_EN,
		D_BUG => D_BUG
	);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Structure;

