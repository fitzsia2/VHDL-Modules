---------------------------------------------------------------------------------
-- CrcLoader.vhd
--
-- Author: Andrew Fitzsimons
-- 2014
--
-- Largest amount of data held by UDP payload is defined by the generic
--   UDP_PAYLOAD_SIZE
--
-- This hardware instance clocks data into CRCGenerator.vhd. 
---------------------------------------------------------------------------------
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
ENTITY CrcLoader IS
   GENERIC(
      UDP_PAYLOAD_SIZE : INTEGER := 800
      );
   PORT(
      CLK_IN : IN STD_LOGIC; -- 100MHz
      COUNT_IN : IN INTEGER;
      TXD : OUT STD_LOGIC_VECTOR(7 downto 0) := (others => 'Z');
      LOAD_INIT_OUT : OUT STD_LOGIC := '0';
      CALC_OUT : OUT STD_LOGIC := '0';
      D_VALID_OUT : OUT STD_LOGIC := '0';
      RCLK_OUT : OUT STD_LOGIC := '0'; -- Initiates a read from memory
      RADDR_OUT : OUT STD_LOGIC_VECTOR(25 downto 0) := (others => '0'); -- Address to read from memory
      DATA_IN : IN STD_LOGIC_VECTOR(63 downto 0); -- Data from memory
      DCLK_IN : IN STD_LOGIC -- Indicates valid data on PDATA_IN
      );
END CrcLoader;

---------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF CrcLoader IS
   SIGNAL Data_i : STD_LOGIC_VECTOR(127 downto 0);


---------------------------------------------------------------------------------
-- Signal Assignment
--
BEGIN

---------------------------------------------------------------------------------
-- Main Process
--
PROCESS( CLK_IN, COUNT_IN )
VARIABLE i : INTEGER := 0;
BEGIN
   IF( CLK_IN'event and CLK_IN = '1' ) THEN
      IF( COUNT_IN = CRC_ETHERNETCOUNT3 ) THEN TXD <= SHL(MAC_DESTADDR1,"100") or MAC_DESTADDR2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT4 ) THEN 
         TXD <= SHL(MAC_DESTADDR3,"100") or MAC_DESTADDR4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT5 ) THEN TXD <= SHL(MAC_DESTADDR5,"100") or MAC_DESTADDR6;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT6 ) THEN TXD <= SHL(MAC_DESTADDR7,"100") or MAC_DESTADDR8;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT7 ) THEN TXD <= SHL(MAC_DESTADDR9,"100") or MAC_DESTADDR10;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT8 ) THEN TXD <= SHL(MAC_DESTADDR11,"100") or MAC_DESTADDR12;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT9 ) THEN TXD <= SHL(MAC_SRCADDR1,"100") or MAC_SRCADDR2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT10 ) THEN TXD <= SHL(MAC_SRCADDR3,"100") or MAC_SRCADDR4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT11 ) THEN TXD <= SHL(MAC_SRCADDR5,"100") or MAC_SRCADDR6;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT12 ) THEN TXD <= SHL(MAC_SRCADDR7,"100") or MAC_SRCADDR8;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT13 ) THEN TXD <= SHL(MAC_SRCADDR9,"100") or MAC_SRCADDR10;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT14 ) THEN TXD <= SHL(MAC_SRCADDR11,"100") or MAC_SRCADDR12;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT15 ) THEN TXD <= SHL(ETHERTYPE1,"100") or ETHERTYPE2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT16 ) THEN TXD <= SHL(ETHERTYPE3,"100") or ETHERTYPE4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT17 ) THEN TXD <= SHL(IP_VER,"100") or IP_IHL;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT18 ) THEN TXD <= SHL(IP_SRVTP1,"100") or IP_SRVTP2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT19 ) THEN TXD <= SHL(IP_LENG1,"100") or IP_LENG2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT20 ) THEN TXD <= SHL(IP_LENG3,"100") or IP_LENG4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT21 ) THEN TXD <= SHL(IP_ID0,"100") or IP_ID1;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT22 ) THEN TXD <= SHL(IP_FLAGS,"100") or IP_OFFSET0;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT23 ) THEN TXD <= SHL(IP_OFFSET1,"100") or IP_OFFSET2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT24 ) THEN TXD <= SHL(IP_TTL1,"100") or IP_TTL2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT25 ) THEN TXD <= SHL(IP_PROTOCOL1,"100") or IP_PROTOCOL2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT26 ) THEN TXD <= SHL(IP_HDCHKSUM1,"100") or IP_HDCHKSUM2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT27 ) THEN TXD <= SHL(IP_HDCHKSUM3,"100") or IP_HDCHKSUM4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT28 ) THEN TXD <= SHL(IP_SRCIP1,"100") or IP_SRCIP2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT29 ) THEN TXD <= SHL(IP_SRCIP3,"100") or IP_SRCIP4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT30 ) THEN TXD <= SHL(IP_SRCIP5,"100") or IP_SRCIP6;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT31 ) THEN TXD <= SHL(IP_SRCIP7,"100") or IP_SRCIP8;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT32 ) THEN TXD <= SHL(IP_DSTIP1,"100") or IP_DSTIP2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT33 ) THEN TXD <= SHL(IP_DSTIP3,"100") or IP_DSTIP4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT34 ) THEN TXD <= SHL(IP_DSTIP5,"100") or IP_DSTIP6;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT35 ) THEN TXD <= SHL(IP_DSTIP7,"100") or IP_DSTIP8;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT36 ) THEN TXD <= SHL(UDP_SRCADR1,"100") or UDP_SRCADR2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT37 ) THEN TXD <= SHL(UDP_SRCADR3,"100") or UDP_SRCADR4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT38 ) THEN TXD <= SHL(UDP_DSTADR1,"100") or UDP_DSTADR2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT39 ) THEN TXD <= SHL(UDP_DSTADR3,"100") or UDP_DSTADR4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT40 ) THEN TXD <= SHL(UDP_LENG1,"100") or UDP_LENG2;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT41 ) THEN TXD <= SHL(UDP_LENG3,"100") or UDP_LENG4;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT42 ) THEN TXD <= SHL(UDP_CHKSUM0,"100") or UDP_CHKSUM1;
      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT43 ) THEN TXD <= SHL(UDP_CHKSUM2,"100") or UDP_CHKSUM3;
      ELSIF( COUNT_IN >= CRC_ETHERNETCOUNT44 ) THEN
         TXD <= Data_i( ( i + 7 ) downto i );
         if( i >= 120 ) then
            i := 0;
         else
            i := i + 8;
         end if;
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT45 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT46 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT47 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT48 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT49 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT50 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT51 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT52 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT53 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT54 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT55 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT56 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT57 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT58 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT59 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT60 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT61 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT62 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT63 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT64 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT65 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT66 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT67 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT68 ) THEN TXD <= Data_i(7 downto 0);
--      ELSIF( COUNT_IN = CRC_ETHERNETCOUNT69 ) THEN TXD <= Data_i(7 downto 0);





