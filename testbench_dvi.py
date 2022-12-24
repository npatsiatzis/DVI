import cocotb
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.handle import Force
from cocotb.triggers import RisingEdge


def decimal_to_bin8(decimal):
    bin8 = bin(decimal)[2:][::-1]
    diff = 8 - len(bin8)
    for i in range(diff):
        bin8 = bin8+'0'
    return bin8

def minimize_transitions(p_bin):
    w_x = [0] * 9
    tmp = [int(i) for i in p_bin]
    cnt_ones = sum(tmp)
    if(cnt_ones >4 or (cnt_ones == 4 and tmp[0] ==0)):
        w_x[0] = int(tmp[0])
        w_x[1] = int(tmp[1] == w_x[0])
        w_x[2] = int(tmp[2] == w_x[1])
        w_x[3] = int(tmp[3] == w_x[2])
        w_x[4] = int(tmp[4] == w_x[3])
        w_x[5] = int(tmp[5] == w_x[4])
        w_x[6] = int(tmp[6] == w_x[5])
        w_x[7] = int(tmp[7] == w_x[6])
        w_x[8] = 0
    else:
        w_x[0] = int(tmp[0])
        w_x[1] = int(tmp[1] ^ w_x[0])
        w_x[2] = int(tmp[2] ^ w_x[1])
        w_x[3] = int(tmp[3] ^ w_x[2])
        w_x[4] = int(tmp[4] ^ w_x[3])
        w_x[5] = int(tmp[5] ^ w_x[4])
        w_x[6] = int(tmp[6] ^ w_x[5])
        w_x[7] = int(tmp[7] ^ w_x[6])
        w_x[8] = 1

    return w_x

def fix_disparity(disparity,p_w_x):
    dout = [0] * 10
    cnt_ones = sum(p_w_x[0:8])
    cnt_zeros = 8 - cnt_ones
    running_disparity = disparity

    if running_disparity == 0 or cnt_ones == 4:
        dout[9] = int(not p_w_x[8])
        dout[8] = p_w_x[8]
        if p_w_x[8] == 0:
            dout[:8] = [int(not i) for i in p_w_x[:8]]  
            running_disparity = running_disparity + cnt_zeros - cnt_ones
        else:
            dout[:8] = p_w_x[:8]
            running_disparity = running_disparity + cnt_ones - cnt_zeros
    else:
        if (running_disparity > 0 and cnt_ones > cnt_zeros) or (running_disparity < 0 and cnt_ones < cnt_zeros):
            dout[9] = 1
            dout[8] = p_w_x[8]
            dout[:8] = [int(not i) for i in p_w_x[:8]]  
            running_disparity = running_disparity + 2 * p_w_x[8] + cnt_zeros - cnt_ones
        else:
            dout[9] = 0
            dout[8] = p_w_x[8]
            dout[:8] = p_w_x[:8]
            running_disparity = running_disparity - 2 * (not p_w_x[8]) + cnt_ones - cnt_zeros

    dout = dout[::-1]
    dout = BinaryValue("".join(str(x) for x in dout))
    return running_disparity,dout    

async def reset(dut):
    dut.i_dena.value = 0
    dut.i_control.value = 0
    dut.i_din.value = 0
    await RisingEdge(dut.i_clk)
    dut.i_dena.value = 1
    dut.i_control.value = 0
    await RisingEdge(dut.i_clk)


@cocotb.test()
async def test_0_disparity(dut):
    """Check results and coverage for the tmds encoder"""
    """Test the operation of encoding with 0 disparity for every input"""

    cocotb.start_soon(Clock(dut.i_clk, 10, units="ns").start())    #pixel clock
    disparity = 0
    await reset(dut)

    for decimal in range(1,2**8):
        dut.r_disparity.value = Force(0)
        dut.i_dena.value = 1
        dut.i_control.value = 0
        dut.i_din.value = decimal

        binary_input = decimal_to_bin8(decimal-1)
        w_x = minimize_transitions(binary_input)
        _,dout = fix_disparity(0,w_x)

        await RisingEdge(dut.i_clk)
        assert not (dout != dut.o_dout.value),"Wrong Behavior!"


@cocotb.test()
async def test(dut):
    """Check results and coverage for the tmds encoder"""
    """Test the operation of running disparity"""

    cocotb.start_soon(Clock(dut.i_clk, 10, units="ns").start())    #pixel clock
    disparity = 0
    await reset(dut)

    for decimal in range(1,2**8):
        # dut.r_disparity.value = Force(0)
        dut.i_dena.value = 1
        dut.i_control.value = 0
        dut.i_din.value = decimal

        binary_input = decimal_to_bin8(decimal-1)
        w_x = minimize_transitions(binary_input)
        disparity,dout = fix_disparity(disparity,w_x)

        await RisingEdge(dut.i_clk)
        assert not (dout != dut.o_dout.value),"Wrong Behavior!"
