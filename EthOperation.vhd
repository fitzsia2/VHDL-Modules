---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
entity EthOperation is port(
   CE : in STD_LOGIC;
   CLK100 : in STD_LOGIC;
   TXD : out STD_LOGIC_VECTOR(3 downto 0);
   TXEN : out STD_LOGIC;
   TXCLK : in STD_LOGIC;
   TXER_TX4 : out STD_LOGIC;
   D_BUG : out STD_LOGIC_VECTOR(3 downto 0);
   COL : out STD_LOGIC
   );
end EthOperation;

---------------------------------------------------------------------------------
architecture Behavioral of EthOperation is
   TYPE SEQUENTIALSTATETYPE is (ENABLE, RUN, FRAMEGAP);
   
   signal ChipState : SEQUENTIALSTATETYPE := RUN;
   signal ChipSNext : SEQUENTIALSTATETYPE := RUN;
   signal Clk_50     : STD_LOGIC;
   signal Clk_25     : STD_LOGIC;
   signal EthCounter : INTEGER := 0;
   signal TxClk_i    : STD_LOGIC;
   signal TxEn_i     : STD_LOGIC;
   signal TxD_i      : STD_LOGIC_VECTOR(3 downto 0);
   signal d_bug_i    : STD_LOGIC;
   
   
----------------------------------------
-- Definitions
----------------------------------------
-- Ethernet Header Offsets

-- Nibble Count
-- ----------------------------------------------------------------------------------------
-- -  7bytes    - 1Byte -   6bytes   -  6bytes   - 2bytes -           - 4bytes -   12bytes
-- -  Preamble  -  SFD  -  DestAddr  -  SrcAddr  -  Type  -  PayLoad  -  CRC   -  FrameGap
-- ----------------------------------------------------------------------------------------
-- |            |       |            |           |        |           |        |
-- |0           |14   15|          27|         39|      43|         51|    9015|


CONSTANT ETH_SFD1 : INTEGER := 11;
CONSTANT ETH_SFD2 : INTEGER := ETH_SFD1 + 1;
--CONSTANT ETH_SFD3 : INTEGER := ETH_SFD2 + 1;

CONSTANT ETH_DESTADDR2 : INTEGER := ETH_SFD2 + 1;
CONSTANT ETH_DESTADDR1 : INTEGER := ETH_DESTADDR2 + 1;

CONSTANT ETH_DESTADDR4 : INTEGER := ETH_DESTADDR1 + 1;
CONSTANT ETH_DESTADDR3 : INTEGER := ETH_DESTADDR4 + 1;

CONSTANT ETH_DESTADDR6 : INTEGER := ETH_DESTADDR3 + 1;
CONSTANT ETH_DESTADDR5 : INTEGER := ETH_DESTADDR6 + 1;

CONSTANT ETH_DESTADDR8 : INTEGER := ETH_DESTADDR5 + 1;
CONSTANT ETH_DESTADDR7 : INTEGER := ETH_DESTADDR8 + 1;

CONSTANT ETH_DESTADDR10 : INTEGER := ETH_DESTADDR7 + 1;
CONSTANT ETH_DESTADDR9 : INTEGER := ETH_DESTADDR10 + 1;

CONSTANT ETH_DESTADDR12 : INTEGER := ETH_DESTADDR9 + 1;
CONSTANT ETH_DESTADDR11 : INTEGER := ETH_DESTADDR12 + 1;

CONSTANT ETH_SRCADDR2 : INTEGER := ETH_DESTADDR11 + 1;
CONSTANT ETH_SRCADDR1 : INTEGER := ETH_SRCADDR2 + 1;

CONSTANT ETH_SRCADDR4 : INTEGER := ETH_SRCADDR1 + 1;
CONSTANT ETH_SRCADDR3 : INTEGER := ETH_SRCADDR4 + 1;

CONSTANT ETH_SRCADDR6 : INTEGER := ETH_SRCADDR3 + 1;
CONSTANT ETH_SRCADDR5 : INTEGER := ETH_SRCADDR6 + 1;

CONSTANT ETH_SRCADDR8 : INTEGER := ETH_SRCADDR5 + 1;
CONSTANT ETH_SRCADDR7 : INTEGER := ETH_SRCADDR8 + 1;

CONSTANT ETH_SRCADDR10 : INTEGER := ETH_SRCADDR7 + 1;
CONSTANT ETH_SRCADDR9 : INTEGER := ETH_SRCADDR10 + 1;

CONSTANT ETH_SRCADDR12 : INTEGER := ETH_SRCADDR9 + 1;
CONSTANT ETH_SRCADDR11 : INTEGER := ETH_SRCADDR12 + 1;

CONSTANT ETH_TYPE2 : INTEGER := ETH_SRCADDR11 + 1;
CONSTANT ETH_TYPE1 : INTEGER := ETH_TYPE2 + 1;