--      ELSIF( COUNT_IN >= ETH_IPV4_UDP_CHKSUM3 AND COUNT_IN <= ETH_IPV4_UDP_PAYLOAD ) THEN
--         TXD <= Data_i( ( i + 7 ) downto i );
--         if( i >= 124 ) then
--            i := 0;
--         else
--            i := i + 4;
--         end if;
      ELSE
         TXD <= "ZZZZZZZZ";
      END IF; -- COUNTER
                
      --
      -- Need to input camera data here
      --
                
   END IF; -- CLK EDGE
END PROCESS;

---------------------------------------------------------------------------------
--
--
PROCESS( DCLK_IN )
   VARIABLE cnt : STD_LOGIC := '0';
BEGIN
   IF( DCLK_IN'event AND DCLK_IN = '1' ) THEN
      IF( cnt = '0' ) THEN
         Data_i(63 downto 0) <= DATA_IN(63 downto 0);
         cnt := '1';
      ELSE
         Data_i(127 downto 64) <= DATA_IN(63 downto 0);
         cnt := '0';
      END IF;
   ELSE
      NULL;
   END IF;
END PROCESS;

---------------------------------------------------------------------------------
--
--
PROCESS( CLK_IN, COUNT_IN )
   VARIABLE cnt : INTEGER := 0;
BEGIN
   IF( CLK_IN'event AND CLK_IN='1' ) THEN
      IF( ( COUNT_IN >= CRC_ETHERNETCOUNT26 )
            AND ( ( COUNT_IN MOD 32) = 0 ) ) THEN
         RCLK_OUT <= '1';
         cnt := cnt + 4;
      ELSE
         RADDR_OUT <= conv_std_logic_vector( cnt, 26 );
         RCLK_OUT <= '0';
      END IF;
   ELSE
      NULL;
   END IF;
END PROCESS;


---------------------------------------------------------------------------------
END Behavioral;
