library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity dvi is
	port(
		i_clk : in std_ulogic;							--system clock
		i_rst : in std_ulogic;
		o_clk_p : out std_ulogic;						--TMDS Clock+
		o_clk_n : out std_ulogic;						--TMDS Clock-
		o_data_p : out std_ulogic_vector(2 downto 0);   --TMDS Data+
		o_data_n : out std_ulogic_vector(2 downto 0)); 	--TMDS Data-
end dvi;

architecture rtl of dvi is 
	signal pix_clk,ser_clk : std_ulogic;
	signal hsync,vsync,active : std_ulogic;
	signal x,y : std_ulogic_vector(15 downto 0);
	signal rgb : std_ulogic_vector(23 downto 0);
begin

	--given system clock, generate:
	--pixel clock (based on resolution)
	--serial clock (5x pixel clock due to DDR)
	clk_gen : entity work.clk_gen(rtl)
	generic map(
		g_clk_period  =>8.0,
		g_clk_mult 	  =>8,
		g_clk_div	  =>1,
		g_clk_ser_div =>8,
		g_clk_pix_div =>40);
	port map(
		i_clk 	  =>i_clk,
		o_pix_clk =>pix_clk,
		o_ser_clk =>ser_clk);

	--given resolution, generate the required timing signals
	display_timings : entity work.display_timings(rtl)
	port map (
		i_clk => pix_clk,
		o_hsync => hsync,
		o_vsync => vsync,
		o_x => x,
		o_y => y,
		o_active => active);

	--generate a test image
	image_generator : entity work.image_generator(rtl)
	port map(
		i_clk  	 =>pix_clk,
		i_active =>active, 
		o_rgb 	 =>rgb);

	--from rgb pixel data to tmds differential output signals
	tmds_transmitter : entity work.tmds_transmitter(rtl)
	port map(
		i_pix_clk	=> pix_clk,  
		i_ser_clk   => ser_clk,
		i_rst 	   	=> i_rst,
		i_pix_data  => rgb,
		i_hsync		=> hsync,    
		i_vsync     => vsync,
		i_active    => active,
		o_clk_p	   	=> o_clk_p,
		o_clk_n	    => o_clk_n,
		o_data_p   	=> o_data_p,
		o_data_n   	=> o_data_n); 
end rtl;