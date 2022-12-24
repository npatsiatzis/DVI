--Module that performs the pixel data (rgb) to 
--differential TMDS data conversion. Consists of (per rgb channel):
--1)TMDS encoder
--2)Serializer (contains differential buffer as well)


library ieee;
use ieee.std_logic_1164.all;

entity tmds_transmitter is
	port(
		i_pix_clk  : in std_ulogic;
		i_ser_clk  : in std_ulogic;
		i_rst 	   : in std_ulogic;
		i_pix_data : in std_ulogic_vector(23 downto 0);
		i_hsync    : in std_ulogic;
		i_vsync    : in std_ulogic;
		i_active   : in std_ulogic;
		o_clk_p	   : out std_ulogic;
		o_clk_n	   : out std_ulogic;
		o_data_p   : out std_ulogic_vector(2 downto 0);
		o_data_n   : out std_ulogic_vector(2 downto 0)); 
end tmds_transmitter;

architecture rtl of tmds_transmitter is
	signal sync : std_ulogic_vector(1 downto 0);
	signal tmds_enc_r : std_ulogic_vector(9 downto 0);
	signal tmds_enc_g : std_ulogic_vector(9 downto 0);
	signal tmds_enc_b : std_ulogic_vector(9 downto 0);
begin
	sync <= i_hsync & i_vsync;

	--TMDS encoder for each channel
	enc_r : entity work.tmds_encoder(rtl)
	port map(
		i_clk => i_pix_clk,
		i_dena => i_active,
		i_controll => sync,
		i_din => i_pix_data(23 downto 16);
		o_dout => tmds_enc_r);

	enc_g : entity work.tmds_encoder(rtl)
	port map(
		i_clk => i_pix_clk,
		i_dena => i_active,
		i_controll => sync,
		i_din => i_pix_data(15 downto 8);
		o_dout => tmds_enc_g);

		enc_b : entity work.tmds_encoder(rtl)
	port map(
		i_clk => i_pix_clk,
		i_dena => i_active,
		i_controll => sync,
		i_din => i_pix_data(7 downto 0);
		o_dout => tmds_enc_b);

	--TMDS serialzers (contain differential buffers as well)
	ser_r : entity work.serializer(rtl)
	port_map(
		i_pix_clk => i_pix_clk,
		i_ser_clk => i_ser_clk,
		i_rst 	  => i_rst,
		i_data 	  => tmds_enc_r,
		o_p 	  => o_data_p(0),
		o_n 	  => o_data_n(0));

	ser_g : entity work.serializer(rtl)
	port_map(
		i_pix_clk => i_pix_clk,
		i_ser_clk => i_ser_clk,
		i_rst 	  => i_rst,
		i_data 	  => tmds_enc_g,
		o_p 	  => o_data_p(1),
		o_n 	  => o_data_n(1));

	ser_b : entity work.serializer(rtl)
	port_map(
		i_pix_clk => i_pix_clk,
		i_ser_clk => i_ser_clk,
		i_rst 	  => i_rst,
		i_data 	  => tmds_enc_b,
		o_p 	  => o_data_p(b),
		o_n 	  => o_data_n(b));

	ser_clk : entity work.serializer(rtl)
	port_map(
		i_pix_clk => i_pix_clk,
		i_ser_clk => i_ser_clk,
		i_rst 	  => i_rst,
		i_data 	  => "1111100000",
		o_p 	  => o_clk_p,
		o_n 	  => o_clk_n;
end rtl;