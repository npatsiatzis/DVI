library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity clk_gen is
	generic(
		g_clk_period : real := 8.0;
		g_clk_mult 	 : integer := 8;
		g_clk_div	 : integer := 1;
		g_clk_ser_div : integer := 8;
		g_clk_pix_div : integer := 40);
	port(
		i_clk : in std_ulogic;
		o_pix_clk : out std_ulogic;
		o_ser_clk : out std_ulogic);
end clk_gen;

architecture rtl of clk_gen is
	signal clkfbout : std_ulogic;
	signal pll_ser, pll_pix : std_ulogic;
begin
   -- buffer output clocks
    clk0buf: BUFG port map (I=>pll_ser, O=>o_ser_clk);
    clk1buf: BUFG port map (I=>pll_pix, O=>o_pix_clk);

    --Primitive : 	Base Phase Locked Loop (PLL)
    --each output clk frequency, from clkout0  to clkout5
    --is determined by clkfbout_mul, divclk_divide , clkout#_divide
    pll: PLLE2_BASE generic map (
        clkin1_period  => g_clk_period,
        clkfbout_mult  => g_clk_mult,
        clkout0_divide => g_clk_ser_div,	--amount to divide clkout0
        clkout1_divide => g_clk_pix_div,	--amount to divide clkout1
        divclk_divide  => g_clk_pix_div		--division ratio for all output clocks w.r.t inpput clock 
    )
    port map(
        rst      => '0',
        pwrdwn   => '0',		--power down instantiated but unused PLLs
        clkin1   => i_clk,
        clkfbin  => clkfbout,	--feedback clock pin ton the PLL
        clkfbout => clkfbout,	--dedicated feedback clock output
        clkout0  => pll_ser,	--default duty 0.5; default phase offset 0.
        clkout1  => pll_pix
    );
end rtl;