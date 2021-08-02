module CHARRAM
(
    input   wire            i_EMU_MCLK, //36.864(PLL 36.868687)
    input   wire    [4:0]   i_EMU_TIMING,

    input   wire            i_CHARCS_n,
    input   wire    [14:0]  i_CPUADDR,
    inout   wire    [15:0]  io_CPUDATA,
    input   wire            i_CPURW,
    input   wire            i_CPUUDS_n,
    input   wire            i_CPULDS_n,

    input   wire    [13:0]  i_GFXADDR,
    output  reg     [31:0]  o_GFXDATA = 32'hFFFF
);


///////////////////////////////////////////////////////////
//////  CHARRAM
////

/*
    A1    MSB           D A T A           LSB
     0   |---(8bit SEL0)---|---(8bit SEL1)---|
     1   |---(8bit SEL2)---|---(8bit SEL3)---|

    BIG ENDIAN
*/

//declare 32bit width CHARRAM
reg     [13:0]  CHARRAM_ADDRLATCH;
reg     [7:0]   CHARRAM_0_INLATCH;
reg     [7:0]   CHARRAM_1_INLATCH;
reg     [7:0]   CHARRAM_2_INLATCH;
reg     [7:0]   CHARRAM_3_INLATCH;
wire    [31:0]  CHARRAM_OUT;
reg             CHARRAM_RD = 1'b1;
reg             CHARRAM_WR = 1'b1;
reg             CHARRAM_SEL0 = 1'b1;
reg             CHARRAM_SEL1 = 1'b1;
reg             CHARRAM_SEL2 = 1'b1;
reg             CHARRAM_SEL3 = 1'b1;

reg     [7:0]   CHARRAMU_CPU_LATCH = 8'hF;
reg     [7:0]   CHARRAML_CPU_LATCH = 8'hF;
wire            CHARRAM_CPU_LATCH_RD = i_CHARCS_n | ~i_CPURW;
assign io_CPUDATA[15:8] = ((i_CPUUDS_n | CHARRAM_CPU_LATCH_RD) == 1'b0) ? CHARRAMU_CPU_LATCH : {8{1'bZ}}; //UDS out
assign io_CPUDATA[7:0] = ((i_CPULDS_n | CHARRAM_CPU_LATCH_RD) == 1'b0) ? CHARRAML_CPU_LATCH : {8{1'bZ}}; //LDS out

RAM16k32 CHARRAM_ELEMENT
(
    .i_EMU_MCLK             (i_EMU_MCLK             ),
    .i_ADDR                 (CHARRAM_ADDRLATCH      ),
    .i_DIN                  ({CHARRAM_0_INLATCH, CHARRAM_1_INLATCH, CHARRAM_2_INLATCH, CHARRAM_3_INLATCH,}),
    .o_DOUT                 (CHARRAM_OUT            ),
    .i_RD_n                 (CHARRAM_RD             ),
    .i_WR_n                 (CHARRAM_WR             ),
    .i_SEL0_n               (CHARRAM_SEL0           ),
    .i_SEL1_n               (CHARRAM_SEL1           ),
    .i_SEL2_n               (CHARRAM_SEL2           ),
    .i_SEL3_n               (CHARRAM_SEL3           )
);



///////////////////////////////////////////////////////////
//////  CHARACTER RAM INTERFACE STATE MACHINE
////

