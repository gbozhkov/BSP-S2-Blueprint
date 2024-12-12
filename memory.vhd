----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.11.2023 16:46:04
-- Design Name: 
-- Module Name: memory - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory is
--  Port ( );
PORT (
clk, rst : IN std_logic;
addr : IN std_logic_vector(15 downto 0);
datawr : IN std_logic_vector(7 downto 0);
datard : OUT std_logic_vector(7 downto 0);
wr : IN std_logic; -- 1 = write, 0 = read
sw : IN std_logic_vector(15 downto 0);
buttons : IN std_logic_vector(3 downto 0);
led : OUT std_logic_vector(15 downto 0);
digits : OUT std_logic_vector(15 downto 0)
);
end memory;

architecture Behavioral of memory is
TYPE ram_type is ARRAY (integer range <>) of std_logic_vector(7 downto 0);
SIGNAL ram : ram_type(0 to 8191);

SIGNAL memoryrd : std_logic_vector(7 downto 0);
SIGNAL page0 : ram_type (0 to 255);
SIGNAL ledi,digitsi : std_logic_vector(15 downto 0);
SIGNAL speciali,special : std_logic_vector(7 downto 0);
SIGNAL page0rd : std_logic_vector(7 downto 0);

begin
pread:process(clk) begin
if clk'event and clk='0' then
 memoryrd <= ram(to_integer(unsigned(addr)));
end if; end process; 
--memoryrd <= ram(to_integer(unsigned(addr)));


pwrite:process(clk) begin
if clk'event and clk='1' then
 if wr='1' then ram(to_integer(unsigned(addr))) <= datawr; end if;
end if; end process;  

-- page 0 : 
-- 0 to 247: bios
-- 248, 249 : leds 
-- 250 : special
-- 251, 252 : digits (7 seg)
-- 253, 254 : switches
-- 255 ; boutons
page0rd <= page0(to_integer(unsigned(addr(7 downto 0))));
datard <=  page0rd when addr(15 downto 8)=x"00" else memoryrd;
led <= ledi;
digits <= digitsi;
special <= speciali;

