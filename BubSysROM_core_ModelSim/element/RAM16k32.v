/*
    8*4416 16k*32 DRAM ELEMENT
*/

module RAM16k32
(
    input   wire            i_EMU_MCLK,
	input   wire    [13:0]  i_ADDR,
	input   wire    [31:0]  i_DIN,
	output  reg     [31:0]  o_DOUT,
	input   wire            i_WR_n,
	input   wire            i_RD_n,
    input   wire            i_SEL0_n,
    input   wire            i_SEL1_n,
    input   wire            i_SEL2_n,
    input   wire            i_SEL3_n
);

/*
    A1    MSB           D A T A           LSB
     0   |---(8bit SEL0)---|---(8bit SEL1)---|
     1   |---(8bit SEL2)---|---(8bit SEL3)---|
*/

//A=0, upper 8 bit
reg     [7:0]   RAM16k8_0 [16383:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n | i_SEL0_n == 1'b0)
    begin
        o_DOUT[31:24] <= RAM16k8_0[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n | i_SEL0_n == 1'b0)
    begin
        RAM16k8_0[i_ADDR] <= i_DIN[31:24];
    end
end

//A=0, lower 8 bit
reg     [7:0]   RAM16k8_1 [16383:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n | i_SEL1_n == 1'b0)
    begin
        o_DOUT[23:16] <= RAM16k8_1[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n | i_SEL1_n == 1'b0)
    begin
        RAM16k8_1[i_ADDR] <= i_DIN[23:16];
    end
end

//A=1, upper 8 bit
reg     [7:0]   RAM16k8_2 [16383:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n | i_SEL2_n == 1'b0)
    begin
        o_DOUT[15:8] <= RAM16k8_2[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n | i_SEL2_n == 1'b0)
    begin
        RAM16k8_2[i_ADDR] <= i_DIN[15:8];
    end
end

//A=1, lower 8 bit
reg     [7:0]   RAM16k8_3 [16383:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n | i_SEL3_n == 1'b0)
    begin
        o_DOUT[7:0] <= RAM16k8_3[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n | i_SEL3_n == 1'b0)
    begin
        RAM16k8_3[i_ADDR] <= i_DIN[7:0];
    end
end

endmodule