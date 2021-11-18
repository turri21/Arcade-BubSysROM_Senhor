/*
    6116 SRAM
*/

module SRAM2k8_obj
(
    input   wire            i_MCLK,
	input   wire    [10:0]  i_ADDR,
	input   wire    [7:0]   i_DIN,
	output  reg     [7:0]   o_DOUT,
	input   wire            i_WR_n,
	input   wire            i_RD_n
);

reg     [7:0]   RAM2k8 [2047:0];

always @(posedge i_MCLK)
begin
    if(i_WR_n == 1'b0)
    begin
        RAM2k8[i_ADDR] <= i_DIN;
    end
end

always @(posedge i_MCLK) //read
begin
    if(i_RD_n == 1'b0)
    begin
        o_DOUT <= RAM2k8[i_ADDR];
    end
end

initial
begin
    $readmemh("init_objram.txt", RAM2k8);
end

endmodule