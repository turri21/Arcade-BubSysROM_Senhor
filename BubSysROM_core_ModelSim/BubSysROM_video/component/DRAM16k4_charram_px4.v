/*
    4416 DRAM
*/

module DRAM16k4_charram_px4
(
    input   wire            i_MCLK,
	input   wire    [7:0]   i_ADDR,
	input   wire    [3:0]   i_DIN,
	output  reg     [3:0]   o_DOUT,
    input   wire            i_RAS_n,
    input   wire            i_CAS_n,
	input   wire            i_WR_n,
	input   wire            i_RD_n
);

reg     [3:0]   RAM16k4 [16383:0];
reg     [7:0]   __ROW_ADDR;
reg     [5:0]   __COL_ADDR;
wire    [13:0]  __ADDR = {__COL_ADDR, __ROW_ADDR};

/*
    MCLK                                    1 1
                        0 1 2 3 4 5 6 7 8 9 0 1 
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
    PIXEL   ----(3)----|----(4)----|----(5)----|----(6)----|----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|
    /DTACK  ¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                               |-----------| = access time = 162.75ns
                                   >row
                                       >column
                                           >launch
                                               >CPU acquisition
    CHAMPX1 ¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    /RAS    ___________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|________________ 
    /CAS    _______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|____________
*/

always @(posedge i_MCLK)
begin
    if(i_RAS_n == 1'b0 && i_CAS_n == 1'b1)
    begin
        __ROW_ADDR <= i_ADDR;
    end

    if(i_CAS_n == 1'b0)
    begin
        __COL_ADDR <= i_ADDR[6:1];
    end
end


always @(posedge i_MCLK)
begin
    if(i_WR_n == 1'b0)
    begin
        RAM16k4[__ADDR] <= i_DIN;
    end
end

always @(posedge i_MCLK) //read
begin
    if(i_RD_n == 1'b0)
    begin
        o_DOUT <= RAM16k4[__ADDR];
    end
end

initial
begin
    $readmemh("charram_px4.txt", RAM16k4);
end

endmodule