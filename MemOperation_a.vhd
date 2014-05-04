---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity MemOperation is
	port(
		CLK_IN      : in  STD_LOGIC;
      CE          : in STD_LOGIC;
      WCLK        : in STD_LOGIC;
      WADR_RST    : in STD_LOGIC;
      D_IN        : in STD_LOGIC_VECTOR(63 downto 0);
      RCLK        : in STD_LOGIC;
      ADR_READ    : in STD_LOGIC_VECTOR(26 downto 1);
      D_OUT       : out STD_LOGIC_VECTOR(15 downto 0);
      RCLK_OUT    : OUT STD_LOGIC;
      D_BUG       : out STD_LOGIC_VECTOR(3 downto 0);
      
   -- CELLULAR MEMORY PORTS
		PCM_CS_L    : out STD_LOGIC := '1'; --Disable PCM Device
		MEM_CS_L    : out STD_LOGIC;	-- Cellular RAM Chip Select
      MEM_OE_L    : out STD_LOGIC;  -- Cellular Ram Output EN
		MEM_WR_L    : out STD_LOGIC;	-- Cellular Write EN
		MEM_ADV_L   : out STD_LOGIC;	-- Mem Address Valid Pin
   	MEM_CLK_L   : out STD_LOGIC;	-- Mem CLK
      MEM_UB_L    : out STD_LOGIC; 
      MEM_LB_L    : out STD_LOGIC;
		MEM_ADR     : out STD_LOGIC_VECTOR(26 downto 1);
		MEM_DB      : inout STD_LOGIC_VECTOR(15 downto 0));
end MemOperation;
---------------------------------------------------------------------------------
architecture Behavioral of MemOperation is
	TYPE STATE_TYPE is (S_READ0, S_READ1, S_READ2, S_READ3, S_READ4,
                       S_READ5, S_READ6, S_READ7, S_READ8, S_READ9,
                       S_READ10, S_READ11, S_READ12, S_READ13, S_READ14,
                       S_READ15,
                       S_WRITE0, S_WRITE1, S_WRITE2, S_WRITE3, S_WRITE4,
                       S_WRITE5, S_WRITE6, S_WRITE7, S_WRITE8, S_WRITE9,
                       S_WRITE10, S_WRITE11, S_WRITE12, S_WRITE13, S_WRITE14,
                       S_WRITE15,
                       S_IDLE);

   signal MemCtrl      : STD_LOGIC_VECTOR(8 downto 0);
	signal MemOutEN_i	  : STD_LOGIC;
	signal MemWrEN_i    : STD_LOGIC;
	signal MemChipEN_i  : STD_LOGIC;
   signal MemUBEN_i    : STD_LOGIC;
	signal MemLBEN_i    : STD_LOGIC;
   signal MemAdr_i     : STD_LOGIC_VECTOR(26 downto 1);
   
   signal Data_i       : STD_LOGIC_VECTOR(63 downto 0);
   signal AdrRead_i    : STD_LOGIC_VECTOR(26 downto 1);
   signal WPendRst     : STD_LOGIC := '0';
   signal WrtePend     : STD_LOGIC := '0';
   
   signal RPendRst     : STD_LOGIC;
   signal ReadPend     : STD_LOGIC;
	
	signal SReg			  : STATE_TYPE := S_IDLE;
	signal SNext		  : STATE_TYPE := S_IDLE;

---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   MEM_OE_L <= not MemOutEN_i;
   MEM_WR_L <= not MemWrEN_i;
   
   PCM_CS_L   <= '1';            -- Never Disabled!
   MEM_CS_L   <= not MemCtrl(8);
   RPendRst   <= MemCtrl(7);
   MemOutEN_i <= MemCtrl(6);
   WPendRst   <= MemCtrl(5);
   MemWrEN_i  <= MemCtrl(4);
   MEM_ADV_L  <= not MemCtrl(3);
   MEM_CLK_L  <= not MemCtrl(2);
   MEM_UB_L   <= not MemCtrl(1);
   MEM_LB_L   <= not MemCtrl(0);
   
   D_BUG(0) <= WCLK;
   D_BUG(1) <= CLK_IN;
   D_BUG(2) <= ReadPend;
   D_BUG(3) <= RPendRst;
   
