---------------------------------------------------------------------------------
-- Mux_TwoToOne.vhd
--
-- Variable width combinational logic implementation of a 2:1 multiplexer
--
-- Written By: Andrew Fitzsimons
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
---------------------------------------------------------------------------------
entity MuxTwoToOne is
   generic(
             N : integer := 8
          );
   port(
         A_in : in std_logic_vector( N-1 downto 0);
         B_in : in std_logic_vector( N-1 downto 0);
         SELECT_in : in std_logic;
         Y_out : out std_logic_vector( N-1 downto 0) := (others => 'Z')
       );
end MuxTwoToOne;

---------------------------------------------------------------------------------
architecture Behavioral of MuxTwoToOne is
   signal i : integer;
   signal x : std_logic_vector( N-1 downto 0 );

---------------------------------------------------------------------------------
-- Combinational logic description
begin
   Y_out <= A_in when SELECT_in = '0' else B_in;

---------------------------------------------------------------------------------
end Behavioral;
