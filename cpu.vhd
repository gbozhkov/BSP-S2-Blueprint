----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2023 17:11:49
-- Design Name: 
-- Module Name: cpu - Behavioral
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
use IEEE.std_logic_unsigned.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
--  Port ( );
Port(
--debug : OUT std_logic_vector (255 downto 0);
clk, rst : IN std_logic; 
addr : OUT std_logic_vector(15 downto 0); -- Add this port if missing
datard : IN std_logic_vector(7 downto 0);
datawr : OUT std_logic_vector(7 downto 0);
wr : OUT std_logic;
state : BUFFER std_logic_vector(3 downto 0); -- Add this port
halt : IN std_logic -- Add this port
);
end cpu;

architecture Behavioral of cpu is
SIGNAL PCM, PCL, addrM, addrL, IRM, IRC, IRL : std_logic_vector(7 downto 0);
TYPE regtype is ARRAY (integer range <>) of std_logic_vector(7 downto 0);
SIGNAL reg : regtype(0 to 7);
--SIGNAL deb : regtype(0 to 17);
SIGNAL datawri : std_logic_vector(7 downto 0);
SIGNAL wri : std_logic;
SIGNAL aluoper1,aluoper2,alures,aluflagin : std_logic_vector(7 downto 0);
SIGNAL aluflag : std_logic_vector(3 downto 0);

begin

p:process(clk,rst) begin
if rst='1' then state<=x"0";
elsif clk'event and clk='1' then
case state is
when x"0" => PCM<=x"00"; PCL<=x"00"; addrM<=x"00"; addrL<=x"00"; wri<='0'; state<=x"1"; 
when x"1" => IRM<=datard; addrL<=PCL+1; PCL<=PCL+1; 
     if datard(7)='0' or datard(6 downto 5)="00" then state<=x"4"; else state<=x"2"; end if;
     if datard(7 downto 3)="10000" then addrM<=reg(6); addrL<=reg(7); wri<='0'; end if;
     if datard(7 downto 3)="10001" then addrM<=reg(6); addrL<=reg(7); datawri<=reg(to_integer(unsigned(datard(2 downto 0)))); wri<='1'; end if;
     if datard(7 downto 6)="01" then aluoper2<=reg(to_integer(unsigned(datard(5 downto 3)))); end if;
when x"2" => IRC<=datard; PCL<=PCL+1; addrL<=PCL+1;   
     if IRM(6 downto 5)="10" or IRM(6 downto 5)="01" then state<=x"4"; else state<=x"3"; end if;
     if IRM(7 downto 3)="11000" then addrM<=reg(6); addrL<=datard; wri<='0'; end if;
     if IRM(7 downto 3)="11001" then addrM<=reg(6); addrL<=datard; datawri<=reg(to_integer(unsigned(IRM(2 downto 0)))); wri<='1'; end if;
     if IRM(7 downto 3)="10101" then aluoper2<=datard; end if; 
when x"3" => IRL<=datard; PCL<=PCL+1; addrL<=PCL+1; state<=x"4";
     if IRM(7 downto 3)="11100" then addrM<=IRC; addrL<=datard; wri<='0'; end if;
     if IRM(7 downto 3)="11101" then addrM<=IRC; addrL<=datard; datawri<=reg(to_integer(unsigned(IRM(2 downto 0)))); wri<='1'; end if;
