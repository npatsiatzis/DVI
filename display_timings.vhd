library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_timings is
	generic(
		--default for 640x480 @60Hz
		g_h_res : natural :=640;						
		g_v_res : natural :=480;
		g_h_fp  : natural :=16;
		g_h_sync : natural :=96;
		g_h_bp : natural :=48;
		g_v_fp : natural :=10;
		g_v_sync : natural :=2;
		g_v_bp : natural :=33);
	port(
		i_clk : in std_ulogic;							--pixel clock											
		o_hsync : out std_ulogic;						--horizontal sync
		o_vsync : out std_ulogic;						--vertical sync
		o_x : out std_ulogic_vector(9 downto 0);		--horizontal screen position
		o_y : out std_ulogic_vector(9 downto 0);		--vertical screen position
		o_active : out std_ulogic);						--data enable (low in blanking interval)
end display_timings;

architecture rtl of display_timings is
	signal r_x : unsigned(9 downto 0):=(others => '0');
	signal r_y : unsigned(9 downto 0):=(others => '0'); 

	--horizontal timings (for VGA 640x480 @60Hz)
	constant h_end : natural 	:= g_h_res 	- 1;			--end of active pixels 
	constant hs_start : natural := h_end 	+ g_h_fp;		--start of sync after front porch
	constant hs_end : natural 	:= hs_start + g_h_sync;		--end of sync
	constant line : natural 	:= hs_end 	+ g_h_bp;		--last pixel on line after back porch

	--vertical timings (for VGA 640x480 @60Hz)
	constant v_end : natural 	:= g_v_res	- 1;			--end of active pixels
	constant vs_start : natural := v_end  	+ g_v_fp;		--start of sync after front porch
	constant vs_end : natural 	:= vs_start + g_v_sync;		--end of sync 
	constant frame : natural 	:= vs_end 	+ g_v_bp;		--last pixel on frame after back porch

begin

	-- active when x position and y position is not in the blanking intervals
	o_active <= '1' when (r_x <= h_end and r_x <= v_end) else '0';
	o_hsync <= '0' when (r_x > hs_start and r_x <= hs_end) else '1';
	o_vsync <= '0' when (r_y > vs_start and r_y <= vs_end) else '1';

	--maintain x,y position based on the pixel clock and the resolution requirements
	x_y_position : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(r_x = line) then
				r_x <= (others => '0');
				if(r_y < frame) then
					r_y <= r_y + 1;
				else
					r_y <= (others => '0');
				end if;
			else
				r_x <= r_x + 1;
			end if;
		end if;
	end process; -- x_y_position

	o_x <= std_ulogic_vector(r_x);
	o_y <= std_ulogic_vector(r_y);
end rtl;