---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
entity CRC_Ctrl is
   port(
      CLK_IN : in std_logic;
      COUNT_IN : in INTEGER;
      TXD : out std_logic_vector(3 downto 0) := (others => '0');
      LOADINIT_OUT : out std_logic := '0'; -- Initialize CRC generator
      START_CALC_OUT : out std_logic := '0'; -- Begin Calculating CRC
      DATA_VALID_OUT : out std_logic := '0'; -- Tell CRC generator the data is valid
      CLK_OUT: out std_logic := '0'; -- half the frequency of CLK_IN
      RCLK_OUT : out std_logic := '0'; -- Initiate read commands to memory
      DCLK_OUT : out std_logic := '0'; -- Send data to CRC generator
      DATA_IN : in std_logic_vector(63 downto 0); -- Accept data from memory
      DCLK_IN : in std_logic;
      RST_OUT : out std_logic := '0'); -- Restart CRC generator
end CRC_Ctrl;

---------------------------------------------------------------------------------
architecture Structure of CRC_Ctrl is

	COMPONENT Counter
   GENERIC(
      COUNTMAX : INTEGER
      );
	PORT(
		CLK_IN : IN STD_LOGIC;          
		COUNT_OUT : OUT INTEGER;
		RST_OUT : OUT STD_LOGIC
		);
	END COMPONENT;
   
	COMPONENT TxDataState
	PORT(
		COUNT_IN : IN INTEGER;          
		TXD : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
   
	COMPONENT Comparator
	PORT(
		A_INT_IN : IN INTEGER;
		B_INT_IN : IN INTEGER;          
		GREATER : OUT std_logic;
		LESS : OUT std_logic;
		EQUAL : OUT std_logic
		);
	END COMPONENT;

	COMPONENT CrcLoader
	PORT(
		CLK_IN : IN std_logic;
		COUNT_IN : IN integer;
		DATA_IN : IN std_logic_vector(63 downto 0);
		DCLK_IN : IN std_logic;          
		TXD : OUT std_logic_vector(3 downto 0);
		RCLK_OUT : OUT std_logic;
		RADDR_OUT : OUT std_logic_vector(25 downto 0)
		);
	END COMPONENT;

	COMPONENT CRC
	PORT(
		CLOCK : IN std_logic;
		RESET : IN std_logic;
		DATA : IN std_logic_vector(7 downto 0);
		LOAD_INIT : IN std_logic;
		CALC : IN std_logic;
		D_VALID : IN std_logic;          
		CRC : OUT std_logic_vector(7 downto 0);
		CRC_REG : OUT std_logic_vector(31 downto 0);
		CRC_VALID : OUT std_logic
		);
	END COMPONENT;
   
---------------------------------------------------------------------------------
-- Internal Signals
--
SIGNAL Count_i : INTEGER;
SIGNAL TxD_i : STD_LOGIC_VECTOR(3 downto 0);
   
---------------------------------------------------------------------------------
-- Device Instatiations
--
begin

	Inst_Counter: Counter
      GENERIC MAP(
         COUNTMAX => 153596
      )
      PORT MAP(
         CLK_IN => '1',
         COUNT_OUT => Count_i,
         RST_OUT => open
      );

	Inst_TxDataState: TxDataState
      PORT MAP(
         COUNT_IN => Count_i,
         TXD => open
      );

	Inst_Comparator: Comparator
      PORT MAP(
         A_INT_IN => Count_i,
         B_INT_IN => ETH_IPV4_UDP_PAYLOAD_N2,
         GREATER => open,
         LESS => open,
         EQUAL => open
      );

	Inst_CrcLoader: CrcLoader PORT MAP(
		CLK_IN => CLK_IN,
		COUNT_IN => Count_i,
		TXD => open,
		RCLK_OUT => open,
		RADDR_OUT => open,
		DATA_IN => DATA_IN,
		DCLK_IN => DCLK_IN
	);

	Inst_CRC: CRC PORT MAP(
		CLOCK => CLK_IN,
		RESET => '1',
		DATA => TxD_i,
		LOAD_INIT => '0',
		CALC => '0',
		D_VALID => '0',
		CRC => open,
		CRC_REG => open,
		CRC_VALID => open
	);

end Structure;