page0(0 to 247) <= (
-- init
x"d8", x"75",-- 00: jumpabs 75 11011000 
x"d8", x"97",-- 02 : jump auxil program
x"00", -- 04: NOP
--x"a0", x"00", -- 00: ld r0,0 10100000 
--x"07", -- 02: mov r0,r7 00000111
--x"57", -- 03: inc 01010111
--x"06", -- 04: mov r0,r6 
-- display addr
x"ee", x"00", x"fb", -- 05: st r6,[00fb] 11101110
x"ef", x"00", x"fc", -- 08: st r7,[00fc] 
-- loop wait for keypressed
x"e0", x"00",x"ff", -- 0b: ld r0,[00ff] 1110000
x"aa", x"04", -- 0e: cmp 04 10101010 
x"dd", x"27", -- 10: jmp z 11011101  dec lsb subroutine
x"aa", x"05", -- 12: cmp 05
x"dd", x"2c", -- 14: jmp z dec msb subroutine
x"aa", x"02", -- 16: cmp 02
x"dd", x"31", -- 18: jmp z inc lsb subr
x"aa", x"03", -- 1a: cmp 03
x"dd", x"36", -- 1c: jmp z inc msb subr
x"aa", x"08", -- 1e: cmp 08
x"dd", x"42", -- 20: jmp z record subr
x"aa", x"09", -- 22: cmp 09
x"9d", -- 24: jmp z to addr in r6 r7 10011101
x"d8", x"0b", -- 25: jmp abs loop wait for keypressed 11011000
-- dec lsb
x"38", -- 27: mov r7,r0 00111000
x"5f", -- 28: dec 01011111
x"07", -- 29: mov r0,r7 00000111
x"d8", x"39", -- 2a: jump abs loop wait for keyrelease
-- dec msb
x"30", -- 2c: mov r6,r0 00110000
x"5f", -- 2d: dec
x"06", -- 2e: mov r0,r6
x"d8", x"39", -- 2f: jump abs loop wait for keyrelease
-- inc lsb
x"38", -- 31: mov r7,r0 00111000
x"57", -- 32: inc 01010111
x"07", -- 33: mov r0,r7 00000111
x"d8", x"39", -- 34: jump abs loop wait for keyrelease
-- dec msb
x"30", -- 36: mov r6,r0 00110000
x"57", -- 37: inc
x"06", -- 38: mov r0,r6
-- loop wait for keyrelease
x"e0", x"00",x"ff", -- 39: ld r0,[00ff] 1110000
x"aa", x"00", -- 3c: cmp 00 10101010 
x"dd", x"05", -- 3e: jmp z start displ addr
x"d8", x"39", -- 40: jmp abs wait release
-- record routine -- wait for keyrelease 
x"e0", x"00",x"ff", -- 42: ld r0,[00ff] 1110000
x"aa", x"00", -- 45: cmp 00 10101010 
x"d9", x"42", -- 47: jmp nz 11011001 
-- record routine 
x"e4", x"00", x"fd", -- 49: ld r4, [00fd] switches 11100100
x"85", -- 4c: ld r5, [] memory 10000101
x"ec", x"00", x"fb", -- 4d: st r4, [00fb] 11101100
x"ed", x"00", x"fc", -- 50: st r5, [00fc]
x"e0", x"00",x"ff", -- 53: ld r0,[00ff] 1110000 buttons
x"aa", x"04", -- 56: cmp 04 10101010 
x"dd", x"68", -- 58: jmp z 11011101  dec lsb subroutine
x"aa", x"02", -- 5a: cmp 02
x"dd", x"6d", -- 5c: jmp z inc lsb subroutine
x"aa", x"01", -- 5e: cmp 01
x"dd", x"72", -- 60: jmp z record subroutine
x"aa", x"08", -- 62: cmp 08
x"dd", x"39", -- 64: jmp z normal release
x"d8", x"49", -- 66: jmp abs loop wait for keypressed 11011000
-- dec lsb
x"38", -- 68: mov r7,r0 00111000
x"5f", -- 69: dec 01011111
x"07", -- 6a: mov r0,r7 00000111
x"d8", x"42", -- 6b: jump abs loop wait for keyrelease
-- inc lsb
x"38", -- 6d: mov r7,r0 00111000
x"57", -- 6e: inc 01010111
x"07", -- 6f: mov r0,r7 00000111
x"d8", x"42", -- 70: jump abs loop wait for keyrelease
-- record
x"8c", -- 72: st r4,[] 10001100
x"d8", x"42", -- 73: jump abs loop wait for keyrelease

x"a0", x"00", -- 75: ld r0,0 10100000 
x"07", -- 77: mov r0,r7 00000111
--x"57", -- 78: inc 01010111
x"00", -- 78: nop
x"06", -- 79: mov r0,r6 
x"ef", x"00", x"fa", -- 7a: st r7, special [00fa]
x"a4", x"b1", -- 7d : ld r4, b1
x"a5", x"05", -- 7f : ld r5, 05
x"ec", x"00", x"fb", -- 81: st r4, display1 
x"ed", x"00", x"fc", -- 84: st r5, display2
x"e0", x"00", x"ff", -- 87: ld r0,[00ff] 1110000
x"aa", x"00", -- 8a : cmp 0
x"dd", x"87", -- 8c: jz 87 test zero button
x"e0", x"00", x"ff", -- 8e: ld r0,[00ff] 1110000
x"aa", x"00", -- 91 : cmp 0
x"dd", x"05", -- 93 jz 8c test zero button
x"d8", x"8e", -- 95 : jmp abs 8e

-- start test program at 97
x"a0", x"00", -- 97: ld r0,0
x"07", -- 99: mov r0,r7
x"a6", x"02", -- 9a: ld r6,2
x"a5", x"ff", -- 9c: ld r5,ff
x"8d", -- 9e: st r5,[]  10001101 
x"57", -- 9f: inc
x"07", -- a0: mov r0,r7
x"8d", -- a1: st r5,[]
x"a5", x"00", -- a2: ld r5,00
x"a4", x"01", -- a4: ld r4,01
x"57", --a6: inc
x"dc", x"ad", -- a7: jovr 11011100 
x"07", -- a9: mov r0,r7
x"8d", -- aa: st r5,[]
x"d8", x"a6", -- ab: ja 11011000 
x"20", -- ad: mov r4,r0  00100000
x"57", -- ae: inc
x"dc", x"bf", -- af: jovr
x"04", -- b1 : mov r0,r4
x"07", -- b2: mov r0,r7
x"80", -- b3: ld r0,[]  10000000
x"44", -- b4: and r0  01000100
x"d9", x"ad", --b5: jnz  11011001 
x"20", -- b7: mov r4,r0
x"07", -- b8: mov r0,r7
x"8c", -- b9 : st r4,[] 10001100
x"60", -- ba: add r4  01100000
x"dc", x"ad", -- bb : jovr
x"d8", x"b8", -- bd : jabs 
x"e7", x"00", x"fd", -- bf: ld r7,[switches]  11100111
x"85", -- c2: ld r5,[] 10000101
x"ef", x"00", x"fb", -- c3: st r7,[display1] 
x"ed", x"00", x"fc", -- c6: st r5,[display2] 
x"d8", x"bf", -- c9: jabs



others => x"00"); 

page0(248) <= ledi(15 downto 8);
page0(249) <= ledi(7 downto 0);
page0(250) <= speciali(7 downto 0);
page0(251) <= digitsi(15 downto 8);
page0(252) <= digitsi(7 downto 0);
page0(253) <= sw(15 downto 8);
page0(254) <= sw(7 downto 0);
page0(255) <= x"0" & buttons;

pwrperiph : process(clk) begin
if clk'event and clk='1' then
if wr='1' then
if addr=x"00f8" then ledi(15 downto 8) <= datawr; end if;
if addr=x"00f9" then ledi(7 downto 0) <= datawr; end if;
if addr=x"00fa" then speciali <= datawr; end if;
if addr=x"00fb" then digitsi(15 downto 8) <= datawr; end if;
if addr=x"00fc" then digitsi(7 downto 0) <= datawr; end if;
end if;
end if; end process;

end Behavioral;