CONSTANT ETH_TYPE4 : INTEGER := ETH_TYPE1 + 1;
CONSTANT ETH_TYPE3 : INTEGER := ETH_TYPE4 + 1;


   -- IPv4 Header Offsets

   -- 20Bytes
   -- 0  |0____.____|1____.____|2____.____|3____.____|
   -- 4  | Ver |Leng|Serv Type |     Total Length    |
   -- 8  |    Identification   |Flags|Fragment Offset|
   -- 12 |    TTL   | Protocol | Header Checksum     |
   -- 16 |             Source Address                |
   -- 20 |            Destination Address            |

   CONSTANT ETH_IPV4_IHL : INTEGER := ETH_TYPE3 + 1;
   CONSTANT ETH_IPV4_VER : INTEGER := ETH_IPV4_IHL + 1;
   
   CONSTANT ETH_IPV4_SRVTP2 : INTEGER := ETH_IPV4_VER + 1;
   CONSTANT ETH_IPV4_SRVTP1 : INTEGER := ETH_IPV4_SRVTP2 + 1;
   
   CONSTANT ETH_IPV4_LNG2 : INTEGER := ETH_IPV4_SRVTP1 + 1;
   CONSTANT ETH_IPV4_LNG1 : INTEGER := ETH_IPV4_LNG2 + 1;
   
   CONSTANT ETH_IPV4_LNG4 : INTEGER := ETH_IPV4_LNG1 + 1;
   CONSTANT ETH_IPV4_LNG3 : INTEGER := ETH_IPV4_LNG4 + 1;
   
   CONSTANT ETH_IPV4_ID2 : INTEGER := ETH_IPV4_LNG3 + 1;
   CONSTANT ETH_IPV4_ID1 : INTEGER := ETH_IPV4_ID2 + 1;
   
   CONSTANT ETH_IPV4_ID4 : INTEGER := ETH_IPV4_ID1 + 1;
   CONSTANT ETH_IPV4_ID3 : INTEGER := ETH_IPV4_ID4 + 1;
   
   CONSTANT ETH_IPV4_FRAGOFF1 : INTEGER := ETH_IPV4_ID3 + 1;
   CONSTANT ETH_IPV4_FLG : INTEGER := ETH_IPV4_FRAGOFF1 + 1;
   
   CONSTANT ETH_IPV4_FRAGOFF3 : INTEGER := ETH_IPV4_FLG + 1;
   CONSTANT ETH_IPV4_FRAGOFF2 : INTEGER := ETH_IPV4_FRAGOFF3 + 1;
   
   CONSTANT ETH_IPV4_LIVETIME2 : INTEGER := ETH_IPV4_FRAGOFF2 + 1;
   CONSTANT ETH_IPV4_LIVETIME1 : INTEGER := ETH_IPV4_LIVETIME2 + 1;
   
   CONSTANT ETH_IPV4_PROTOCOL2 : INTEGER := ETH_IPV4_LIVETIME1 + 1;
   CONSTANT ETH_IPV4_PROTOCOL1 : INTEGER := ETH_IPV4_PROTOCOL2 + 1;
   
   CONSTANT ETH_IPV4_HEADERCHKSM2 : INTEGER := ETH_IPV4_PROTOCOL1 + 1;
   CONSTANT ETH_IPV4_HEADERCHKSM1 : INTEGER := ETH_IPV4_HEADERCHKSM2 + 1;
   
   CONSTANT ETH_IPV4_HEADERCHKSM4 : INTEGER := ETH_IPV4_HEADERCHKSM1 + 1;
   CONSTANT ETH_IPV4_HEADERCHKSM3 : INTEGER := ETH_IPV4_HEADERCHKSM4 + 1;
   
   CONSTANT ETH_IPV4_SRCIP2 : INTEGER := ETH_IPV4_HEADERCHKSM3 + 1;
   CONSTANT ETH_IPV4_SRCIP1 : INTEGER := ETH_IPV4_SRCIP2 + 1;
   
   CONSTANT ETH_IPV4_SRCIP4 : INTEGER := ETH_IPV4_SRCIP1 + 1;
   CONSTANT ETH_IPV4_SRCIP3 : INTEGER := ETH_IPV4_SRCIP4 + 1;
   
   CONSTANT ETH_IPV4_SRCIP6 : INTEGER := ETH_IPV4_SRCIP3 + 1;
   CONSTANT ETH_IPV4_SRCIP5 : INTEGER := ETH_IPV4_SRCIP6 + 1;
   
   CONSTANT ETH_IPV4_SRCIP8 : INTEGER := ETH_IPV4_SRCIP5 + 1;
   CONSTANT ETH_IPV4_SRCIP7 : INTEGER := ETH_IPV4_SRCIP8 + 1;
   
   CONSTANT ETH_IPV4_DSTIP2 : INTEGER := ETH_IPV4_SRCIP7 + 1;
   CONSTANT ETH_IPV4_DSTIP1 : INTEGER := ETH_IPV4_DSTIP2 + 1;
   
   CONSTANT ETH_IPV4_DSTIP4 : INTEGER := ETH_IPV4_DSTIP1 + 1;
   CONSTANT ETH_IPV4_DSTIP3 : INTEGER := ETH_IPV4_DSTIP4 + 1;
   
   CONSTANT ETH_IPV4_DSTIP6 : INTEGER := ETH_IPV4_DSTIP3 + 1;
   CONSTANT ETH_IPV4_DSTIP5 : INTEGER := ETH_IPV4_DSTIP6 + 1;
   
   CONSTANT ETH_IPV4_DSTIP8 : INTEGER := ETH_IPV4_DSTIP5 + 1;
   CONSTANT ETH_IPV4_DSTIP7 : INTEGER := ETH_IPV4_DSTIP8 + 1;
   
   CONSTANT ETH_IPV4_PAYLOAD : INTEGER := ETH_IPV4_DSTIP7 + 1;


      -- UDP Header Offsets
      -- 8Bytes
      -- 0  |0____.____|1____.____|2____.____|3____.____|
      -- 4  |    Source Address   | Destination Address |
      -- 8  |        Length       |       Checksum      |
      CONSTANT ETH_IPV4_UDP_SRCADR2 : INTEGER := ETH_IPV4_DSTIP7 + 1;
      CONSTANT ETH_IPV4_UDP_SRCADR1 : INTEGER := ETH_IPV4_UDP_SRCADR2 + 1;
      
      CONSTANT ETH_IPV4_UDP_SRCADR4 : INTEGER := ETH_IPV4_UDP_SRCADR1 + 1;
      CONSTANT ETH_IPV4_UDP_SRCADR3 : INTEGER := ETH_IPV4_UDP_SRCADR4 + 1;
      
      CONSTANT ETH_IPV4_UDP_DSTADR2 : INTEGER := ETH_IPV4_UDP_SRCADR3 + 1;
      CONSTANT ETH_IPV4_UDP_DSTADR1 : INTEGER := ETH_IPV4_UDP_DSTADR2 + 1;
      
      CONSTANT ETH_IPV4_UDP_DSTADR4 : INTEGER := ETH_IPV4_UDP_DSTADR1 + 1;
      CONSTANT ETH_IPV4_UDP_DSTADR3 : INTEGER := ETH_IPV4_UDP_DSTADR4 + 1;
      
      CONSTANT ETH_IPV4_UDP_LENG2 : INTEGER   := ETH_IPV4_UDP_DSTADR3 + 1;
      CONSTANT ETH_IPV4_UDP_LENG1 : INTEGER   := ETH_IPV4_UDP_LENG2 + 1;
      
      CONSTANT ETH_IPV4_UDP_LENG4 : INTEGER   := ETH_IPV4_UDP_LENG1 + 1;
      CONSTANT ETH_IPV4_UDP_LENG3 : INTEGER   := ETH_IPV4_UDP_LENG4 + 1;
      
      CONSTANT ETH_IPV4_UDP_CHKSUM2 : INTEGER := ETH_IPV4_UDP_LENG3 + 1;
      CONSTANT ETH_IPV4_UDP_CHKSUM1 : INTEGER := ETH_IPV4_UDP_CHKSUM2 + 1;
      
      CONSTANT ETH_IPV4_UDP_CHKSUM4 : INTEGER := ETH_IPV4_UDP_CHKSUM1 + 1;
      CONSTANT ETH_IPV4_UDP_CHKSUM3 : INTEGER := ETH_IPV4_UDP_CHKSUM4 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N2 : INTEGER := ETH_IPV4_UDP_CHKSUM3 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N1 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N2 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N4 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N1  + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N3 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N4 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N6 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N3 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N5 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N6 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N8 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N5 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N7 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N8 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N10 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N7 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N9 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N10 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N12 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N9 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N11 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N12 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N14 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N11 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N13 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N14 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N16 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N13 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N15 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N16 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N18 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N15 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N17 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N18 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N20 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N17 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N19 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N20 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N22 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N19 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N21 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N22 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N24 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N21 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N23 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N24 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N26 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N23 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N25 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N26 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N28 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N25 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N27 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N28 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N30 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N27 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N29 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N30 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N32 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N29 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N31 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N32 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N34 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N31 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N33 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N34 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N36 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N33 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N35 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N36 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N38 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N35 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N37 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N38 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N40 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N37 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N39 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N40 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N42 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N39 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N41 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N42 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N44 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N41 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N43 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N44 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N46 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N43 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N45 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N46 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N48 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N45 + 1;
      CONSTANT ETH_IPV4_UDP_PAYLOAD_N47 : INTEGER := ETH_IPV4_UDP_PAYLOAD_N48 + 1;
      
      CONSTANT ETH_IPV4_UDP_PAYLOAD : INTEGER := ETH_IPV4_UDP_PAYLOAD_N47;
      
     
