![example workflow](https://github.com/npatsiatzis/dvi/actions/workflows/regression.yml/badge.svg)

# Digital Visual Interface(DVI) RTL implementation

- design consists of timing generator, clock generator(PLL), image generator, TMDS transmitter(TMDS encoder + serializer) and DVI top
- parameterizable timing generator, default values correspond to 640 x 480 @ 60 Hz Industry standard timing
- image generator generates a standard test frame
- CoCoTB testbench for functional verification of the TMDS encoder module. Test all input space both againt a static 0 disparity as well as against free running disparity.
