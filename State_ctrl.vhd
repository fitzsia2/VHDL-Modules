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
   component DataFF is
      port(
             PRESET_in : in std_logic;
             CLEAR_in : in std_logic;
             CLK_in : in std_logic;
             D_in : in std_logic;
             Q_out : out std_logic := '0';
             n_Q_out : out std_logic := '1'
          );
   end component;

--------------------------------------------------------------------------------
-- Internal Signal Assignments
--------------------------------------------------------------------------------
begin
   OUTPUT1_out <= CameraEnable_i;
   CameraFrameDone_i <= INPUT1_in;


--------------------------------------------------------------------------------
-- Internal Hardware Assignments
--------------------------------------------------------------------------------
state_1: DataFF
port map(
          PRESET_in => '0',
          CLEAR_in => '0',
          CLK_in => CameraFrameDone_i,
          D_in => '1',
          Q_out => CameraEnable_i,
          n_Q_out => open
         );


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
               end Structure;

