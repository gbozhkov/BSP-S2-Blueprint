library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_top is
    Port(
        clk : IN std_logic;
        sw : IN std_logic_vector(15 downto 0);
        led : OUT std_logic_vector(15 downto 0);
        seg : OUT std_logic_vector(6 downto 0);
        dp : OUT std_logic;
        an : OUT std_logic_vector(3 downto 0);
        btnC, btnU, btnL, btnR, btnD : IN std_logic
    );
end cpu_top;

architecture Behavioral of cpu_top is

COMPONENT memory is
PORT (
clk, rst : IN std_logic;
addr : IN std_logic_vector(15 downto 0);
datawr : IN std_logic_vector(7 downto 0);
datard : OUT std_logic_vector(7 downto 0);
wr : IN std_logic;
sw : IN std_logic_vector(15 downto 0);
buttons : IN std_logic_vector(3 downto 0);
led : OUT std_logic_vector(15 downto 0);
digits : OUT std_logic_vector(15 downto 0)
);
end COMPONENT;

COMPONENT interface is
PORT (
clk, rst : IN std_logic;
data : IN std_logic_vector(15 downto 0);
segm : OUT std_logic_vector(7 downto 0);
common : OUT std_logic_vector(3 downto 0);
butin : IN std_logic_vector(3 downto 0);
butout : OUT std_logic_vector(3 downto 0)
);
end COMPONENT;

COMPONENT cpu is
PORT (
clk, rst : IN std_logic;
addr : OUT std_logic_vector(15 downto 0);
datard : IN std_logic_vector(7 downto 0);
datawr : OUT std_logic_vector(7 downto 0);
wr : OUT std_logic;
state : BUFFER std_logic_vector(3 downto 0);
halt : IN std_logic
);
end COMPONENT;

COMPONENT cauid IS
Port (
clk      : IN std_logic;
rst      : IN std_logic;
datard   : IN std_logic_vector(7 downto 0);
state    : IN std_logic_vector(1 downto 0);
match    : OUT std_logic
);
 END COMPONENT;

SIGNAL addr : std_logic_vector(15 downto 0);
SIGNAL datard, datawr : std_logic_vector(7 downto 0);
SIGNAL wr : std_logic;
SIGNAL state : std_logic_vector(3 downto 0);
SIGNAL buttons_i, buttons : std_logic_vector(3 downto 0);
SIGNAL digits : std_logic_vector(15 downto 0);
SIGNAL segm : std_logic_vector(7 downto 0);
SIGNAL cauid_match : std_logic;
SIGNAL cpu_state : std_logic_vector(1 downto 0);

begin

    -- Button inputs
    buttons_i <= (btnU, btnL, btnR, btnD);

    -- Map 7-segment display signals
    seg <= segm(6 downto 0);
    dp <= '1';

ccpu : cpu PORT MAP (
    clk => clk,
    rst => btnC,
    addr => addr,
    datard => datard,
    datawr => datawr,
    wr => wr,
    state => state,
    halt => cauid_match
);

    -- Instantiate Memory
    cmem : memory PORT MAP (
        clk => clk,
        rst => btnC,
        addr => addr,
        datawr => datawr,
        datard => datard,
        wr => wr,
        sw => sw,
        buttons => buttons,
        led => led,
        digits => digits
    );

    -- Instantiate Interface
    cint : interface PORT MAP (
        clk => clk,
        rst => btnC,
        data => digits,
        segm => segm,
        common => an,
        butin => buttons_i,
        butout => buttons
    );

    -- Map CPU state to 2-bit state for CAUID
    cpu_state <= state(1 downto 0);

    -- Instantiate CAUID
    c_cauid: cauid PORT MAP (
        clk => clk,
        rst => btnC,
        datard => datard,
        state => cpu_state,
        match => cauid_match
    );

    -- Use CAUID match signal
    led(0) <= cauid_match; -- Turn on first LED if a match is detected

-- debug
--digitsdeb <= debug( 15 downto   0) when sw(3 downto 0) = x"f"
--        else debug( 31 downto  16) when sw(3 downto 0) = x"e"
--        else debug( 47 downto  32) when sw(3 downto 0) = x"d"
--        else debug( 63 downto  48) when sw(3 downto 0) = x"c"
--        else debug( 79 downto  64) when sw(3 downto 0) = x"b"
--        else debug( 95 downto  80) when sw(3 downto 0) = x"a"
--        else debug(111 downto  96) when sw(3 downto 0) = x"9"
--        else debug(127 downto 112) when sw(3 downto 0) = x"8"
--        else debug(143 downto 128) when sw(3 downto 0) = x"7"
--        else debug(159 downto 144) when sw(3 downto 0) = x"6"
--        else debug(175 downto 160) when sw(3 downto 0) = x"5"
--        else debug(191 downto 176) when sw(3 downto 0) = x"4"
--        else debug(207 downto 192) when sw(3 downto 0) = x"3"
--        else debug(223 downto 208) when sw(3 downto 0) = x"2"
--        else debug(239 downto 224) when sw(3 downto 0) = x"1"
--        else debug(255 downto 240) when sw(3 downto 0) = x"0"
--        else x"0000";


     




end Behavioral;
