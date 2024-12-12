library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cauid is
    Port (
        clk      : in std_logic;
        rst      : in std_logic;
        datard   : in std_logic_vector(7 downto 0); -- from memory
        state    : in std_logic_vector(1 downto 0); -- state vector
        match    : out std_logic
    );
end cauid;

architecture Behavioral of cauid is

type signature_array_type is array (0 to 7) of std_logic_vector(31 downto 0);
signal signatures : signature_array_type := (
        x"03aa64ff", x"6403ac21", x"2a4b6c7d", x"94db5312",
        x"ed1132b4", x"abcd1234", x"56789abc", x"57dc44d8"
);
signal masks : signature_array_type := (
        x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF",
        x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF", x"FFFFFFFF"
);
signal instruction_register : std_logic_vector(31 downto 0) := (others => '0');
signal shift_register : signature_array_type := (others => (others => '0'));

begin

    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset all signals
            instruction_register <= (others => '0');
            shift_register <= (others => (others => '0'));
            match <= '0';

        elsif rising_edge(clk) then
            -- Shift logic for states 1, 2, 3
            if state = "00" or state = "01" or state = "10" then
                shift_register(0 to 6) <= shift_register(1 to 7);  -- Shift left
                shift_register(7) <= datard & shift_register(7)(31 downto 8); -- Align to the right, preserve 32 bits

            elsif state = "11" then
                -- Compare the instruction register with the signatures in the 8x8 array
                match <= '0';
                for i in 0 to 7 loop
                    if (shift_register(i) and masks(i)) = (signatures(i) and masks(i)) then
                        match <= '1';
                    end if;
                end loop;
            end if;
        end if;
    end process;

end Behavioral;

