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
      ADR_READ    : in STD_LOGIC_VECTOR(25 downto 0);
      D_OUT       : out STD_LOGIC_VECTOR(15 downto 0);
      RCLK_OUT    : OUT STD_LOGIC := 'Z';
      D_BUG       : out STD_LOGIC_VECTOR(3 downto 0)  := (others => 'Z');
      
   -- CELLULAR MEMORY PORTS
		PCM_CS_L    : out STD_LOGIC := '1'; --Disable PCM Device
		MEM_CS_L    : out STD_LOGIC := 'Z';	-- Cellular RAM Chip Select
      MEM_OE_L    : out STD_LOGIC := 'Z';  -- Cellular Ram Output EN
		MEM_WR_L    : out STD_LOGIC := 'Z';	-- Cellular Write EN
		MEM_ADV_L   : out STD_LOGIC := 'Z';	-- Mem Address Valid Pin
   	MEM_CLK_L   : out STD_LOGIC := 'Z';	-- Mem CLK
      MEM_UB_L    : out STD_LOGIC := 'Z'; 
      MEM_LB_L    : out STD_LOGIC := 'Z';
		MEM_ADR     : out STD_LOGIC_VECTOR(25 downto 0) := (others => 'Z');
		MEM_DB      : inout STD_LOGIC_VECTOR(15 downto 0) := (others => 'Z')
      );
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
   signal MemAdr_i     : STD_LOGIC_VECTOR(25 downto 0);
   
   signal Data_i       : STD_LOGIC_VECTOR(63 downto 0);
   signal AdrRead_i    : STD_LOGIC_VECTOR(25 downto 0);
   signal WPendRst     : STD_LOGIC := '0';
   signal WrtePend     : STD_LOGIC := '0';
   signal WrteCnt      : STD_LOGIC_VECTOR(25 downto 0) := (others => '0');
   
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
--
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
--
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
-- Description of State Machine
--
process(CLK_IN, WADR_RST, WrteCnt, CE)
CONSTANT ADRMAX : STD_LOGIC_VECTOR := X"257FC";
begin
   
	if(CE = '0') then
      MEM_ADR <= (others => 'Z');
      MEM_DB <= (others => 'Z');
      D_OUT <= (others => 'Z');
      RCLK_OUT <= 'Z';
   elsif(CLK_IN'event and CLK_IN = '1') then
		SReg <= SNext;
      
      --------------------------------------------------------------------------
      -- Set memory data and address bus for read sequence
      --
      if(SReg = S_READ0) then
         MEM_ADR <= AdrRead_i;
         MEM_DB <= (others => 'Z');
      elsif(SReg = S_READ8) then
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(SReg = S_READ9) then
         RCLK_OUT <= '0';
      elsif(SReg = S_READ10) then
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(SReg = S_READ11) then
         RCLK_OUT <= '1';
      elsif(SReg = S_READ12) then
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(SReg = S_READ13) then
         RCLK_OUT <= '1';
      elsif(SReg = S_READ14) then
         D_OUT <= MEM_DB;
         RCLK_OUT <= '0';
      elsif(SReg = S_READ15) then
         RCLK_OUT <= '1';
         
      --------------------------------------------------------------------------
      -- Set memory data and address bus for Write sequence
      --
      elsif(SReg = S_WRITE0) then
         MEM_ADR <= WrteCnt;
         MEM_DB <= Data_i(15 downto 0);
      elsif(SReg = S_WRITE9) then
         MEM_DB <= Data_i(31 downto 16);
      elsif(SReg = S_WRITE11) then
         MEM_DB <= Data_i(47 downto 32);
      elsif(SReg = S_WRITE13) then
         MEM_DB <= Data_i(63 downto 48);
      elsif(SReg = S_WRITE15) then
         WrteCnt <= WrteCnt + "100";
      elsif(SReg = S_IDLE) then
         MEM_DB <= (others => 'Z');
         RCLK_OUT <= '0';
      end if;
      
      --------------------------------------------------------------------------
      -- Reset Write Address Whenever a VSYNC is asserted
      --
      if(WADR_RST = '1') then
         MEM_DB <= (others => 'Z');
         WrteCnt <= (others => '0');
      else
         null;
      end if;
      
	else
		null;
	end if;
end process;
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
process(SReg, WrtePend, ReadPend, CE)
CONSTANT MEMIDLE   : STD_LOGIC_VECTOR(8 downto 0)     := "000000000";

CONSTANT BURSTREAD0 : STD_LOGIC_VECTOR(8 downto 0)    := "110001111";
CONSTANT BURSTREAD1 : STD_LOGIC_VECTOR(8 downto 0)    := "100001011";
CONSTANT BURSTREAD2 : STD_LOGIC_VECTOR(8 downto 0)    := "100000111";
CONSTANT BURSTREAD3 : STD_LOGIC_VECTOR(8 downto 0)    := "101000011";
CONSTANT BURSTREAD4 : STD_LOGIC_VECTOR(8 downto 0)    := "101000111";

CONSTANT BURSTWRTE0 : STD_LOGIC_VECTOR(8 downto 0)    := "100111100";
CONSTANT BURSTWRTE1 : STD_LOGIC_VECTOR(8 downto 0)    := "100011000";
CONSTANT BURSTWRTE2 : STD_LOGIC_VECTOR(8 downto 0)    := "100010100";
CONSTANT BURSTWRTE3 : STD_LOGIC_VECTOR(8 downto 0)    := "100010000";
CONSTANT BURSTWRTE4 : STD_LOGIC_VECTOR(8 downto 0)    := "100000111";
CONSTANT BURSTWRTE5 : STD_LOGIC_VECTOR(8 downto 0)    := "100000011";
begin
   -----------------------------------------------------------------------------
   -- DISABLE CHIP SELECT DURING INITIALIZATION PERIOD
   -----------------------------------------------------------------------------
   if(CE = '0') then
      MemCtrl <= "LLLLLLLLL";
      SNext <= S_IDLE;
   -----------------------------------------------------------------------------
   -- NORMAL OPERATION
   -----------------------------------------------------------------------------
   else
      case SReg is
         -----------------------------------------------------------------------
         -- READ FROM MEMORY (150 nS)
         -----------------------------------------------------------------------
         when S_READ0 =>
            MemCtrl <= BURSTREAD0;
            SNext <= S_READ1;
         when S_READ1 =>
            MemCtrl <= BURSTREAD1;
            SNext <= S_READ2;
         when S_READ2 =>
            MemCtrl <= BURSTREAD2;
            SNext <= S_READ3;
         when S_READ3 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ4;
         when S_READ4 =>
            MemCtrl <= BURSTREAD4;
            SNext <= S_READ5;
         when S_READ5 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ6;
         when S_READ6 =>
            MemCtrl <= BURSTREAD4;
            SNext <= S_READ7;
         when S_READ7 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ8;
         when S_READ8 =>
            MemCtrl <= BURSTREAD4;
            SNext <= S_READ9;
         when S_READ9 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ10;
         when S_READ10 =>
            MemCtrl <= BURSTREAD4;
            SNext <= S_READ11;
         when S_READ11 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ12;
         when S_READ12 =>
            MemCtrl <= BURSTREAD4;
            SNext <= S_READ13;
         when S_READ13 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ14;
         when S_READ14 =>
            MemCtrl <= BURSTREAD3;
            SNext <= S_READ15;
         when S_READ15 =>
            MemCtrl <= MEMIDLE;
            SNext <= S_IDLE;
            
         -----------------------------------------------------------------------
         -- WRITE TO MEMORY (150 nS)
         -----------------------------------------------------------------------
         when S_WRITE0 =>
            MemCtrl <= BURSTWRTE0;
            SNext <= S_WRITE1;
         when S_WRITE1 =>
            MemCtrl <= BURSTWRTE1;
            SNext <= S_WRITE2;
         when S_WRITE2 =>
            MemCtrl <= BURSTWRTE2;
            SNext <= S_WRITE3;
         when S_WRITE3 =>
            MemCtrl <= BURSTWRTE3;
            SNext <= S_WRITE4;
         when S_WRITE4 =>
            MemCtrl <= BURSTWRTE2;
            SNext <= S_WRITE5;
         when S_WRITE5 =>
            MemCtrl <= BURSTWRTE3;
            SNext <= S_WRITE6;
         when S_WRITE6 =>
            MemCtrl <= BURSTWRTE4;
            SNext <= S_WRITE7;
         when S_WRITE7 =>
            MemCtrl <= BURSTWRTE5;
            SNext <= S_WRITE8;
         when S_WRITE8 =>
            MemCtrl <= BURSTWRTE4;
            SNext <= S_WRITE9;
         when S_WRITE9 =>
            MemCtrl <= BURSTWRTE5;
            SNext <= S_WRITE10;
         when S_WRITE10 =>
            MemCtrl <= BURSTWRTE4;
            SNext <= S_WRITE11;
         when S_WRITE11 =>
            MemCtrl <= BURSTWRTE5;
            SNext <= S_WRITE12;
         when S_WRITE12 =>
            MemCtrl <= BURSTWRTE4;
            SNext <= S_WRITE13;
         when S_WRITE13 =>
            MemCtrl <= BURSTWRTE5;
            SNext <= S_WRITE14;
         when S_WRITE14 =>
            MemCtrl <= BURSTWRTE4;
            SNext <= S_WRITE15;
         when S_WRITE15 =>
            MemCtrl <= MEMIDLE;
            SNext <= S_IDLE;
            
         -----------------------------------------------------------------------
         -- IDLE STATE
         -----------------------------------------------------------------------
         when S_IDLE =>
            MemCtrl <= MEMIDLE;
               
            -- Give Priority to Write cycle
               if(WrtePend = '1') then
                  SNext <= S_WRITE0;
               elsif(ReadPend = '1') then
                  SNext <= S_READ0;
               else
                  SNext <= S_IDLE;
               end if;
            
         -----------------------------------------------------------------------
         -- Send Error States to IDLE STATE
         -----------------------------------------------------------------------
         when others =>
            MemCtrl <= MEMIDLE;
            SNext <= S_IDLE;
      end case;
   end if;
end process;
--------------------------------------------------------------------------------
end Behavioral;
