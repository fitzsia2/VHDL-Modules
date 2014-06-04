---------------------------------------------------------------------------------
-- VideoAcquisition.vhd
--
-- Operates the camera module and reports when one entire frame has been received
--   and stored
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------
entity VideoAcquisition is
  port(
        CLK100 : in std_logic;
        D_BUG : out std_logic_vector(15 downto 0) := (others => '0');
        -- Camera Signals
        CAM_EN : in std_logic; -- Enables XCLK
        CAM_SIOC : out std_logic := '0'; -- Serial comm clock
        CAM_SIOD : out std_logic := '0'; -- Serial data clock
        CAM_VSYNC : in std_logic; -- Vertical sync
        CAM_HREF : in std_logic; -- Horizontal sync
        CAM_PCLK : in std_logic; -- Store CAM_DATA on rising edge
        CAM_DATA : in std_logic_vector (7 downto 0); -- Data from camera
        CAM_XCLK : out std_logic := '0'; -- Provide camera with external clock
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
end VideoAcquisition;

architecture Structure of VideoCam is
  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Component Declarations
  ------------------------------------------------------------------------------
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

