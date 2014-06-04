--------------------------------------------------------------------------------
-- CAM_Ctrl (Structure)
--
-- Author: Andrew Fitzsimons
--
-- Used for initializing and operating an OV7670 digital camera
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity CAM_Ctrl is
  port(
        CLK_IN : in std_logic;
        CLK24M_IN : in std_logic;
        SIOC : out std_logic;
        SIOD : out std_logic;
        VSYNC : in std_logic;
        HREF : in std_logic;
        PCLK : in std_logic;
        DATA : in std_logic_vector(7 downto 0);
        CAM_EN : in std_logic;          
        D_BUG : out std_logic_vector(3 downto 0);
        XCLK : out std_logic;
        n_rst : out std_logic;
        PWDN : out std_logic;
        CLK_OUT : out std_logic;
        D0 : out std_logic_vector(7 downto 0);
        D1 : out std_logic_vector(7 downto 0);
        D2 : out std_logic_vector(7 downto 0);
        D3 : out std_logic_vector(7 downto 0));
end CAM_Ctrl;
--------------------------------------------------------------------------------
-- Internal Hardware Signals
--------------------------------------------------------------------------------
architecture Structure of CAM_Ctrl is
  signal InitEnable_i : std_logic;
  signal OpEnable_i : std_logic;

--------------------------------------------------------------------------------
-- Internal Hardware Components
--------------------------------------------------------------------------------=
  component Timer150000 is
    port(
          CLK_IN : in std_logic;
          ARST : in std_logic;
          OUT_EN : out std_logic
        );
  end component;

  component CamInit is
    port(
          CLK_IN : in std_logic;
          CE : in std_logic;
          SIOC : out std_logic;
          SIOD : out std_logic;
          DONE_o : out std_logic;
          D_BUG : out std_logic_vector(3 downto 0)
        );
  end component;

  component CamOperation is
    port(
          CLK100M_IN : in std_logic;
          CLK24M_IN : in std_logic;
          CE : in std_logic;
          VSYNC : in std_logic;
          HREF : in std_logic;
          PCLK : in std_logic;
          DATA : in std_logic_vector(7 downto 0);
          CAM_EN : in std_logic;          
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
--------------------------------------------------------------------------------
-- Internal Signal Assignments
--------------------------------------------------------------------------------
begin

--------------------------------------------------------------------------------
-- Internal Hardware Assignments
--------------------------------------------------------------------------------
  U1: Timer150000
  port map(
            CLK_IN => CLK_IN,
            ARST => '0',
            OUT_EN => InitEnable_i
          );

  U2: CamInit
  port map(
            CLK_IN => CLK_IN,
            CE => InitEnable_i,
            SIOC => SIOC,
            SIOD => SIOD,
            DONE_o => OpEnable_i,
            D_BUG => open
          );

  U3: CamOperation
  port map(
            CLK100M_IN => CLK_IN,
            CLK24M_IN => CLK24M_IN,
            CE => OpEnable_i,
            VSYNC => VSYNC,
            HREF => HREF,
            PCLK => PCLK,
            DATA => DATA,
            XCLK => XCLK,
            n_rst => n_rst,
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

