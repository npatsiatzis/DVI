--Module that generates a test frame. For normal operation
--this is swapped for a framebuffer holding the frame

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity image_generator is
	port(
		i_clk : in std_ulogic;
		i_active : in std_ulogic;
        o_r : out std_ulogic_vector(2 downto 0);
        o_g : out std_ulogic_vector(2 downto 0);
        o_b : out std_ulogic_vector(1 downto 0));
		--o_rgb : out std_ulogic_vector(23 downto 0));
end image_generator;

architecture rtl of image_generator is
    type state_type is (s0, s1, s2, s3, s4, s5);
    signal state : state_type := s0;

    signal r : unsigned(2 downto 0) := (others => '1');
    signal b : unsigned(1 downto 0) := (others => '0');
    signal g : unsigned(2 downto 0) := (others => '0');
begin

    --rgb <= std_logic_vector(r & g & b);
    o_r <= std_ulogic_vector(r);
    o_g <= std_ulogic_vector(g);
    o_b <= std_ulogic_vector(b);

    -- color spectrum process
    process(i_clk) is
    begin
        if rising_edge(i_clk) then
            if i_active = '1' then
                case state is
                when s0 =>
                    if g = (2**(g'length))-1 then
                        state <= s1;
                    else
                        g <= g + 1;
                    end if;
                when s1 =>
                    if r = 0 then
                        state <= s2;
                    else
                        r <= r - 1;
                    end if;
                when s2 =>
                    if b = (2**(b'length))-1 then
                        state <= s3;
                    else
                        b <= b + 1;
                    end if;
                when s3 =>
                    if g = 0 then
                        state <= s4;
                    else
                        g <= g - 1;
                    end if;
                when s4 =>
                    if r = (2**(r'length))-1 then
                        state <= s5;
                    else
                        r <= r + 1;
                    end if;
                when s5 =>
                    if b = 0 then
                        state <= s0;
                    else
                        b <= b - 1;
                    end if;
                end case;
            else
                r <= (others => '1');
                g <= (others => '0');
                b <= (others => '0');
                state <= s0;
            end if;
        end if;
    end process;
end rtl;