--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--------------------------------------------------------------------------------
entity CamDataAddressManager is
   generic(
             N : integer := 8
          );
   port(
          ARST_in : in std_logic;
          CLK_in : in std_logic; -- Used for counting
          ADDRESS_out : out std_logic_vector( N-1 downto 0 ) := (others => '0')
       );
end CamDataAddressManager;

--------------------------------------------------------------------------------
architecture Behavioral of CamDataAddressManager is

--------------------------------------------------------------------------------
-- Constant Declarations
--
   constant MAXCOUNTSIZE : integer := 2;
   constant MEMADDRBUSSIZE :integer := 26;

--------------------------------------------------------------------------------
-- Signal Assignments
--
   signal CountOut_i : std_logic_vector( MEMADDRBUSSIZE-1 downto 0);
   signal DataAddressCounter_i : std_logic_vector( MAXCOUNTSIZE-1 downto 0 );
   signal ResetCounter_i : std_logic := '0';
   signal AddressOut_i : std_logic_vector( N*2-1 downto 0 );

--------------------------------------------------------------------------------
-- Hardware Components
--
   component Counter is
      generic(
               N : integer
             );
      port(
            EN_in : in std_logic;
            CLK_in : in std_logic;
            RST_in : in std_logic;
            COUNT_OUT : out std_logic_vector( N-1 downto 0 )
          );
   end component;

   component Comparator is
      generic(
               WIDTH_g : integer
             );
      port(
            A_in : in std_logic_vector( WIDTH_g-1 downto 0);
            B_in : in std_logic_vector( WIDTH_g-1 downto 0);
            EQ : out std_logic;
            NEQ : out std_logic;
            LT : out std_logic;
            LTE : out std_logic;
            GT : out std_logic;
            GTE : out std_logic
          );
   end component;

   component Multiplier is
      generic(
                N : integer := 8
             );
      port(
             A_in : in std_logic_vector( N-1 downto 0 );
             B_in : in std_logic_vector( N-1 downto 0); -- Used for counting
             Y_out : out std_logic_vector( 2*N-1 downto 0 ) := (others => '0')
          );
   end component;

--------------------------------------------------------------------------------
-- Signal Assignments
--
begin
   ADDRESS_out <= AddressOut_i( N-1 downto 0 );

--------------------------------------------------------------------------------
-- Connection Description
--
   Cnt1: Counter
   generic map(
                 N => MAXCOUNTSIZE
              )
   port map(
              EN_in => '1', 
              CLK_in => CLK_in,
              RST_in => ResetCounter_i or ARST_in,
              COUNT_OUT => DataAddressCounter_i
           );

   Cmp1: Comparator
   generic map(
                 WIDTH_g => MAXCOUNTSIZE
              )
   port map(
              A_in => DataAddressCounter_i,
              B_in => CONV_STD_LOGIC_VECTOR(2, MAXCOUNTSIZE),
              EQ => ResetCounter_i,
              NEQ => open,
              LT => open,
              LTE => open,
              GT => open,
              GTE => open
           );

   ComparatorCounter: Counter
   generic map(
                 N => MEMADDRBUSSIZE
              )
   port map(
              EN_in => '1', 
              CLK_in => ResetCounter_i,
              RST_in => ARST_in,
              COUNT_OUT => CountOut_i
           );

   Mult1: Multiplier
   generic map(
                 26
              )
   port map(
              A_in => CountOut_i,
              B_in => conv_std_logic_vector( 4, 26 ),
              Y_out => AddressOut_i
           );

--------------------------------------------------------------------------------
end Behavioral;
