--Serializer for 10-bits TMDS signal using 
--primitives found in Xilinx 7-series FPGAS.
--primitives instantiations might need some modifications 
--for use with other series devices.

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity serializer is
	port(
		i_pix_clk : in std_ulogic;						--pixel clock
		i_ser_clk : in std_ulogic;						--serial clock(5x, due to DDR)
		i_rst 	  : in std_ulogic;
		i_data	  : in std_ulogic_vector(9 downto 0);	--TMDS data
		o_p		  : out std_ulogic;						--differential pair +
		o_n 	  : out std_ulogic); 					--differential pair -
end serializer;

architecture rtl of serializer is
	--signals to help cascade master-slave OSERDES since data width >8
	signal cascade1,cascade2 : std_ulogic
	--OSERDES out signal
	signal r_sdata : std_ulogic;
begin
    --serializer 10:1 using SDR
    --i_ser_clk thus only 5x of i_pix_clk
    --master-slave cascaded since data width > 8
    master : OSERDESE2
    generic map (
        DATA_RATE_OQ      => "DDR",			--defines whether data is processed at SRD/DDR
        DATA_RATE_TQ      => "SDR",			--defines how tri-state control is processed
        DATA_WIDTH        => 10,			--defines parallel data input width; if > 8;
        									--requires 2 OSERDES2 in master-slave configuration 
        SERDES_MODE       => "MASTER",		--defines the mode of OSERDES2 in case of cascade
        TRISTATE_WIDTH    => 1)
    port map (
        OQ                => r_sdata,		--data output port of the OSERDES2 module
        OFB               => open,			--output feedback port of OSERDES2
        TQ                => open,			
        TFB               => open,
        SHIFTOUT1         => open,
        SHIFTOUT2         => open,
        TBYTEOUT          => open,			
        CLK               => i_ser_clk,		--high-speed clock that drives the serial side
        CLKDIV            => i_pix_clk,		--divided high-speed clock that drives the parallel side
        D1                => i_data(0),		--incoming parallel data enter through D1-D8
       
        --DVI sends least significant bit first 
   		--OSERDESE2 sends D1 bit first
        D2                => i_data(1),
        D3                => i_data(2),
        D4                => i_data(3),
        D5                => i_data(4),
        D6                => i_data(5),
        D7                => i_data(6),
        D8                => i_data(7),
        TCE               => '0',
        OCE               => '1',
        TBYTEIN           => '0',
        RST               => i_rst,
        SHIFTIN1          => cascade1,		--cascade input for data input expansion
        SHIFTIN2          => cascade2,
        T1                => '0',
        T2                => '0',
        T3                => '0',
        T4                => '0'
    );

    slave : OSERDESE2
    generic map (
        DATA_RATE_OQ      => "DDR",
        DATA_RATE_TQ      => "SDR",
        DATA_WIDTH        => 10,
        SERDES_MODE       => "SLAVE",
        TRISTATE_WIDTH    => 1)
    port map (
        OQ                => open,
        OFB               => open,
        TQ                => open,
        TFB               => open,
        SHIFTOUT1         => cascade1,		--cascade output for data input expansion
        SHIFTOUT2         => cascade2,
        TBYTEOUT          => open,
        CLK               => i_ser_clk,
        CLKDIV            => i_pix_clk,
        D1                => '0',
        D2                => '0',
        D3                => i_data(8),
        D4                => i_data(9),
        D5                => '0',
        D6                => '0',
        D7                => '0',
        D8                => '0',
        TCE               => '0',
        OCE               => '1',
        TBYTEIN           => '0',
        RST               => i_rst,
        SHIFTIN1          => '0',
        SHIFTIN2          => '0',
        T1                => '0',
        T2                => '0',
        T3                => '0',
        T4                => '0'
    );

    -- create differential output pair
    --Primitive : Differential output buffer
    obuf : OBUFDS
    generic map (
    	IOSTANDARD =>"TMDS_33")
    port map (
    	I=>sdata,		--buffer input
    	O=>o_p,			--differential p output
		OB=>o_n);		--differential n output	
end rtl;