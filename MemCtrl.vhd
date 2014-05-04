---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity MemCtrl is
	port(
		CLK100      : in  STD_LOGIC;
      WCLK        : in STD_LOGIC;
      D_IN        : in STD_LOGIC_VECTOR(63 downto 0);
      RCLK        : in STD_LOGIC;
      ADR_READ    : in STD_LOGIC_VECTOR(26 downto 1);
      CLK_OUT : out STD_LOGIC := '0';
      D_OUT       : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
      D_BUG       : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
      
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
end MemCtrl;
---------------------------------------------------------------------------------
architecture Behavioral of MemCtrl is
	TYPE STATE_TYPE is (S_READ0, S_READ1, S_READ2, S_READ3, S_READ4, S_READ5,
                       S_READ6, S_WRITE0, S_WRITE1, S_WRITE2, S_WRITE3, S_WRITE4,
                       S_WRITE5, S_WRITE6, S_WRITE7, S_WRITE8, S_WRITE9, S_IDLE);

   signal MemCtrl      : STD_LOGIC_VECTOR(7 downto 0);
	signal MemOutEN_i	  : STD_LOGIC;
	signal MemWrEN_i    : STD_LOGIC;
	signal MemChipEN_i  : STD_LOGIC;
   signal MemUBEN_i    : STD_LOGIC;
	signal MemLBEN_i    : STD_LOGIC;
   signal MemAdr_i     : STD_LOGIC_VECTOR(26 downto 1);
   
   signal Data_i       : STD_LOGIC_VECTOR(63 downto 0);
   
   signal WPendRst     : STD_LOGIC := '0';
   signal WrtePend     : STD_LOGIC := '0';
   signal WrteDone     : STD_LOGIC := '0';
   signal WrteCnt      : STD_LOGIC_VECTOR(26 downto 1) := (others => '0');
   signal ReadDone     : STD_LOGIC;
   
	signal TimerEN      : STD_LOGIC := '0';
   signal Timer        : STD_LOGIC_VECTOR(3 downto 0):= "0000";
	
	signal SReg			  : STATE_TYPE := S_IDLE;
	signal SNext		  : STATE_TYPE := S_IDLE;
   

---------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   MEM_OE_L <= not MemOutEN_i;
   MEM_WR_L <= not MemWrEN_i;
   
   PCM_CS_L   <= '1';            -- Never Enabled!
   MEM_CS_L   <= not MemCtrl(7);
   MemOutEN_i <= MemCtrl(6);
   WPendRst   <= MemCtrl(5);
   MemWrEN_i  <= MemCtrl(4);
   MEM_ADV_L  <= not MemCtrl(3);
   MEM_CLK_L  <= not MemCtrl(2);
   MEM_UB_L   <= not MemCtrl(1);
   MEM_LB_L   <= not MemCtrl(0);
   
   D_BUG(1) <= WCLK;
   D_BUG(2) <= WrtePend;
   D_BUG(3) <= MemWrEN_i;
   
 --------------------------------------------------------------------------------
-- Clock Incoming Write Signal
--
process(WCLK, WPendRst)
begin
   if(WPendRst = '0') then
      if(WCLK'event and WCLK='1') then
         WrtePend <= '1';
         Data_i <= D_IN;
      else
         null;
      end if;
   else
      WrtePend <= '0';
   end if;
end process;
--------------------------------------------------------------------------------
-- Description of State Machine
--
process(CLK100)
begin	
	if (CLK100'event and CLK100 = '1') then
		SReg <= SNext;
      if(SReg = S_READ0) then
         MEM_ADR <= ADR_READ;
         MEM_DB <= (others => 'Z');
         if(ADR_READ = "100101011111111110") then
            --D_BUG(1) <= '1';
         else
            --D_BUG(1) <= '0';
         end if;
      elsif(SReg = S_READ6) then
         D_OUT <= MEM_DB;
      elsif(SReg = S_WRITE0) then
         MEM_ADR <= WrteCnt;
         MEM_DB <= (others => '0');
      elsif(SReg = S_WRITE2) then
         MEM_DB <= Data_i(15 downto 0);
      elsif(SReg = S_WRITE4) then
         MEM_DB <= Data_i(31 downto 16);
      elsif(SReg = S_WRITE6) then
         MEM_DB <= Data_i(47 downto 32);
      elsif(SReg = S_WRITE8) then
         MEM_DB <= Data_i(63 downto 48);
      elsif(SReg = S_WRITE9) then
         MEM_DB <= (others => 'Z');
--         if(WrteCnt <= "100101011111111111") then
         if(WrteCnt <    "100101100000000000") then
            WrteCnt <= WrteCnt + "100";
         else
            WrteCnt <= (others => '0');
         end if;
         if(WrteCnt = "00000000000000000000000000000000") then
            D_BUG(0) <= '1';
         else
            D_BUG(0) <= '0';
         end if;
      elsif(SReg = S_IDLE) then
         MEM_DB <= (others => 'Z');
      end if;
	else
		null;
	end if;
end process;
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
process(WCLK, WPendRst)
begin
   if(WPendRst = '1') then
      WrtePend <= '0';
   else
      if(WCLK'event and WCLK = '1') then
         WrtePend <= '1';
      else
         null;
      end if;
   end if;
end process;
         
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
process(SReg, SNext, Timer, MEM_DB, WCLK, RCLK, D_IN, ADR_READ)
CONSTANT MEMIDLE   : STD_LOGIC_VECTOR(7 downto 0)    := "00000000";
CONSTANT MEMREAD   : STD_LOGIC_VECTOR(7 downto 0)    := "11001111";

CONSTANT MEMWRTE0  : STD_LOGIC_VECTOR(7 downto 0)    := "10111111";
CONSTANT MEMWRTE1  : STD_LOGIC_VECTOR(7 downto 0)    := "10011111";

CONSTANT MEMWBRST0 : STD_LOGIC_VECTOR(7 downto 0)    := "10111000";
CONSTANT MEMWBRST1 : STD_LOGIC_VECTOR(7 downto 0)    := "10011100";
CONSTANT MEMWBRST2 : STD_LOGIC_VECTOR(7 downto 0)    := "10000000";
CONSTANT MEMWBRST3 : STD_LOGIC_VECTOR(7 downto 0)    := "10000111";
CONSTANT MEMWBRST4 : STD_LOGIC_VECTOR(7 downto 0)    := "10000011";
--VARIABLE cnt : INTEGER := 0;
begin
	case SReg is
		-----------------------------------------------------------------------
		-- READ FROM MEMORY (70 nS)
		-----------------------------------------------------------------------
		when S_READ0 =>
         MemCtrl <= MEMREAD;
         SNext <= S_READ1;
		when S_READ1 =>
         MemCtrl <= MEMREAD;
         SNext <= S_READ2;
		when S_READ2 =>
         MemCtrl <= MEMREAD;
         SNext <= S_READ3;
		when S_READ3 =>
         MemCtrl <= MEMREAD;
         SNext <= S_READ4;
		when S_READ4 =>
         MemCtrl <= MEMREAD;
         SNext <= S_READ5;
		when S_READ5 =>
         MemCtrl <= MEMREAD;
         SNext <= S_READ6;
		when S_READ6 =>
         MemCtrl <= MEMIDLE;
         SNext <= S_IDLE;
			
		-----------------------------------------------------------------------
		-- WRITE TO MEMORY (70 nS)
		-----------------------------------------------------------------------
		when S_WRITE0 =>
         MemCtrl <= MEMWBRST0;
         SNext <= S_WRITE1;
		when S_WRITE1 =>
         MemCtrl <= MEMWBRST1;
         SNext <= S_WRITE2;
		when S_WRITE2 =>
         MemCtrl <= MEMWBRST2;
         SNext <= S_WRITE3;
		when S_WRITE3 =>
         MemCtrl <= MEMWBRST3;
         SNext <= S_WRITE4;
		when S_WRITE4 =>
         MemCtrl <= MEMWBRST4;
         SNext <= S_WRITE5;
		when S_WRITE5 =>
         MemCtrl <= MEMWBRST3;
         SNext <= S_WRITE6;
		when S_WRITE6 =>
         MemCtrl <= MEMWBRST4;
         SNext <= S_WRITE7;
		when S_WRITE7 =>
         MemCtrl <= MEMWBRST3;
         SNext <= S_WRITE8;
		when S_WRITE8 =>
         MemCtrl <= MEMWBRST4;
         SNext <= S_WRITE9;
		when S_WRITE9 =>
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
            elsif(RCLK = '1') then
               SNext <= S_READ0;
            else
               SNext <= S_IDLE;
            end if;
         
		-----------------------------------------------------------------------
		-- Send Error States to IDLE STATE
		-----------------------------------------------------------------------
		when others =>
			SNext <= S_IDLE;
	end case;
end process;
--------------------------------------------------------------------------------
end Behavioral;
