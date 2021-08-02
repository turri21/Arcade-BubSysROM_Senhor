/*
    6264 4k*8 SRAM ELEMENT
*/

module RAM4k8
(
    input   wire            i_EMU_MCLK,
	input   wire    [11:0]  i_ADDR,
	input   wire    [7:0]   i_DIN,
	output  reg     [7:0]   o_DOUT,
	input   wire            i_WR_n,
	input   wire            i_RD_n
);


reg     [7:0]   RAM4k8 [4095:0];

always @(negedge i_EMU_MCLK) //read
begin
    if(i_RD_n == 1'b0)
    begin
        o_DOUT <= RAM4k8[i_ADDR];
    end
end

always @(negedge i_EMU_MCLK)
begin
    if(i_WR_n == 1'b0)
    begin
        RAM4k8[i_ADDR] <= i_DIN;
    end
end

endmodule