CONSTANT ETH_IPV4_DUP_ENDOFPAYLOAD : INTEGER := ETH_IPV4_UDP_PAYLOAD; -- = (ETH_IPV4_UDP_PAYLOAD) + (UDP Payload size)
CONSTANT ETH_IP_ENDOFPAYLOAD : INTEGER := ETH_IPV4_UDP_PAYLOAD; -- = (ETH_IPV4_UDP_PAYLOAD) + (UDP Payload size)
CONSTANT ETH_PAYLOAD : INTEGER := ETH_IPV4_UDP_PAYLOAD; -- Consider changing this to where CRC begins

CONSTANT ETH_CRC2 : INTEGER := ETH_IPV4_UDP_PAYLOAD + 1;
CONSTANT ETH_CRC1 : INTEGER := ETH_CRC2 + 1;

CONSTANT ETH_CRC4 : INTEGER := ETH_CRC1 + 1;
CONSTANT ETH_CRC3 : INTEGER := ETH_CRC4 + 1;

CONSTANT ETH_CRC6 : INTEGER := ETH_CRC3 + 1;
CONSTANT ETH_CRC5 : INTEGER := ETH_CRC6 + 1;

CONSTANT ETH_CRC8 : INTEGER := ETH_CRC5 + 1;
CONSTANT ETH_CRC7 : INTEGER := ETH_CRC8 + 1;

CONSTANT ETH_END_FRAME : INTEGER := ETH_CRC7 + 1;

CONSTANT ETH_FRAMEGAP : INTEGER := ETH_CRC7 + 24;