/*
    EXECUTING           S S S S S S S S S S S S S S S S S S S S S S S S S                 
                        0 0 0 0 0 1 2 3 0 0 0 0 0 0 0 0 0 4 5 6 0 0 0 0 0
    MCLK                                    1 1
                        0 1 2 3 4 5 6 7 8 9 0 1 
    CLK18M  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
    PIXEL   ----(3)----|----(4)----|----(5)----|----(6)----|----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|
    /DTACK  ¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


    CHAMPX1 ¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
    /RAS    ____________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________     15ns(LS14) delayed
    /CAS    ________________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|___________     15ns*4(LS14) + 25ns(220pF) = about 85ns delayed

                                     >DRAM CPU/REFRESH       >DRAM GFX DOUT          >DRAM CPU/REFRESH       >DRAM GFX DOU   DRAM async access speed 150ns (TMS4416)
                                                                                                                             Automatically refreshes ROW ADDRESS during CPU/HV counter access cycle                                                                                                           
    DEVICE             |---------(CPU)---------|---------(GFX)---------|---------(CPU)---------|---------(GFX)---------|
    LATCHED CPU WR ¯¯¯¯¯¯¯¯¯¯¯¯|_______________________|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                                     |(WR VALID)-|                                   |(WR VALID)-|                                
                                     |(RD VALID)-|                                   |(RD VALID)-|
                       |                CHARRAM ADDR TM-A              |                CHARRAM ADDR TM-B              |

                                                                       >CHARRAM TM-A data latched by K005290
                                                                                                                       >CHARRAM data TM-B latched by K005290
*/

//declare states
localparam CHARRAM_ACC_S0 = 3'd0;      //nop
localparam CHARRAM_ACC_S1 = 3'd1;      //CS내려갔으면 어드레스 래치에 어드레스 넣기, RD면 RD=0, WR이면 INLATCH에 CPU데이터 넣고 WR=0
localparam CHARRAM_ACC_S2 = 3'd2;      //RD면 RD=1, WR=1(SEL도 1로 복귀)
localparam CHARRAM_ACC_S3 = 3'd3;      //CPU OUTLATCH에 데이터 넣기
localparam CHARRAM_ACC_S4 = 3'd4;      //어드레스 래치에 어드레스 넣기, RD=0
localparam CHARRAM_ACC_S5 = 3'd5;      //RD=1
localparam CHARRAM_ACC_S6 = 3'd6;      //GFXDATA에 넣기

//state register
reg     [2:0]   CHARRAM_ACC_state = CHARRAM_ACC_S0;

//flow control
always @(posedge i_EMU_MCLK)
begin
    case(i_EMU_TIMING[4:3])
        2'd0: //pixel 0
        begin
            case(i_EMU_TIMING[2:0])
                3'd0: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd1: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd2: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd3: CHARRAM_ACC_state <= CHARRAM_ACC_S1;
                3'd4: CHARRAM_ACC_state <= CHARRAM_ACC_S2;
                3'd5: CHARRAM_ACC_state <= CHARRAM_ACC_S3;
                default: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
            endcase
        end
        2'd1: //pixel 1
        begin
            case(i_EMU_TIMING[2:0])
                3'd0: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd1: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd2: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd3: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd4: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd5: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                default: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
            endcase
        end
        2'd2: //pixel 2
        begin
            case(i_EMU_TIMING[2:0])
                3'd0: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd1: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd2: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd3: CHARRAM_ACC_state <= CHARRAM_ACC_S4;
                3'd4: CHARRAM_ACC_state <= CHARRAM_ACC_S5;
                3'd5: CHARRAM_ACC_state <= CHARRAM_ACC_S6;
                default: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
            endcase
        end
        2'd3: //pixel 3
        begin
            case(i_EMU_TIMING[2:0])
                3'd0: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd1: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd2: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd3: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd4: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                3'd5: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
                default: CHARRAM_ACC_state <= CHARRAM_ACC_S0;
            endcase
        end
    endcase
end