--------------------------------------------------------------------------------
-- Clock Incoming Write Signal
--------------------------------------------------------------------------------
process(WCLK, WPendRst)
begin
   if(WPendRst = '1') then
      WrtePend <= '0';
   elsif(WCLK'event and WCLK='1') then
      WrtePend <= '1';
      Data_i <= D_IN;
   end if;
end process;
--------------------------------------------------------------------------------
-- Clock Incoming Read Signal
--------------------------------------------------------------------------------
process(RCLK, RPendRst)
begin
   if(RPendRst = '1') then
      ReadPend <= '0';
   elsif(RCLK'event and RCLK='1') then
      ReadPend <= '1';
      AdrRead_i <= ADR_READ;
   end if;
end process;
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
process(CLK_IN, SReg, WrtePend, ReadPend, CE, WADR_RST)
CONSTANT ADRMAX : STD_LOGIC_VECTOR(18 downto 1) := "100101011111111100";
CONSTANT ADRINCR : STD_LOGIC_VECTOR(26 downto 1) := "00000000000000000000000100";
CONSTANT MEMIDLE   : STD_LOGIC_VECTOR(8 downto 0)     := "100000000";

CONSTANT BURSTREAD0 : STD_LOGIC_VECTOR(8 downto 0)    := "110000111";
CONSTANT BURSTREAD1 : STD_LOGIC_VECTOR(8 downto 0)    := "100000011";
CONSTANT BURSTREAD2 : STD_LOGIC_VECTOR(8 downto 0)    := "100000111";
CONSTANT BURSTREAD3 : STD_LOGIC_VECTOR(8 downto 0)    := "101001011";
CONSTANT BURSTREAD4 : STD_LOGIC_VECTOR(8 downto 0)    := "101001111";

CONSTANT BURSTWRTE0 : STD_LOGIC_VECTOR(8 downto 0)    := "100111100";
CONSTANT BURSTWRTE1 : STD_LOGIC_VECTOR(8 downto 0)    := "100011100";
CONSTANT BURSTWRTE2 : STD_LOGIC_VECTOR(8 downto 0)    := "100011000";
CONSTANT BURSTWRTE3 : STD_LOGIC_VECTOR(8 downto 0)    := "100011100";
CONSTANT BURSTWRTE4 : STD_LOGIC_VECTOR(8 downto 0)    := "100010011";
CONSTANT BURSTWRTE5 : STD_LOGIC_VECTOR(8 downto 0)    := "100010111";

variable wrtecnt : STD_LOGIC_VECTOR(26 downto 1) := "00000000000000000000000000";
variable cnt : STD_LOGIC_VECTOR(7 downto 0) := X"00";
begin
   -----------------------------------------------------------------------------
   -- DISABLE CHIP SELECT DURING INITIALIZATION PERIOD
   -----------------------------------------------------------------------------
   if(CE = '0') then
      MemCtrl <= "0ZZZZZZZZ";
      MEM_ADR <= (others => 'Z');
      MEM_DB <= (others => 'Z');
      D_OUT <= (others => 'Z');
      RCLK_OUT <= 'Z';
   -----------------------------------------------------------------------------
   -- NORMAL OPERATION
   -----------------------------------------------------------------------------
   elsif(CLK_IN'event and CLK_IN = '1') then
      if(cnt = X"01") then
         MemCtrl <= BURSTREAD0;
         cnt := cnt + '1';
         MEM_DB <= (others => 'Z');
         MEM_ADR <= AdrRead_i;
         RCLK_OUT <= '0';
      elsif(cnt = X"02") then
         MemCtrl <= BURSTREAD1;
         cnt := cnt + '1';
      elsif(cnt = X"03") then
         MemCtrl <= BURSTREAD2;
         cnt := cnt + '1';
      elsif(cnt = X"04") then
         MemCtrl <= "100001011";
         cnt := cnt + '1';
      elsif(cnt = X"05") then
         MemCtrl <= BURSTREAD4;
         cnt := cnt + '1';
      elsif(cnt = X"06") then
         MemCtrl <= BURSTREAD3;
         cnt := cnt + '1';
      elsif(cnt = X"07") then
         MemCtrl <= BURSTREAD4;
         cnt := cnt + '1';
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(cnt = X"08") then
         MemCtrl <= BURSTREAD3;
         cnt := cnt + '1';
         RCLK_OUT <= '1';
      elsif(cnt = X"09") then
         MemCtrl <= BURSTREAD4;
         cnt := cnt + '1';
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(cnt = X"0A") then
         MemCtrl <= BURSTREAD3;
         cnt := cnt + '1';
         RCLK_OUT <= '1';
      elsif(cnt = X"0B") then
         MemCtrl <= BURSTREAD4;
         cnt := cnt + '1';
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(cnt = X"0C") then
         MemCtrl <= BURSTREAD3;
         cnt := cnt + '1';
         RCLK_OUT <= '1';
      elsif(cnt = X"0D") then
         MemCtrl <= BURSTREAD4;
         cnt := cnt + '1';
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(cnt = X"0E") then
         MemCtrl <= BURSTREAD3;
         cnt := cnt + '1';
         RCLK_OUT <= '1';
      elsif(cnt = X"0F") then
         MemCtrl <= BURSTREAD4;
         cnt := cnt + '1';
         RCLK_OUT <= '0';
      elsif(cnt = X"10") then
         MemCtrl <= MEMIDLE;
         cnt := X"00";
         
      -----------------------------------------------------------------------
      -- WRITE TO MEMORY (150 nS)
      -----------------------------------------------------------------------
      elsif(cnt = X"11") then
         MemCtrl <= BURSTWRTE0;
         cnt := cnt + '1';
         MEM_ADR <= wrtecnt;
         MEM_DB <= Data_i(15 downto 0);
      elsif(cnt = X"12") then
         MemCtrl <= BURSTWRTE1;
         cnt := cnt + '1';
      elsif(cnt = X"13") then
         MemCtrl <= BURSTWRTE2;
         cnt := cnt + '1';
      elsif(cnt = X"14") then
         MemCtrl <= BURSTWRTE3;
         cnt := cnt + '1';
      elsif(cnt = X"15") then
         MemCtrl <= BURSTWRTE2;
         cnt := cnt + '1';
      elsif(cnt = X"16") then
         MemCtrl <= BURSTWRTE3;
         cnt := cnt + '1';
      elsif(cnt = X"17") then
         MemCtrl <= BURSTWRTE4;
         cnt := cnt + '1';
      elsif(cnt = X"18") then
         MemCtrl <= BURSTWRTE5;
         cnt := cnt + '1';
      elsif(cnt = X"19") then
         MemCtrl <= BURSTWRTE4;
         cnt := cnt + '1';
      elsif(cnt = X"1A") then
         MemCtrl <= BURSTWRTE5;
         cnt := cnt + '1';
         MEM_DB <= Data_i(31 downto 16);
      elsif(cnt = X"1B") then
         MemCtrl <= BURSTWRTE4;
         cnt := cnt + '1';
      elsif(cnt = X"1C") then
         MemCtrl <= BURSTWRTE5;
         cnt := cnt + '1';
         MEM_DB <= Data_i(47 downto 32);
      elsif(cnt = X"1D") then
         MemCtrl <= BURSTWRTE4;
         cnt := cnt + '1';
      elsif(cnt = X"1E") then
         MemCtrl <= BURSTWRTE5;
         cnt := cnt + '1';
         MEM_DB <= Data_i(63 downto 48);
      elsif(cnt = X"1F") then
         MemCtrl <= BURSTWRTE4;
         cnt := cnt + '1';
      elsif(cnt = X"20") then
         MemCtrl <= BURSTWRTE5;
         cnt := cnt + '1';
      elsif(cnt = X"21") then
         MemCtrl <= BURSTWRTE4;
         cnt := cnt + '1';
         
         if(wrtecnt >= ADRMAX) then
            wrtecnt := "00000000000000000000000000";
         else
            wrtecnt := wrtecnt + ADRINCR;
         end if;
         
         
      elsif(cnt = X"22") then
         MemCtrl <= MEMIDLE;
         cnt := X"00";
         MEM_DB <= (others => 'Z');
            
      -----------------------------------------------------------------------
      -- IDLE STATE
      -----------------------------------------------------------------------
      elsif(cnt = X"00") then
         MemCtrl <= MEMIDLE;
            
         -- Give Priority to Write cycle
         if(WrtePend = '1') then
            cnt := X"11";
         elsif(ReadPend = '1') then
            cnt := X"01";
         else
            null;
         end if;
            
      -----------------------------------------------------------------------
      -- Send Error States to IDLE STATE
      -----------------------------------------------------------------------
      else
         MemCtrl <= MEMIDLE;
         cnt := X"00";
      end if;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