----------------------------------------
-- Ethernet frame constructors
----------------------------------------
-- Ethernet Header Constants
CONSTANT ETHPREAMBLE : STD_LOGIC_VECTOR := "1010";
CONSTANT SFD1 : STD_LOGIC_VECTOR := X"5";
CONSTANT SFD2 : STD_LOGIC_VECTOR := X"D";
CONSTANT BROADCAST : STD_LOGIC_VECTOR := X"F";
CONSTANT MAC_DESTADDR1 : STD_LOGIC_VECTOR := X"0";  -- 0 -- 00-1d-92-f3-31-53
CONSTANT MAC_DESTADDR2 : STD_LOGIC_VECTOR := X"0";  -- 0
CONSTANT MAC_DESTADDR3 : STD_LOGIC_VECTOR := X"1";  -- 1
CONSTANT MAC_DESTADDR4 : STD_LOGIC_VECTOR := X"D";  -- D
CONSTANT MAC_DESTADDR5 : STD_LOGIC_VECTOR := X"9";  -- 9
CONSTANT MAC_DESTADDR6 : STD_LOGIC_VECTOR := X"2";  -- 2
CONSTANT MAC_DESTADDR7 : STD_LOGIC_VECTOR := X"F";  -- F
CONSTANT MAC_DESTADDR8 : STD_LOGIC_VECTOR := X"3";  -- 3
CONSTANT MAC_DESTADDR9 : STD_LOGIC_VECTOR := X"3";  -- 3
CONSTANT MAC_DESTADDR10 : STD_LOGIC_VECTOR := X"1";  -- 1
CONSTANT MAC_DESTADDR11 : STD_LOGIC_VECTOR := X"5";  -- 5
CONSTANT MAC_DESTADDR12 : STD_LOGIC_VECTOR := X"3";  -- 3
CONSTANT MAC_SRCADDR1 : STD_LOGIC_VECTOR := X"A";  -- A -- A3-1C-6D-DF-B6-B6
CONSTANT MAC_SRCADDR2 : STD_LOGIC_VECTOR := X"3";  -- 3
CONSTANT MAC_SRCADDR3 : STD_LOGIC_VECTOR := X"1";  -- 1
CONSTANT MAC_SRCADDR4 : STD_LOGIC_VECTOR := X"C";  -- C
CONSTANT MAC_SRCADDR5 : STD_LOGIC_VECTOR := X"6";  -- 6
CONSTANT MAC_SRCADDR6 : STD_LOGIC_VECTOR := X"D";  -- D
CONSTANT MAC_SRCADDR7 : STD_LOGIC_VECTOR := X"D";  -- D
CONSTANT MAC_SRCADDR8 : STD_LOGIC_VECTOR := X"F";  -- F
CONSTANT MAC_SRCADDR9 : STD_LOGIC_VECTOR := X"B";  -- B
CONSTANT MAC_SRCADDR10 : STD_LOGIC_VECTOR := X"6"; -- 6
CONSTANT MAC_SRCADDR11 : STD_LOGIC_VECTOR := X"B"; -- B
CONSTANT MAC_SRCADDR12 : STD_LOGIC_VECTOR := X"6"; -- 6
CONSTANT ETHERTYPE1 : STD_LOGIC_VECTOR := X"0"; -- 0
CONSTANT ETHERTYPE2 : STD_LOGIC_VECTOR := X"8"; -- 8
CONSTANT ETHERTYPE3 : STD_LOGIC_VECTOR := X"0"; -- 0
CONSTANT ETHERTYPE4 : STD_LOGIC_VECTOR := X"0"; -- 0
CONSTANT CRC1 : STD_LOGIC_VECTOR := X"7"; -- bd890fc8 --> http://www.zorc.breitbandkatze.de/crc.html
CONSTANT CRC2 : STD_LOGIC_VECTOR := X"0"; -- d6fe9a4b --> Test bench
CONSTANT CRC3 : STD_LOGIC_VECTOR := X"7";
CONSTANT CRC4 : STD_LOGIC_VECTOR := X"0";
CONSTANT CRC5 : STD_LOGIC_VECTOR := X"A";
CONSTANT CRC6 : STD_LOGIC_VECTOR := X"D";
CONSTANT CRC7 : STD_LOGIC_VECTOR := X"F";
CONSTANT CRC8 : STD_LOGIC_VECTOR := X"C";

