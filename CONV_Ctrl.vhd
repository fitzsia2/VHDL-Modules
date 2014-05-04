---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity CONV_Ctrl is port(
		CLK_IN : in STD_LOGIC;
		CE : in STD_LOGIC;
		VSYNC : in STD_LOGIC;
		HREF : in STD_LOGIC;
		PCLK : in STD_LOGIC;
		DATA : in STD_LOGIC_VECTOR(7 downto 0);
		CAM_EN : in STD_LOGIC;          
		D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
		SIOC : out STD_LOGIC;
		SIOD : out STD_LOGIC;
		XCLK : out STD_LOGIC;
		ARST_L : out STD_LOGIC;
		PWDN : out STD_LOGIC;
		CLK_OUT : out STD_LOGIC;
		Y0 : out STD_LOGIC_VECTOR(7 downto 0);
		Y1 : out STD_LOGIC_VECTOR(7 downto 0);
		CB : out STD_LOGIC_VECTOR(7 downto 0);
		CR : out STD_LOGIC_VECTOR(7 downto 0)
		);
end CONV_Ctrl;

architecture Structure of CONV_Ctrl is

begin


end Structure;

