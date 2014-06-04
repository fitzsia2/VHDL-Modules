--------------------------------------------------------------------------------
-- MemOperation.vhd
--
-- Configured for 4 words, 150ns write cycles.
-- Memory MUST be initialized for burst read/write cycles
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
entity MemOperation is
  port(
        CE : in std_logic;
        CLK_IN : in std_logic;
        WCLK : in std_logic;
        WADR_RST : in std_logic;
        ADR_in : in std_logic_vector(25 downto 0);
        D_IN : in std_logic_vector(63 downto 0);
        DATA_ACK_out : out std_logic := '0';
        RCLK : in std_logic;
        ADR_READ : in std_logic_vector(25 downto 0);
        D_OUT : out std_logic_vector(15 downto 0);
        RCLK_OUT : out std_logic := 'Z';
        D_BUG : out std_logic_vector(3 downto 0)  := (others => 'Z');

        -- CELLULAR MEMORY PORTS
        PCM_CS_L : out std_logic := '1'; --Disable PCM Device
        MEM_CS_L : out std_logic := 'Z'; -- Cellular RAM Chip Select
        MEM_OE_L : out std_logic := 'Z'; -- Cellular Ram Output EN
        MEM_WR_L : out std_logic := 'Z'; -- Cellular Write EN
        MEM_ADV_L : out std_logic := 'Z';	-- Mem Address Valid Pin
        MEM_CLK_L : out std_logic := 'Z';	-- Mem CLK
        MEM_UB_L : out std_logic := 'Z'; 
        MEM_LB_L : out std_logic := 'Z';
        MEM_ADR : out std_logic_vector(25 downto 0) := (others => 'Z');
        MEM_DB : inout std_logic_vector(15 downto 0) := (others => 'Z')
      );
end MemOperation;

architecture Behavioral of MemOperation is
  ------------------------------------------------------------------------------
  -- Type Declaration
  ------------------------------------------------------------------------------
  type STATE_TYPE
    is(
      S_READ0, S_READ1, S_READ2, S_READ3, S_READ4, S_READ5, S_READ6, S_READ7, S_READ8, S_READ9, S_READ10, S_READ11, S_READ12, S_READ13, S_READ14, S_READ15,
      S_WRITE0, S_WRITE1, S_WRITE2, S_WRITE3, S_WRITE4, S_WRITE5, S_WRITE6, S_WRITE7, S_WRITE8, S_WRITE9, S_WRITE10, S_WRITE11, S_WRITE12, S_WRITE13, S_WRITE14, S_WRITE15,
      S_IDLE
    );

  ------------------------------------------------------------------------------
  -- Internal Hardware Signals
  ------------------------------------------------------------------------------
  signal MemCtrl : std_logic_vector(8 downto 0);
  signal MemOutEN_i : std_logic;
  signal MemWrEN_i : std_logic;
  signal MemChipEN_i : std_logic;
  signal MemUBEN_i : std_logic;
  signal MemLBEN_i : std_logic;
  signal MemAdr_i : std_logic_vector(25 downto 0);

  signal Data_i : std_logic_vector(63 downto 0);
  signal AdrRead_i : std_logic_vector(25 downto 0);
  signal WPendRst : std_logic := '0';
  signal WrtePend : std_logic := '0';

  signal RPendRst : std_logic;
  signal ReadPend : std_logic;

  signal SReg : STATE_TYPE := S_IDLE;
  signal SNext : STATE_TYPE := S_IDLE;