-- IPv4 Header Constants
CONSTANT IP_VER : STD_LOGIC_VECTOR := X"4";
CONSTANT IP_IHL : STD_LOGIC_VECTOR := X"5";
CONSTANT IP_SRVTP1 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_SRVTP2 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_LENG1 : STD_LOGIC_VECTOR := X"0"; -- = (20 Byte IP header) + (8 Byte UDP header) + (24 Byte UDP payload) = 52
CONSTANT IP_LENG2 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_LENG3 : STD_LOGIC_VECTOR := X"3";
CONSTANT IP_LENG4 : STD_LOGIC_VECTOR := X"4";
CONSTANT IP_ID : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_FLAGS : STD_LOGIC_VECTOR := X"4"; -- 11:7
CONSTANT IP_OFFSET : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_TTL1 : STD_LOGIC_VECTOR := X"F";
CONSTANT IP_TTL2 : STD_LOGIC_VECTOR := X"F";
CONSTANT IP_PROTOCOL1 : STD_LOGIC_VECTOR := X"1"; -- UDP Protocol ID
CONSTANT IP_PROTOCOL2 : STD_LOGIC_VECTOR := X"1";
CONSTANT IP_HDCHKSUM1 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_HDCHKSUM2 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_HDCHKSUM3 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_HDCHKSUM4 : STD_LOGIC_VECTOR := X"0";
--CONSTANT IP_HDCHKSUM1 : STD_LOGIC_VECTOR := X"E";
--CONSTANT IP_HDCHKSUM2 : STD_LOGIC_VECTOR := X"7";
--CONSTANT IP_HDCHKSUM3 : STD_LOGIC_VECTOR := X"E";
--CONSTANT IP_HDCHKSUM4 : STD_LOGIC_VECTOR := X"D";
CONSTANT IP_SRCIP1 : STD_LOGIC_VECTOR := X"C"; -- IP source is 192
CONSTANT IP_SRCIP2 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_SRCIP3 : STD_LOGIC_VECTOR := X"A"; -- .168
CONSTANT IP_SRCIP4 : STD_LOGIC_VECTOR := X"8";
CONSTANT IP_SRCIP5 : STD_LOGIC_VECTOR := X"8"; -- .137
CONSTANT IP_SRCIP6 : STD_LOGIC_VECTOR := X"9";
CONSTANT IP_SRCIP7 : STD_LOGIC_VECTOR := X"7"; -- .120
CONSTANT IP_SRCIP8 : STD_LOGIC_VECTOR := X"8";
CONSTANT IP_DSTIP1 : STD_LOGIC_VECTOR := X"C"; -- IP destination is 192
CONSTANT IP_DSTIP2 : STD_LOGIC_VECTOR := X"0";
CONSTANT IP_DSTIP3 : STD_LOGIC_VECTOR := X"A"; -- .168
CONSTANT IP_DSTIP4 : STD_LOGIC_VECTOR := X"8";
CONSTANT IP_DSTIP5 : STD_LOGIC_VECTOR := X"8"; -- .137
CONSTANT IP_DSTIP6 : STD_LOGIC_VECTOR := X"9";
CONSTANT IP_DSTIP7 : STD_LOGIC_VECTOR := X"0"; -- .1
CONSTANT IP_DSTIP8 : STD_LOGIC_VECTOR := X"1";
--CONSTANT IP_DSTIP1 : STD_LOGIC_VECTOR := "1111"; -- IP destination is 192
--CONSTANT IP_DSTIP2 : STD_LOGIC_VECTOR := "1111";
--CONSTANT IP_DSTIP3 : STD_LOGIC_VECTOR := "1111"; -- .168
--CONSTANT IP_DSTIP4 : STD_LOGIC_VECTOR := "1111";
--CONSTANT IP_DSTIP5 : STD_LOGIC_VECTOR := "1111"; -- .137
--CONSTANT IP_DSTIP6 : STD_LOGIC_VECTOR := "1111";
--CONSTANT IP_DSTIP7 : STD_LOGIC_VECTOR := "1111"; -- .1
--CONSTANT IP_DSTIP8 : STD_LOGIC_VECTOR := "1111";

-- UDP Header Constants
CONSTANT UDP_SRCADR1 : STD_LOGIC_VECTOR := X"0"; -- Least significant nibble
CONSTANT UDP_SRCADR2 : STD_LOGIC_VECTOR := X"A";
CONSTANT UDP_SRCADR3 : STD_LOGIC_VECTOR := X"0";
CONSTANT UDP_SRCADR4 : STD_LOGIC_VECTOR := X"A"; -- Most significant nibble
CONSTANT UDP_DSTADR1 : STD_LOGIC_VECTOR := X"0";
CONSTANT UDP_DSTADR2 : STD_LOGIC_VECTOR := X"C";
CONSTANT UDP_DSTADR3 : STD_LOGIC_VECTOR := X"0";
CONSTANT UDP_DSTADR4 : STD_LOGIC_VECTOR := X"0";
CONSTANT UDP_LENG1 : STD_LOGIC_VECTOR := X"0"; -- (8Byte header) + (24Byte payload) = 32
CONSTANT UDP_LENG2 : STD_LOGIC_VECTOR := X"0";
CONSTANT UDP_LENG3 : STD_LOGIC_VECTOR := X"2";
CONSTANT UDP_LENG4 : STD_LOGIC_VECTOR := X"0";
CONSTANT UDP_CHKSUM : STD_LOGIC_VECTOR := X"0"; -- 0
CONSTANT UDP_DATA_N1 : STD_LOGIC_VECTOR := X"1";
CONSTANT UDP_DATA_N2 : STD_LOGIC_VECTOR := X"2";
CONSTANT UDP_DATA_N3 : STD_LOGIC_VECTOR := X"3";
CONSTANT UDP_DATA_N4 : STD_LOGIC_VECTOR := X"4";
CONSTANT UDP_DATA_N5 : STD_LOGIC_VECTOR := X"5";
CONSTANT UDP_DATA_N6 : STD_LOGIC_VECTOR := X"6";
CONSTANT UDP_DATA_N7 : STD_LOGIC_VECTOR := X"7";
CONSTANT UDP_DATA_N8 : STD_LOGIC_VECTOR := X"8";
CONSTANT UDP_DATA_N9 : STD_LOGIC_VECTOR := X"9";
CONSTANT UDP_DATA_NA : STD_LOGIC_VECTOR := X"A";
CONSTANT UDP_DATA_NB : STD_LOGIC_VECTOR := X"B";
CONSTANT UDP_DATA_NC : STD_LOGIC_VECTOR := X"C";
CONSTANT UDP_DATA_ND : STD_LOGIC_VECTOR := X"D";
CONSTANT UDP_DATA_NE : STD_LOGIC_VECTOR := X"E";
CONSTANT UDP_DATA_NF : STD_LOGIC_VECTOR := X"F";
CONSTANT UDP_DATA_N0 : STD_LOGIC_VECTOR := X"0";

CONSTANT END_OF_TX1 : STD_LOGIC_VECTOR := "01101";
CONSTANT END_OF_TX2 : STD_LOGIC_VECTOR := "00111";
   
---------------------------------------------------------------------------------
begin
   TXEN <= TxEn_i;
   TXER_TX4 <= '0';
   TXD(3 downto 0) <= TxD_i(3 downto 0);
   
   D_BUG(0) <= CLK100;
   D_BUG(1) <= Clk_25;
   D_BUG(2) <= TXCLK;
   D_BUG(3) <= d_bug_i;

