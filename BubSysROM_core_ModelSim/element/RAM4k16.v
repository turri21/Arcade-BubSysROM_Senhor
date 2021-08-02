/*
    2*6264 4k*16 SRAM ELEMENT
*/

module RAM4k16
(
    input   wire            i_EMU_MCLK,
	input   wire    [11:0]  i_ADDR,
	input   wire    [15:0]  i_DIN,
	output  reg     [15:0]  o_DOUT,
	input   wire            i_WR_n,
	input   wire            i_RD_n,
    input   wire            i_SEL0_n,
    input   wire            i_SEL1_n
);

/*
     MSB           D A T A           LSB
    |---(8bit SEL0)---|---(8bit SEL1)---|
*/

//upper 8 bit
reg     [7:0]   RAM4k8_0 [4095:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n | i_SEL0_n == 1'b0)
    begin
        o_DOUT[15:8] <= RAM4k8_0[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n | i_SEL0_n == 1'b0)
    begin
        RAM4k8_0[i_ADDR] <= i_DIN[15:8];
    end
end


//lower 8 bit
reg     [7:0]   RAM4k8_1 [4095:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n | i_SEL1_n == 1'b0)
    begin
        o_DOUT[7:0] <= RAM4k8_1[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n | i_SEL1_n == 1'b0)
    begin
        RAM4k8_1[i_ADDR] <= i_DIN[7:0];
    end
end


endmodule