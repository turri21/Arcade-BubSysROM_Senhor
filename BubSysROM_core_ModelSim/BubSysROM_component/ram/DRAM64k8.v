/*
    4164 DRAM * 8
*/

module DRAM64k8
(
    input   wire            i_MCLK,
	input   wire    [7:0]   i_ADDR,
	input   wire    [7:0]   i_DIN,
	output  reg     [7:0]   o_DOUT,
    input   wire            i_RAS_n,
    input   wire            i_CAS_n,
	input   wire            i_WR_n
);

reg     [7:0]   RAM64k8 [65535:0];
reg             prev_ras;
reg             prev_cas;
reg     [7:0]   ROW_ADDR;
reg     [7:0]   COL_ADDR;
wire    [15:0]  ADDR = {COL_ADDR, ROW_ADDR};


always @(posedge i_MCLK)
begin
    prev_ras <= i_RAS_n;
    prev_cas <= i_CAS_n;

    if(i_RAS_n == 1'b0 && prev_ras == 1'b1)
    begin
        ROW_ADDR <= i_ADDR;
    end

    if(i_CAS_n == 1'b0 && prev_cas == 1'b1)
    begin
        COL_ADDR <= i_ADDR;
    end
end


always @(posedge i_MCLK)
begin
    o_DOUT <= RAM64k8[ADDR];

    if(i_WR_n == 1'b0)
    begin
        RAM64k8[ADDR] <= i_DIN;
    end
end




endmodule