---------------------------------------------------------------------------------
process(CLK100, Clk_50, Clk_25)
begin
   if(CLK100'event and CLK100 = '1') then
      Clk_50 <= not Clk_50;
      if(Clk_50'event and Clk_50 = '1') then
         Clk_25 <= not Clk_25;
      else
         null;
      end if;
   else
      null;
   end if;
end process;
---------------------------------------------------------------------------------
process(CE, EthCounter, TXCLK)
CONSTANT STARTOFCOUNTER : INTEGER := 0;
CONSTANT ENDOFCOUNTER : INTEGER := (ETH_FRAMEGAP + 12000);
begin
   if(CE = '0') then
      EthCounter <= STARTOFCOUNTER;
   elsif(TXCLK'event and TXCLK = '0') then
      if(EthCounter = ENDOFCOUNTER) then
         EthCounter <= STARTOFCOUNTER;
      else
         EthCounter <= EthCounter + 1;
      end if;
   end if;
end process;
---------------------------------------------------------------------------------
process(ChipState, ChipSNext, EthCounter)
variable cnt : INTEGER := 0;
begin
   case ChipState is
      ------------------------------------------------
      -- Main Operation
      ------------------------------------------------
      -- Wait for chip initialization
      when ENABLE =>
         TxEN_i <= '0';
         TxD_i <= "0000";
         
      ------------------------------------------------
      -- Send Ethernet Frame
      when RUN =>
         
         if((EthCounter >= ETH_END_FRAME)
               or (EthCounter <= 0)) then
            TxEn_i <= '0';
         else
            TxEN_i <= '1';
         end if;
         
         
         if(EthCounter <= ETH_SFD1) then
            TxD_i <= SFD1;
         elsif(EthCounter = ETH_SFD2) then
            TxD_i <= SFD2;
--         elsif(EthCounter = ETH_SFD3) then
--            TxD_i <= SFD1;
            
         elsif(EthCounter <= ETH_DESTADDR1) then
            TxD_i<= MAC_DESTADDR1;
         elsif(EthCounter = ETH_DESTADDR2) then
            TxD_i<= MAC_DESTADDR2;
         elsif(EthCounter = ETH_DESTADDR3) then
            TxD_i<= MAC_DESTADDR3;
         elsif(EthCounter = ETH_DESTADDR4) then
            TxD_i<= MAC_DESTADDR4;
         elsif(EthCounter = ETH_DESTADDR5) then
            TxD_i<= MAC_DESTADDR5;
         elsif(EthCounter = ETH_DESTADDR6) then
            TxD_i<= MAC_DESTADDR6;
         elsif(EthCounter = ETH_DESTADDR7) then
            TxD_i<= MAC_DESTADDR7;
         elsif(EthCounter = ETH_DESTADDR8) then
            TxD_i<= MAC_DESTADDR8;
         elsif(EthCounter = ETH_DESTADDR9) then
            TxD_i<= MAC_DESTADDR9;
         elsif(EthCounter = ETH_DESTADDR10) then
            TxD_i<= MAC_DESTADDR10;
         elsif(EthCounter = ETH_DESTADDR11) then
            TxD_i<= MAC_DESTADDR11;
         elsif(EthCounter = ETH_DESTADDR12) then
            TxD_i<= MAC_DESTADDR12;
            
         elsif(EthCounter = ETH_SRCADDR1) then
            TxD_i<= MAC_SRCADDR1;
         elsif(EthCounter = ETH_SRCADDR2) then
            TxD_i<= MAC_SRCADDR2;
         elsif(EthCounter = ETH_SRCADDR3) then
            TxD_i<= MAC_SRCADDR3;
         elsif(EthCounter = ETH_SRCADDR4) then
            TxD_i<= MAC_SRCADDR4;
         elsif(EthCounter = ETH_SRCADDR5) then
            TxD_i<= MAC_SRCADDR5;
         elsif(EthCounter = ETH_SRCADDR6) then
            TxD_i<= MAC_SRCADDR6;
         elsif(EthCounter = ETH_SRCADDR7) then
            TxD_i<= MAC_SRCADDR7;
         elsif(EthCounter = ETH_SRCADDR8) then
            TxD_i<= MAC_SRCADDR8;
         elsif(EthCounter = ETH_SRCADDR9) then
            TxD_i<= MAC_SRCADDR9;
         elsif(EthCounter = ETH_SRCADDR10) then
            TxD_i<= MAC_SRCADDR10;
         elsif(EthCounter = ETH_SRCADDR11) then
            TxD_i<= MAC_SRCADDR11;
         elsif(EthCounter = ETH_SRCADDR12) then
            TxD_i<= MAC_SRCADDR12;
            
         elsif(EthCounter = ETH_TYPE1) then
            TxD_i<= ETHERTYPE1;
         elsif(EthCounter = ETH_TYPE2) then
            TxD_i<= ETHERTYPE2;
         elsif(EthCounter = ETH_TYPE3) then
            TxD_i<= ETHERTYPE3;
         elsif(EthCounter = ETH_TYPE4) then
            TxD_i<= ETHERTYPE4;
         elsif(EthCounter <= ETH_PAYLOAD) then
            
            --------------------------------------------------------------------
            -- CONSTRUCT IP HEADER
            --------------------------------------------------------------------
            if(EthCounter = ETH_IPV4_VER) then
               TxD_i<= IP_VER;
               
            elsif(EthCounter = ETH_IPV4_IHL) then
               TxD_i<= IP_IHL;
               
            elsif(EthCounter = ETH_IPV4_SRVTP1 or EthCounter = ETH_IPV4_SRVTP2) then
               TxD_i<= IP_SRVTP1;
               
            elsif(EthCounter = ETH_IPV4_LNG1) then
               TxD_i<= IP_LENG1;
            elsif(EthCounter = ETH_IPV4_LNG2) then
               TxD_i<= IP_LENG2;
            elsif(EthCounter = ETH_IPV4_LNG3) then
               TxD_i<= IP_LENG3;
            elsif(EthCounter = ETH_IPV4_LNG4) then
               TxD_i<= IP_LENG4;
               
            elsif(EthCounter = ETH_IPV4_ID1) then
               TxD_i<= IP_ID;
            elsif(EthCounter = ETH_IPV4_ID2) then
               TxD_i<= IP_ID;
            elsif(EthCounter = ETH_IPV4_ID3) then
               TxD_i<= IP_ID;
            elsif(EthCounter = ETH_IPV4_ID4) then
               TxD_i<= IP_ID;
               
            elsif(EthCounter = ETH_IPV4_FLG) then
               TxD_i<= IP_FLAGS;
               
            elsif(EthCounter >= ETH_IPV4_FRAGOFF1 and ETHCOUNTER <= ETH_IPV4_FRAGOFF3) then
               TxD_i<= IP_OFFSET;
               
            elsif(EthCounter = ETH_IPV4_LIVETIME1) then
               TxD_i<= IP_TTL1;
            elsif(EthCounter = ETH_IPV4_LIVETIME2) then
               TxD_i<= IP_TTL2;
               
            elsif(EthCounter = ETH_IPV4_PROTOCOL1) then
               TxD_i<= IP_PROTOCOL1;
            elsif(EthCounter = ETH_IPV4_PROTOCOL2) then
               TxD_i<= IP_PROTOCOL2;
               
            elsif(EthCounter = ETH_IPV4_HEADERCHKSM1) then
               TxD_i<= IP_HDCHKSUM1;
            elsif(EthCounter = ETH_IPV4_HEADERCHKSM2) then
               TxD_i<= IP_HDCHKSUM2;
            elsif(EthCounter = ETH_IPV4_HEADERCHKSM3) then
               TxD_i<= IP_HDCHKSUM3;
            elsif(EthCounter = ETH_IPV4_HEADERCHKSM4) then
               TxD_i<= IP_HDCHKSUM4;
               
            elsif(EthCounter = ETH_IPV4_SRCIP1) then
               TxD_i<= IP_SRCIP1;
            elsif(EthCounter = ETH_IPV4_SRCIP2) then
               TxD_i<= IP_SRCIP2;
            elsif(EthCounter = ETH_IPV4_SRCIP3) then
               TxD_i<= IP_SRCIP3;
            elsif(EthCounter = ETH_IPV4_SRCIP4) then
               TxD_i<= IP_SRCIP4;
            elsif(EthCounter = ETH_IPV4_SRCIP5) then
               TxD_i<= IP_SRCIP5;
            elsif(EthCounter = ETH_IPV4_SRCIP6) then
               TxD_i<= IP_SRCIP6;
            elsif(EthCounter = ETH_IPV4_SRCIP7) then
               TxD_i<= IP_SRCIP7;
            elsif(EthCounter = ETH_IPV4_SRCIP8) then
               TxD_i<= IP_SRCIP8;
               
            elsif(EthCounter = ETH_IPV4_DSTIP1) then
               TxD_i<= IP_DSTIP1;
            elsif(EthCounter = ETH_IPV4_DSTIP2) then
               TxD_i<= IP_DSTIP2;
            elsif(EthCounter = ETH_IPV4_DSTIP3) then
               TxD_i<= IP_DSTIP3;
            elsif(EthCounter = ETH_IPV4_DSTIP4) then
               TxD_i<= IP_DSTIP4;
            elsif(EthCounter = ETH_IPV4_DSTIP5) then
               TxD_i<= IP_DSTIP5;
            elsif(EthCounter = ETH_IPV4_DSTIP6) then
               TxD_i<= IP_DSTIP6;
            elsif(EthCounter = ETH_IPV4_DSTIP7) then
               TxD_i<= IP_DSTIP7;
            elsif(EthCounter = ETH_IPV4_DSTIP8) then
               TxD_i<= IP_DSTIP8;
               
            elsif(EthCounter >= ETH_IPV4_PAYLOAD and EthCounter <= ETH_IP_ENDOFPAYLOAD) then
            
               --------------------------------------------------------------------
               -- CONSTRUCT UDP HEADER
               --------------------------------------------------------------------
               if(EthCounter = ETH_IPV4_UDP_SRCADR1) then
                  TxD_i<= UDP_SRCADR1;
               elsif(EthCounter = ETH_IPV4_UDP_SRCADR2) then
                  TxD_i<= UDP_SRCADR2;
               elsif(EthCounter = ETH_IPV4_UDP_SRCADR3) then
                  TxD_i<= UDP_SRCADR3;
               elsif(EthCounter = ETH_IPV4_UDP_SRCADR4) then
                  TxD_i<= UDP_SRCADR4;
                  
               elsif(EthCounter = ETH_IPV4_UDP_DSTADR1) then
                  TxD_i<= UDP_DSTADR1;
               elsif(EthCounter = ETH_IPV4_UDP_DSTADR2) then
                  TxD_i<= UDP_DSTADR2;
               elsif(EthCounter = ETH_IPV4_UDP_DSTADR3) then
                  TxD_i<= UDP_DSTADR3;
               elsif(EthCounter = ETH_IPV4_UDP_DSTADR4) then
                  TxD_i<= UDP_DSTADR4;
                  
               elsif(EthCounter = ETH_IPV4_UDP_LENG1) then
                  TxD_i<= UDP_LENG1;
               elsif(EthCounter = ETH_IPV4_UDP_LENG2) then
                  TxD_i<= UDP_LENG2;
               elsif(EthCounter = ETH_IPV4_UDP_LENG3) then
                  TxD_i<= UDP_LENG3;
               elsif(EthCounter = ETH_IPV4_UDP_LENG4) then
                  TxD_i<= UDP_LENG4;
                  
               elsif(EthCounter = ETH_IPV4_UDP_CHKSUM1) then
                  TxD_i<= UDP_CHKSUM;
               elsif(EthCounter = ETH_IPV4_UDP_CHKSUM2) then
                  TxD_i<= UDP_CHKSUM;
               elsif(EthCounter = ETH_IPV4_UDP_CHKSUM3) then
                  TxD_i<= UDP_CHKSUM;
               elsif(EthCounter = ETH_IPV4_UDP_CHKSUM4) then
                  TxD_i<= UDP_CHKSUM;
                  
               -- UDP Data
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N1) then
                  TxD_i<= UDP_DATA_N1;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N2) then
                  TxD_i<= UDP_DATA_N2;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N3) then
                  TxD_i<= UDP_DATA_N3;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N4) then
                  TxD_i<= UDP_DATA_N4;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N5) then
                  TxD_i<= UDP_DATA_N5;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N6) then
                  TxD_i<= UDP_DATA_N6;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N7) then
                  TxD_i<= UDP_DATA_N7;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N8) then
                  TxD_i<= UDP_DATA_N8;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N9) then
                  TxD_i<= UDP_DATA_N9;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N10) then
                  TxD_i<= UDP_DATA_NA;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N11) then
                  TxD_i<= UDP_DATA_NB;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N12) then
                  TxD_i<= UDP_DATA_NC;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N13) then
                  TxD_i<= UDP_DATA_ND;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N14) then
                  TxD_i<= UDP_DATA_NE;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N15) then
                  TxD_i<= UDP_DATA_NF;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N16) then
                   TxD_i<= UDP_DATA_N0;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N17) then
                  TxD_i<= UDP_DATA_N1;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N18) then
                  TxD_i<= UDP_DATA_N2;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N19) then
                  TxD_i<= UDP_DATA_N3;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N20) then
                   TxD_i<= UDP_DATA_N4;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N21) then
                  TxD_i<= UDP_DATA_N5;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N22) then
                  TxD_i<= UDP_DATA_N6;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N23) then
                  TxD_i<= UDP_DATA_N7;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N24) then
                  TxD_i<= UDP_DATA_N8;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N25) then
                  TxD_i<= UDP_DATA_N9;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N26) then
                  TxD_i<= UDP_DATA_NA;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N27) then
                  TxD_i<= UDP_DATA_NB;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N28) then
                   TxD_i<= UDP_DATA_NC;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N29) then
                  TxD_i<= UDP_DATA_ND;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N30) then
                  TxD_i<= UDP_DATA_NE;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N31) then
                  TxD_i<= UDP_DATA_NF;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N32) then
                  TxD_i<= UDP_DATA_N0;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N33) then
                  TxD_i<= UDP_DATA_N1;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N34) then
                  TxD_i<= UDP_DATA_N2;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N35) then
                  TxD_i<= UDP_DATA_N3;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N36) then
                  TxD_i<= UDP_DATA_N4;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N37) then
                  TxD_i<= UDP_DATA_N5;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N38) then
                  TxD_i<= UDP_DATA_N6;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N39) then
                  TxD_i<= UDP_DATA_N7;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N40) then
                  TxD_i<= UDP_DATA_N8;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N41) then
                  TxD_i<= UDP_DATA_N9;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N42) then
                  TxD_i<= UDP_DATA_NA;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N43) then
                  TxD_i<= UDP_DATA_NB;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N44) then
                  TxD_i<= UDP_DATA_NC;
                  
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N45) then
                  TxD_i<= UDP_DATA_ND;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N46) then
                  TxD_i<= UDP_DATA_NE;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N47) then
                  TxD_i<= UDP_DATA_NF;
               elsif(EthCounter = ETH_IPV4_UDP_PAYLOAD_N48) then
                  TxD_i<= UDP_DATA_N0;
               else
                  null;
               end if; -- End of UDP header
            end if; -- End of IPv4 header
            
         elsif(EthCounter = ETH_CRC1) then
            TxD_i<= CRC1;
         elsif(EthCounter = ETH_CRC2) then
            TxD_i<= CRC2;
         elsif(EthCounter = ETH_CRC3) then
            TxD_i<= CRC3;
         elsif(EthCounter = ETH_CRC4) then
            TxD_i<= CRC4;
         elsif(EthCounter = ETH_CRC5) then
            TxD_i<= CRC5;
         elsif(EthCounter = ETH_CRC6) then
            TxD_i<= CRC6;
         elsif(EthCounter = ETH_CRC7) then
            TxD_i<= CRC7;
         elsif(EthCounter = ETH_CRC8) then
            TxD_i<= CRC8;
         elsif(EthCounter = ETH_FRAMEGAP) then
            TxD_i<= "0000";
         else
            null;
         
         end if; -- End of ethernet frame
         
      ------------------------------------------------
      -- Frame Gap - Wait 12 Bytes
      when FRAMEGAP =>
         TxEN_i <= '0';
            
      ------------------------------------------------
      ------------------------------------------------
      -- Handle Exceptions
      when others =>
      
   end case;
end process;
--------------------------------------------------------------------------------
end Behavioral;