--------------------------------------------------------------------------------
-- Signal Assignments
--------------------------------------------------------------------------------
begin
  MEM_OE_L <= not MemOutEN_i;
  MEM_WR_L <= not MemWrEN_i;
  DATA_ACK_out <= WrtePend;

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

  ------------------------------------------------------------------------------
  -- Clock Incoming Write Signal
  --
  process(WCLK, WPendRst)
  begin
    if(WPendRst = '1') then
      WrtePend <= '0'; -- Reset at the beginning of a write sequence
    elsif(WCLK'event and WCLK='1') then
      Data_i <= D_IN;
      AdrWrite_i <= ADR_in;
      WrtePend <= '1';
    end if;
  end process;
  ------------------------------------------------------------------------------
  -- Clock Incoming Read Signal
  --
  process(RCLK, RPendRst)
  begin
    if(RPendRst = '1') then
      ReadPend <= '0';
    elsif(RCLK'event and RCLK='1') then
      AdrRead_i <= ADR_READ;
      ReadPend <= '1';
    end if;
  end process;
  ------------------------------------------------------------------------------
  -- Description of State Machine
  --
  process(CLK_IN, WADR_RST, CE)
    constant ADRMAX : std_logic_vector := X"257FC";
  begin

    if(CE = '0') then
      MEM_ADR <= (others => 'Z');
      MEM_DB <= (others => 'Z');
      D_OUT <= (others => 'Z');
      RCLK_OUT <= 'Z';
    elsif(CLK_IN'event and CLK_IN = '1') then
      SReg <= SNext;

      --------------------------------------------------------------------------
      -- Set data and address buses for read sequence
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
      -- Set data and address bus for Write sequence
      --
      elsif(SReg = S_WRITE0) then
        MEM_ADR <= AdrWrite_i;
        MEM_DB <= Data_i(15 downto 0);
      elsif(SReg = S_WRITE9) then
        MEM_DB <= Data_i(31 downto 16);
      elsif(SReg = S_WRITE11) then
        MEM_DB <= Data_i(47 downto 32);
      elsif(SReg = S_WRITE13) then
        MEM_DB <= Data_i(63 downto 48);
      elsif(SReg = S_IDLE) then
        MEM_DB <= (others => 'Z');
        RCLK_OUT <= '0';
      end if;

      --------------------------------------------------------------------------
      -- Reset write address whenever a WADR_RST is asserted
      --
      if(WADR_RST = '1') then
        MEM_DB <= (others => 'Z');
      else
        null;
      end if;

    else
      null;
    end if;
  end process;
  ------------------------------------------------------------------------------
  --
  ------------------------------------------------------------------------------
  process(SReg, WrtePend, ReadPend, CE)
    constant MEMIDLE   : std_logic_vector(8 downto 0)     := "000000000";

    constant BURSTREAD0 : std_logic_vector(8 downto 0)    := "110001111";
    constant BURSTREAD1 : std_logic_vector(8 downto 0)    := "100001011";
    constant BURSTREAD2 : std_logic_vector(8 downto 0)    := "100000111";
    constant BURSTREAD3 : STD_LOGIC_VECTOR(8 downto 0)    := "101000011";
    constant BURSTREAD4 : std_logic_vector(8 downto 0)    := "101000111";

    constant BURSTWRTE0 : std_logic_vector(8 downto 0)    := "100111100"; -- Resets the write pend
    constant BURSTWRTE1 : std_logic_vector(8 downto 0)    := "100011000";
    constant BURSTWRTE2 : std_logic_vector(8 downto 0)    := "100010100";
    constant BURSTWRTE3 : std_logic_vector(8 downto 0)    := "100010000";
    constant BURSTWRTE4 : std_logic_vector(8 downto 0)    := "100000111";
    constant BURSTWRTE5 : std_logic_vector(8 downto 0)    := "100000011";
  begin
    ----------------------------------------------------------------------------
    -- Set all outputs to active low when chip is disabled
    ----------------------------------------------------------------------------
    if(CE = '0') then
      MemCtrl <= "LLLLLLLLL";
      SNext <= S_IDLE;
    ----------------------------------------------------------------------------
    -- NORMAL OPERATION
    ----------------------------------------------------------------------------
    else
      case SReg is
        ------------------------------------------------------------------------
        -- READ FROM MEMORY (150 nS)
        ------------------------------------------------------------------------
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

        ------------------------------------------------------------------------
        -- WRITE TO MEMORY (150 nS)
        ------------------------------------------------------------------------
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

        ------------------------------------------------------------------------
        -- IDLE STATE
        ------------------------------------------------------------------------
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

        ------------------------------------------------------------------------
        -- Send Error States to IDLE STATE
        ------------------------------------------------------------------------
        when others =>
          MemCtrl <= MEMIDLE;
          SNext <= S_IDLE;
      end case;
    end if;
  end process;
--------------------------------------------------------------------------------
end Behavioral;
