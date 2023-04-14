--A TMDS encoder(form of 8b/10b encoding) is esentially a two stage process:
--1)Transform the first bit and each subsequent bit is either 
--XOR/XNOR transformed  against the previous bit; the ninth bit encodes which operation was used.
--2)The first 8bits are optionally inverted to even out the
--balance of ones and zeros; the tenth bit encodes whether inversion took place.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tmds_encoder is
	port(
		i_clk : in std_ulogic;							--TMDS clock
		i_dena : in std_ulogic;							--display enable, '1' when din is encoded, '0' for control
		i_control : in std_ulogic_vector(1 downto 0);	--control(sync) data
		i_din : in std_ulogic_vector(7 downto 0);		--pixel data
		o_dout : out std_ulogic_vector(9 downto 0));	--output data
end tmds_encoder;

architecture rtl of tmds_encoder is
	signal w_onesD : natural range 0 to 8;
	signal w_x : std_ulogic_vector(8 downto 0);
	signal w_onesX : natural range 0 to 9;
	signal r_disparity : integer range -31 to 31 :=0;	--accumulated disparity
begin
	count_ones : process(all)
		variable cnt_ones : unsigned(3 downto 0) := (others => '0');
	begin
		cnt_ones := (others => '0');
		for i in 0 to i_din'high loop 
			cnt_ones := cnt_ones + i_din(i);
		end loop;

		w_onesD <= to_integer(cnt_ones);
	end process; -- count_ones

	calc_x : process(all)
	begin
		w_x(0) <= i_din(0);
		if(w_onesD > 4 or (w_onesD =4 and i_din(0) = '0')) then
			w_x(1) <= i_din (1) XNOR w_x(0);
			w_x(2) <= i_din (2) XNOR w_x(1);
			w_x(3) <= i_din (3) XNOR w_x(2);
			w_x(4) <= i_din (4) XNOR w_x(3);
			w_x(5) <= i_din (5) XNOR w_x(4);
			w_x(6) <= i_din (6) XNOR w_x(5);
			w_x(7) <= i_din (7) XNOR w_x(6);
			w_x(8) <= '0';
		else
			w_x(1) <= i_din (1) XOR w_x(0);
			w_x(2) <= i_din (2) XOR w_x(1);
			w_x(3) <= i_din (3) XOR w_x(2);
			w_x(4) <= i_din (4) XOR w_x(3);
			w_x(5) <= i_din (5) XOR w_x(4);
			w_x(6) <= i_din (6) XOR w_x(5);
			w_x(7) <= i_din (7) XOR w_x(6);
			w_x(8) <= '1';
		end if;
	end process; -- calc_x


	count_onesX : process(all)
		variable cnt_onesX : unsigned(3 downto 0) := (others => '0');
	begin
		cnt_onesX := (others => '0');
		for i in 0 to w_x'high-1 loop 
			cnt_onesX := cnt_onesX + w_x(i);
		end loop;

		w_onesX <= to_integer(cnt_onesX);
	end process; -- count_onesX

	calc_dout : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_dena = '0') then
				r_disparity <= 0;
				case i_control is 
					when "00" => o_dout <= "1101010100";
					when "01" => o_dout <= "0010101011";
					when "10" => o_dout <= "0101010100";
					when others => o_dout <= "1010101011";
				end case;
			else
				if(r_disparity = 0 or w_onesX = 4) then
					if(w_x(8) = '0') then 
						o_dout <= "10" & not w_x(7 downto 0);
						-- disparity = disparity - diff_wx , where diff_wx isones_w_x - zeros_w_x
						r_disparity <= r_disparity +8 -2*w_onesX;
					else
						o_dout <= "01" & w_x(7 downto 0);
						-- disparity = disparity + diff_wx , where diff_wx isones_w_x - zeros_w_x
						r_disparity <= r_disparity -8 +2*w_onesX;
					end if;
				elsif((r_disparity>0 and w_onesX>4) or (r_disparity <0 and w_onesX<4)) then					
					if(w_x(8) = '1')then
						-- disparity = disparity + diff_wx , where diff_wx isones_w_x - zeros_w_x
						r_disparity <= r_disparity +10 -2*w_onesX;
						o_dout <= "11" & not w_x(7 downto 0);
					else
						r_disparity <= r_disparity +8 -2*w_onesX;	
						-- disparity = disparity - diff_wx , where diff_wx isones_w_x - zeros_w_x
						o_dout <= "10" & not w_x(7 downto 0);
					end if;
				else
					if(w_x(8) = '0') then
						-- disparity = disparity + diff_wx -2, where diff_wx isones_w_x - zeros_w_x
						r_disparity <= r_disparity -10 +2*w_onesX;
						o_dout <= "00" & w_x(7 downto 0);
					else
						-- disparity = disparity + diff_wx , where diff_wx isones_w_x - zeros_w_x
						r_disparity <= r_disparity -8 +2*w_onesX;
						o_dout <= "01" & w_x(7 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process; -- calc_dout
end rtl;