----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2023 01:34:23
-- Design Name: 
-- Module Name: interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use IEEE.std_logic_unsigned.ALL;

entity interface is
--  Port ( );
Port (
clk,rst : IN std_logic;
data : IN std_logic_vector(15 downto 0);
segm : OUT std_logic_vector(7 downto 0);
common : OUT std_logic_vector(3 downto 0);
butin : IN std_logic_vector(3 downto 0);
butout : OUT std_logic_vector(3 downto 0)
);
end interface;

architecture Behavioral of interface is
SIGNAL clkdiv: std_logic_vector(15 downto 0);
SIGNAL clkdig,clkbut : std_logic;
SIGNAL thisdig,commi : std_logic_vector(3 downto 0);
begin
pclkdiv: process (clk) begin
if clk'event and clk='1' then
clkdiv <= clkdiv+1;
end if; end process;
clkdig <= clkdiv(15);
clkbut <= clkdiv(15);

pbutt: process (clkbut) begin
if clkbut'event and clkbut='1' then
butout <= butin;
end if; end process;

pdigits: process (clkdig) begin
if clkdig'event and clkdig='1' then
case commi is 
when "0111" => commi <= "1110"; thisdig <= data( 3 downto  0);
when "1110" => commi <= "1101"; thisdig <= data( 7 downto  4);
when "1101" => commi <= "1011"; thisdig <= data(11 downto  8);
when "1011" => commi <= "0111"; thisdig <= data(15 downto 12);
when others => commi <= "1110"; thisdig <= data( 3 downto  0);
end case;
end if; end process;

common <= commi;
segm <=
x"40" when thisdig = x"0" else
x"79" when thisdig = x"1" else
x"24" when thisdig = x"2" else
x"30" when thisdig = x"3" else
x"19" when thisdig = x"4" else
x"12" when thisdig = x"5" else
x"02" when thisdig = x"6" else
x"78" when thisdig = x"7" else
x"00" when thisdig = x"8" else
x"10" when thisdig = x"9" else
x"08" when thisdig = x"a" else
x"03" when thisdig = x"b" else
x"46" when thisdig = x"c" else
x"21" when thisdig = x"d" else
x"06" when thisdig = x"e" else
x"0e" when thisdig = x"f" else
x"ff";

end Behavioral;
