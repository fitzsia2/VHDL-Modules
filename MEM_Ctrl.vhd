---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
-- Digital Hardware Description
---------------------------------------------------------------------------------
entity MEM_Ctrl is
	PORT(
		CLK_IN : in STD_LOGIC;
      MEM_MT_CRE : out STD_LOGIC;
		WCLK : in STD_LOGIC;
		WADR_RST : in STD_LOGIC;
		D_IN : in STD_LOGIC_VECTOR(63 downto 0);
		RCLK : in STD_LOGIC;
		ADR_READ : in STD_LOGIC_VECTOR(25 downto 0);    
		MEM_DB : inout STD_LOGIC_VECTOR(15 downto 0);      
		D_OUT : out STD_LOGIC_VECTOR(15 downto 0);
		RCLK_OUT : out STD_LOGIC;
		D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
		PCM_CS_L : out STD_LOGIC;
		MEM_CS_L : out STD_LOGIC;
		MEM_OE_L : out STD_LOGIC;
		MEM_WR_L : out STD_LOGIC;
		MEM_ADV_L : out STD_LOGIC;
		MEM_CLK_L : out STD_LOGIC;
		MEM_UB_L : out STD_LOGIC;
		MEM_LB_L : out STD_LOGIC;
		MEM_ADR : out STD_LOGIC_VECTOR(26 downto 1)
		);
end MEM_Ctrl;
---------------------------------------------------------------------------------
-- Internal Hardware Signals
---------------------------------------------------------------------------------
architecture Structure of MEM_Ctrl is
   signal InitEnable_i : STD_LOGIC;
   signal OperationEnable_i : STD_LOGIC;
   
   signal Init_Cs_l_i   : STD_LOGIC;
   signal Op_Cs_l_i     : STD_LOGIC;
   
   signal Init_Wr_l_i   : STD_LOGIC;
   signal Op_Wr_l_i     : STD_LOGIC;
   
   signal Init_Adv_l_i  : STD_LOGIC;
   signal Op_Adv_l_i    : STD_LOGIC;
   
   signal Init_OE_l_i   : STD_LOGIC;
   signal Op_OE_l_i     : STD_LOGIC;
   
   signal Init_Addr_i   : STD_LOGIC_VECTOR(26 downto 1);
   signal Op_Addr_i     : STD_LOGIC_VECTOR(26 downto 1);
   
   signal Init_DB_i     : STD_LOGIC_VECTOR(15 downto 0);
   signal Op_DB_i       : STD_LOGIC_VECTOR(15 downto 0);

---------------------------------------------------------------------------------
-- Internal Hardware Components
---------------------------------------------------------------------------------
   component Timer150000 is port(
      CLK_IN : in STD_LOGIC;
      ARST   : in STD_LOGIC;
      OUT_EN : out STD_LOGIC
      );
   end component;
   
	COMPONENT MemInit
	PORT(
		CE : IN std_logic;
		CLK_IN : IN std_logic;
      MEM_CS_L : OUT std_logic;
		MEM_ADR : OUT std_logic_vector(25 downto 0);
		MEM_ADV_L : OUT std_logic;
		MEM_OE_L : OUT std_logic;
		MEM_WR_L : OUT std_logic;
		MEM_UB_L : OUT std_logic;
		MEM_LB_L : OUT std_logic;
		MEM_CRE : OUT std_logic;
		OUT_EN : OUT std_logic;
      D_BUG : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
   
   component MemOperation is port(
      CLK_IN   : in STD_LOGIC;
      CE       : in STD_LOGIC;
      WCLK     : in STD_LOGIC;
      WADR_RST : in STD_LOGIC;
      D_IN     : in STD_LOGIC_VECTOR(63 downto 0);
      RCLK     : in STD_LOGIC;
      ADR_READ : in STD_LOGIC_VECTOR(25 downto 0);    
      MEM_DB   : inout STD_LOGIC_VECTOR(15 downto 0);      
      D_OUT    : out STD_LOGIC_VECTOR(15 downto 0);
      RCLK_OUT : out STD_LOGIC;
      D_BUG    : out STD_LOGIC_VECTOR(3 downto 0);
      PCM_CS_L : out STD_LOGIC;
      MEM_CS_L : out STD_LOGIC;
      MEM_OE_L : out STD_LOGIC;
      MEM_WR_L : out STD_LOGIC;
      MEM_ADV_L : out STD_LOGIC;
      MEM_CLK_L : out STD_LOGIC;
      MEM_UB_L : out STD_LOGIC;
      MEM_LB_L : out STD_LOGIC;
      MEM_ADR  : out STD_LOGIC_VECTOR(25 downto 0)
      );
   end component;

---------------------------------------------------------------------------------
-- Internal Signal Assignments
---------------------------------------------------------------------------------
begin
   MEM_CS_L <= Init_Cs_l_i WHEN (OperationEnable_i = '0') ELSE Op_Cs_l_i;
   MEM_ADR <= Init_Addr_i WHEN (OperationEnable_i = '0') ELSE Op_Addr_i;
   MEM_ADV_L <= Init_Adv_l_i WHEN (OperationEnable_i = '0') ELSE Op_Adv_l_i;
   MEM_WR_L <= Init_Wr_l_i WHEN (OperationEnable_i = '0') ELSE Op_Wr_l_i;
   MEM_OE_L <= Init_OE_l_i WHEN (OperationEnable_i = '0') ELSE Op_OE_l_i;

---------------------------------------------------------------------------------
-- Internal Hardware Assignments
---------------------------------------------------------------------------------
U1: Timer150000 PORT MAP(
      CLK_IN => CLK_IN,
      ARST => '0',
      OUT_EN => InitEnable_i
   );
   
U2: MemInit PORT MAP(
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
		OUT_EN => OperationEnable_i,
      D_BUG => open
	);
   
U3: MemOperation PORT MAP(
      CE => OperationEnable_i,
		CLK_IN => CLK_IN,
		WCLK => WCLK,
		WADR_RST => WADR_RST,
		D_IN => D_IN,
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
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
end Structure;