when x"4" => addrm<=PCM; addrL<=PCL; wri<='0'; state<=x"1";  
     if IRM(7 downto 6)="00" and IRM(5 downto 3)/=IRM(2 downto 0) then reg(to_integer(unsigned(IRM(2 downto 0))))<=reg(to_integer(unsigned(IRM(5 downto 3)))); end if;
     if IRM(7)='1' and IRM(4 downto 3)="00" and IRM(6 downto 5)/="01" then reg(to_integer(unsigned(IRM(2 downto 0))))<=datard; end if; 
     if IRM(7)='1' and IRM(4 downto 3)="00" and IRM(6 downto 5) ="01" then reg(to_integer(unsigned(IRM(2 downto 0))))<=IRC; end if; 
     if (IRM(7 downto 6)="01" or IRM(7 downto 3)="10101") and IRM(2 downto 0)/="010" then reg(0)<=alures; end if;
     if IRM(7 downto 6)="01" or IRM(7 downto 3)="10101" then reg(1)(3 downto 0)<=aluflag; end if;
     if IRM(7 downto 3)="10011" and (IRM(2 downto 0)="000" or reg(1)(to_integer(unsigned(IRM(1 downto 0))))=IRM(2)) then PCL<=reg(7); addrL<=reg(7); PCM<=reg(6); addrM<=reg(6); end if;
     if IRM(7 downto 3)="10111" and (IRM(2 downto 0)="000" or reg(1)(to_integer(unsigned(IRM(1 downto 0))))=IRM(2)) then PCL<=PCL+IRC; addrL<=PCL+IRC; end if;
     if IRM(7 downto 3)="11011" and (IRM(2 downto 0)="000" or reg(1)(to_integer(unsigned(IRM(1 downto 0))))=IRM(2)) then PCL<=IRC; addrL<=IRC; end if;
     if IRM(7 downto 3)="11111" and (IRM(2 downto 0)="000" or reg(1)(to_integer(unsigned(IRM(1 downto 0))))=IRM(2)) then PCL<=IRL; addrL<=IRL; PCM<=IRC; addrM<=IRC; end if;
     
when others => null;
end case;
end if; end process;

addr <= addrM & addrL;
datawr <= datawri; wr <= wri;
aluoper1 <= reg(0); aluflagin <= reg(1);

palu: process(aluoper1,aluoper2,IRM,aluflagin) 
VARIABLE v1,v2,vr : std_logic_vector(9 downto 0);
begin
v1 := '0' & aluoper1(7) & aluoper1; 
v2 := '0' & aluoper2(7) & aluoper2;
vr := v1;
case IRM(2 downto 0) IS   
when "000" => vr := v1+v2;
when "001" | "010" => vr := v1-v2;
when "100" => vr := v1 and v2;
when "101" => vr := v1 or v2;
when "110" => vr := v1 xor v2;
when "011" => vr := "00" & x"00";
when "111" =>
case IRM(5 downto 3) IS
when "000" => vr := 0-v1;
when "001" => vr := not v1;
when "010" => vr := v1+1;
when "011" => vr := v1-1;
when "100" => vr(7 downto 1) := v1(6 downto 0); vr(0) := v1(7); 
when "101" => vr(6 downto 0) := v1(7 downto 1); vr(7) := v1(0);  
when "110" => vr(7 downto 1) := v1(6 downto 0); vr(0) := '0'; 
when "111" => vr(7 downto 0) := v1(8 downto 1);     
when others => null;
end case;
when others => null;
end case;
alures<=vr(7 downto 0);
aluflag(0)<=vr(9);
if vr(7 downto 0)=x"00" then aluflag(1)<='1'; else aluflag(1)<='0'; end if;
aluflag(2)<=vr(7);
aluflag(3)<=vr(8) xor vr(7);

end process;
-- debug
--deb(0) <= "000" & wri & state;
--deb(1) <= IRM;
--deb(2) <= IRC;
--deb(3) <= IRL;
--deb(4) <= PCM;
--deb(5) <= PCL;
--deb(6) <= addrM;
--deb(7) <= addrL;
--deb(8) <= datawri; 
--deb(9) <= datard;
--deb(10 to 17) <= reg(0 to 7);

--debug <= deb(0) & deb(1) & deb(2) & deb(3) & deb(4) & deb(5) & deb(6) & deb(7)
-- & deb(8) & deb(9) & x"1111222233334444555566667777" 
-- & deb(10) & deb(11) & deb(12) & deb(13) & deb(14) & deb(15) & deb(16) & deb(17)  ;

end Behavioral;
