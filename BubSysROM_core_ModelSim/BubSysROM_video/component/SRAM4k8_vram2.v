/*
    TC5533P SRAM
*/

module SRAM4k8_vram2
(
    input   wire            i_MCLK,
	input   wire    [11:0]  i_ADDR,
	input   wire    [7:0]   i_DIN,
	output  reg     [7:0]   o_DOUT,
	input   wire            i_WR_n,
	input   wire            i_RD_n
);

reg     [7:0]   RAM4k8 [4095:0];

always @(posedge i_MCLK)
begin
    if(i_WR_n == 1'b0)
    begin
        RAM4k8[i_ADDR] <= i_DIN;
    end
end

always @(posedge i_MCLK) //read
begin
    if(i_RD_n == 1'b0)
    begin
        o_DOUT <= RAM4k8[i_ADDR];
    end
end

initial
begin
    $readmemh("vram2.txt", RAM4k8);
end

endmodule