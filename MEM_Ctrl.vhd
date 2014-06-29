--------------------------------------------------------------------------------
-- MEM_Ctrl.vhd (Structure)
--
-- Initializes and operates a Micron M45W8MW16 using 4 word, 150ns write cycles.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
-- Digital Hardware Description
--------------------------------------------------------------------------------
entity MEM_Ctrl is
  port(
        CLK_IN : in std_logic;
        MEM_MT_CRE : out std_logic;
        WCLK : in std_logic;
        WADR_RST : in std_logic;
        ADR_in : in std_logic_vector(25 downto 0);
        D_IN : in std_logic_vector(63 downto 0);
        DATA_ACK_out : out std_logic := '0';
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
        MEM_ADR : out std_logic_vector(26 downto 1)
      );
end MEM_Ctrl;

architecture Structure of MEM_Ctrl is
  ------------------------------------------------------------------------------
  -- Internal Hardware Signals
  ------------------------------------------------------------------------------
  signal InitEnable_i : std_logic;
  signal OperationEnable_i : std_logic;

  signal Init_Cs_l_i   : std_logic;
  signal Op_Cs_l_i     : std_logic;

  signal Init_Wr_l_i   : std_logic;
  signal Op_Wr_l_i     : std_logic;

  signal Init_Adv_l_i  : std_logic;
  signal Op_Adv_l_i    : std_logic;

  signal Init_OE_l_i   : std_logic;
  signal Op_OE_l_i     : std_logic;

  signal Init_Addr_i   : std_logic_vector(26 downto 1);
  signal Op_Addr_i     : std_logic_vector(26 downto 1);

  signal Init_DB_i     : std_logic_vector(15 downto 0);
  signal Op_DB_i       : std_logic_vector(15 downto 0);

   -----------------------------------------------------------------------------
   -- Internal Hardware Components
   -----------------------------------------------------------------------------
  component Timer150000 is
    port(
          CLK_IN : in std_logic;
          ARST   : in std_logic;
          OUT_EN : out std_logic
        );
  end component;

  component MemInit
    port(
          CE : in std_logic;
          CLK_IN : in std_logic;
          MEM_CS_L : out std_logic;
          MEM_ADR : out std_logic_vector(25 downto 0);
          MEM_ADV_L : out std_logic;
          MEM_OE_L : out std_logic;
          MEM_WR_L : out std_logic;
          MEM_UB_L : out std_logic;
          MEM_LB_L : out std_logic;
          MEM_CRE : out std_logic;
          DONE_out : out std_logic;
          D_BUG : out std_logic_vector(15 downto 0)
        );
  end component;

  component MemOperation is
    port(
          CLK_IN : in std_logic;
          CE : in std_logic;
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

--------------------------------------------------------------------------------
-- Internal Signal Assignments
--------------------------------------------------------------------------------
begin
  MEM_CS_L <= Init_Cs_l_i when (OperationEnable_i = '0') else Op_Cs_l_i;
  MEM_ADR <= Init_Addr_i when (OperationEnable_i = '0') else Op_Addr_i;
  MEM_ADV_L <= Init_Adv_l_i when (OperationEnable_i = '0') else Op_Adv_l_i;
  MEM_WR_L <= Init_Wr_l_i when (OperationEnable_i = '0') else Op_Wr_l_i;
  MEM_OE_L <= Init_OE_l_i when (OperationEnable_i = '0') else Op_OE_l_i;

--------------------------------------------------------------------------------
-- Internal Hardware Assignments
--------------------------------------------------------------------------------
  U1: Timer150000
  port map(
            CLK_IN => CLK_IN,
            ARST => '0',
            OUT_EN => InitEnable_i
          );

  U2: MemInit
  port map(
            CE => InitEnable_i,
            CLK_IN => CLK_IN,
            MEM_ADR => Init_Addr_i,
            MEM_CS_L => Init_Cs_l_i,
            MEM_ADV_L => Init_Adv_l_i,
            MEM_OE_L => Init_OE_l_i,
            MEM_WR_L => Init_Wr_l_i,
            MEM_UB_L => MEM_UB_L,
            MEM_LB_L => MEM_LB_L,
            MEM_CRE => MEM_MT_CRE,
            DONE_out => OperationEnable_i,
            D_BUG => open
          );

  U3: MemOperation
  port map(
            CE => OperationEnable_i,
            CLK_IN => CLK_IN,
            WCLK => WCLK,
            WADR_RST => WADR_RST,
            ADR_in => ADR_in,
            D_IN => D_IN,
            DATA_ACK_out => open,
            RCLK => RCLK,
            ADR_READ => ADR_READ,
            D_OUT => D_OUT,
            RCLK_OUT => RCLK_OUT,
            PCM_CS_L => PCM_CS_L,
            MEM_CS_L => Op_Cs_l_i,
            MEM_OE_L => Op_OE_l_i,
            MEM_WR_L => Op_Wr_l_i,
            MEM_ADV_L => Op_Adv_l_i,
            MEM_CLK_L => MEM_CLK_L,
            MEM_UB_L => MEM_UB_L ,
            MEM_LB_L => MEM_LB_L,
            MEM_ADR => Op_Addr_i,
            MEM_DB => MEM_DB,
            D_BUG(3 downto 0) => D_BUG(3 downto 0)
          );
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Structure;

