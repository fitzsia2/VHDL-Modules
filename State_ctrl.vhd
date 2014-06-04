--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity SystemState is
port(
    CLK24M_IN : in std_logic;
    SRST : in std_logic;
    RST_OUT : out std_logic := '0';
    INPUT1 : in std_logic;
    OUTPUT1 : out std_logic := '0';
);
end CAM_Ctrl;
--------------------------------------------------------------------------------
-- Internal Hardware Signals
--------------------------------------------------------------------------------
architecture Structure of CAM_Ctrl is
    signal CameraEnable_i : std_logic := '0';
    signal CameraFrameDone_i : std_logic := '0';

--------------------------------------------------------------------------------
-- Internal Hardware Components
--------------------------------------------------------------------------------
    component DataFF is port (
        CLK : in std_logic;
        SRST : in std_logic;
        SET : in std_logic;
        Q : out std_logic;
        Q_NOT : out std_logic);
    end component;

--------------------------------------------------------------------------------
-- Internal Signal Assignments
--------------------------------------------------------------------------------
begin
    OUTPUT1 <= CameraEnable_i
    CameraFrameDone_i <= INPUT1;


--------------------------------------------------------------------------------
-- Internal Hardware Assignments
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Structure;

