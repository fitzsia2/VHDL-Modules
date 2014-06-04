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
    CLK_in : in std_logic;
    SRST_in : in std_logic;
    RST_out : out std_logic := '0';
    INPUT1_in : in std_logic;
    OUTPUT1_out : out std_logic := '0'
);
end SystemState;
--------------------------------------------------------------------------------
-- Internal Hardware Signals
--------------------------------------------------------------------------------
architecture Structure of SystemState is
    signal CameraEnable_i : std_logic := '0';
    signal CameraFrameDone_i : std_logic := '0';

--------------------------------------------------------------------------------
-- Internal Hardware Components
--------------------------------------------------------------------------------
    component DataFF is port (
       CLK_in : in std_logic;
       DATA_in : in std_logic;
       n_SRST_in : in std_logic;
       SET_in : in std_logic;
       Q_out : out std_logic;
       n_Q_out : out std_logic);
    end component;

--------------------------------------------------------------------------------
-- Internal Signal Assignments
--------------------------------------------------------------------------------
begin
    OUTPUT1_out <= CameraEnable_i,
    CameraFrameDone_i <= INPUT1_in;


--------------------------------------------------------------------------------
-- Internal Hardware Assignments
--------------------------------------------------------------------------------
state_1: DataFF
   port map(
      CLK_in => CLK_in,
      DATA_in => CameraFrameDone_i,
      n_SRST_in => '1',
      SET_in => '0',
      Q_out => open,
      n_Q_out => open);
      

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Structure;

