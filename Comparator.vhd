---------------------------------------------------------------------------------
-- Comparator.vhd
--
-- Found this example in "Digital Design and Computer Architecutre" by Harris
--   and Harris
--
-- Combinational logic implementation of a comparator
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.EthConstants.ALL;
---------------------------------------------------------------------------------
entity Comparator is
  generic(
           WIDTH_g : integer := 8
         );
  port(
        A_in : in std_logic_vector( WIDTH_g-1 downto 0);
        B_in : in std_logic_vector( WIDTH_g-1 downto 0);
        EQ : out std_logic := '0';
        NEQ : out std_logic := '0';
        LT : out std_logic := '0';
        LTE : out std_logic := '0';
        GT : out std_logic := '0';
        GTE : out std_logic := '0'
      );
end Comparator;

---------------------------------------------------------------------------------
architecture Behavioral of Comparator is

---------------------------------------------------------------------------------
-- Combinational logic description
begin
  EQ  <= '1' when ( A_in = B_in )  else '0';
  NEQ <= '1' when ( A_in /= B_in ) else '0';
  LT  <= '1' when ( A_in < B_in )  else '0';
  LTE <= '1' when ( A_in <= B_in ) else '0';
  GT  <= '1' when ( A_in > B_in )  else '0';
  GTE <= '1' when ( A_in >= B_in ) else '0';

---------------------------------------------------------------------------------
end Behavioral;