//output control
always @(posedge i_EMU_MCLK)
begin
    case(CHARRAM_ACC_state)
        CHARRAM_ACC_S0: begin end
        CHARRAM_ACC_S1: 
        begin 
            if(i_CHARCS_n == 1'b0)
            begin
                CHARRAM_ADDRLATCH <= i_CPUADDR[14:1]; //A1=0 CHACS1, A1=1 CHACS2
            end

            if(i_CPURW == 1'b1) //read
            begin
                if(i_CHARCS_n == 1'b0)
                begin
                    if(i_CPUADDR[0] == 1'b0) //CHACS1
                    begin
                        if(i_CPUUDS_n == 1'b0)
                        begin
                            CHARRAM_SEL0 <= 1'b0;
                        end

                        if(i_CPULDS_n == 1'b0)
                        begin
                            CHARRAM_SEL1 <= 1'b0;
                        end

                        CHARRAM_RD <= 1'b0;
                    end
                    else //CHACS2
                    begin
                        if(i_CPUUDS_n == 1'b0)
                        begin
                            CHARRAM_SEL2 <= 1'b0;
                        end

                        if(i_CPULDS_n == 1'b0)
                        begin
                            CHARRAM_SEL3 <= 1'b0;
                        end

                        CHARRAM_RD <= 1'b0;
                    end
                end
            end
            else //write
            begin
                if(i_CHARCS_n == 1'b0)
                begin
                    if(i_CPUADDR[0] == 1'b0) //CHACS1
                    begin
                        if(i_CPUUDS_n == 1'b0)
                        begin
                            CHARRAM_0_INLATCH <= io_CPUDATA[15:8];
                            CHARRAM_SEL0 <= 1'b0;
                        end

                        if(i_CPULDS_n == 1'b0)
                        begin
                            CHARRAM_1_INLATCH <= io_CPUDATA[7:0];
                            CHARRAM_SEL1 <= 1'b0;
                        end

                        CHARRAM_WR <= 1'b0;
                    end
                    else //CHACS2
                    begin
                        if(i_CPUUDS_n == 1'b0)
                        begin
                            CHARRAM_2_INLATCH <= io_CPUDATA[15:8];
                            CHARRAM_SEL2 <= 1'b0;
                        end

                        if(i_CPULDS_n == 1'b0)
                        begin
                            CHARRAM_3_INLATCH <= io_CPUDATA[7:0];
                            CHARRAM_SEL3 <= 1'b0;
                        end

                        CHARRAM_WR <= 1'b0;
                    end
                end

            end
        end
        CHARRAM_ACC_S2:
        begin
            CHARRAM_SEL0 <= 1'b1;
            CHARRAM_SEL1 <= 1'b1;
            CHARRAM_SEL2 <= 1'b1;
            CHARRAM_SEL3 <= 1'b1;
            CHARRAM_WR <= 1'b1;
            CHARRAM_RD <= 1'b1;
        end
        CHARRAM_ACC_S3:
        begin
            if(i_CPURW == 1'b1) //read
            begin
                if(i_CHARCS_n == 1'b0)
                begin
                    if(i_CPUADDR[0] == 1'b0) //CHACS1
                    begin
                        if(i_CPUUDS_n == 1'b0)
                        begin
                            CHARRAMU_CPU_LATCH <= CHARRAM_OUT[31:24];
                        end

                        if(i_CPULDS_n == 1'b0)
                        begin
                            CHARRAML_CPU_LATCH <= CHARRAM_OUT[23:16];
                        end
                    end
                    else //CHACS2
                    begin
                        if(i_CPUUDS_n == 1'b0)
                        begin
                            CHARRAMU_CPU_LATCH <= CHARRAM_OUT[15:8];
                        end

                        if(i_CPULDS_n == 1'b0)
                        begin
                            CHARRAMU_CPU_LATCH <= CHARRAM_OUT[7:0];
                        end
                    end
                end
            end
        end
        CHARRAM_ACC_S4:
        begin
            CHARRAM_ADDRLATCH <= i_GFXADDR;

            CHARRAM_SEL0 <= 1'b0;
            CHARRAM_SEL1 <= 1'b0;
            CHARRAM_SEL2 <= 1'b0;
            CHARRAM_SEL3 <= 1'b0;
            CHARRAM_RD <= 1'b0;
        end
        CHARRAM_ACC_S5: 
        begin
            CHARRAM_SEL0 <= 1'b1;
            CHARRAM_SEL1 <= 1'b1;
            CHARRAM_SEL2 <= 1'b1;
            CHARRAM_SEL3 <= 1'b1;
            CHARRAM_RD <= 1'b1;
        end
        CHARRAM_ACC_S6:
        begin 
            o_GFXDATA <= CHARRAM_OUT;
        end

        default: begin end
    endcase
end

endmodule