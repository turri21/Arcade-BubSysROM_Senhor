module VRAM
(
    input   wire            i_EMU_MCLK, //36.864(PLL 36.868687)
    input   wire    [4:0]   i_EMU_TIMING,

    input   wire            i_VCS1_n,
    input   wire            i_VCS2_n,
    input   wire    [11:0]  i_CPUADDR,
    inout   wire    [15:0]  io_CPUDATA,
    input   wire            i_CPURW,
    input   wire            i_CPUUDS_n,
    input   wire            i_CPULDS_n,


    input   wire    [11:0]  i_GFXADDR,
    output  reg     [15:0]  o_VRAM1GFXDATA = 16'hFF,
    output  reg     [7:0]   o_VRAM2GFXDATA = 8'hF
);

///////////////////////////////////////////////////////////
//////  VRAM
////

//declare 16bit width VRAM 1
reg     [11:0]  VRAM1_ADDRLATCH;
reg     [7:0]   VRAM1_0_INLATCH;
reg     [7:0]   VRAM1_1_INLATCH;
wire    [15:0]  VRAM1_OUT;
reg             VRAM1_RD = 1'b1;
reg             VRAM1_WR = 1'b1;
reg             VRAM1_SEL0 = 1'b1;
reg             VRAM1_SEL1 = 1'b1;

reg     [7:0]   VRAM1U_CPU_LATCH = 8'hF;
reg     [7:0]   VRAM1L_CPU_LATCH = 8'hF;
wire            VRAM1_CPU_LATCH_RD = i_VCS1_n | ~i_CPURW;
assign io_CPUDATA[15:8] = ((i_CPUUDS_n | VRAM1_CPU_LATCH_RD) == 1'b0) ? VRAM1U_CPU_LATCH : {8{1'bZ}}; //UDS out
assign io_CPUDATA[7:0] = ((i_CPULDS_n | VRAM1_CPU_LATCH_RD) == 1'b0) ? VRAM1L_CPU_LATCH : {8{1'bZ}}; //LDS out

RAM4k16 VRAM1_ELEMENT
(
    .i_EMU_MCLK             (i_EMU_MCLK             ),
    .i_ADDR                 (VRAM1_ADDRLATCH        ),
    .i_DIN                  ({VRAM1_0_INLATCH, VRAM1_1_INLATCH}),
    .o_DOUT                 (VRAM1_OUT              ),
    .i_RD_n                 (VRAM1_RD               ),
    .i_WR_n                 (VRAM1_WR               ),
    .i_SEL0_n               (VRAM1_SEL0             ),
    .i_SEL1_n               (VRAM1_SEL1             ) 
);


//declare 8bit width VRAM 2
reg     [11:0]  VRAM2_ADDRLATCH;
reg     [7:0]   VRAM2_INLATCH;
wire    [7:0]   VRAM2_OUT;
reg             VRAM2_RD = 1'b1;
reg             VRAM2_WR = 1'b1;

reg     [7:0]   VRAM2_CPU_LATCH = 8'hF;
wire            VRAM2_CPU_LATCH_RD = i_VCS2_n | ~i_CPURW;
assign io_CPUDATA[7:0] = (i_CPULDS_n | VRAM2_CPU_LATCH_RD == 1'b0) ? VRAM2_CPU_LATCH : {8{1'bZ}}; //LDS out

RAM4k8 VRAM2_ELEMENT
(
    .i_EMU_MCLK             (i_EMU_MCLK                 ),
    .i_ADDR                 (VRAM2_ADDRLATCH        ),
    .i_DIN                  (VRAM2_INLATCH          ),
    .o_DOUT                 (VRAM2_OUT              ),
    .i_RD_n                 (VRAM2_RD               ),
    .i_WR_n                 (VRAM2_WR               )
);



///////////////////////////////////////////////////////////
//////  VIDEO RAM INTERFACE STATE MACHINE
////

/*
    EXECUTING           S S S S S S S S S S S S S S S S S S S S S S S S                 
                        0 0 1 0 2 3 4 0 0 0 0 0 0 0 0 0 5 6 7 0 0 0 0 0
    MCLK                           
                        0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 
    CLK18M  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
    PIXEL   ----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|----(4)----|----(5)----|----(6)----|----(7)----|
    /DTACK  ¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                             >SRAM CPU DIN                 >SRAM GFX DOUT          >SRAM CPU DOUT          >SRAM GFX DOUT    SRAM async access speed 100ns (TC5533-P on every PCB)
    VRTIME  ¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     6264 CE2 is always 1 in cpu access cycle
    DEVICE             |---------(CPU)---------|---------(GFX)---------|---------(CPU)---------|---------(GFX)---------|
                                   |(RD VALID)-|                                   |(RD VALID)-|                             ext. gates allow RD during pixel 0 and 1 cycles
                             |WRVAL|                                         |WRVAL|                                         ext. gates allow WR during pixel 0 cycle
                       |                 VRAM ADDR TM-A                |                 VRAM ADDR TM-B                |

                                                                       >VRAM ADDR TM-A latched by LS273 at /2H
                                                                                                                       >CHARRAM TM-A line data latched
*/

//declare states
localparam VRAM_ACC_S0 = 3'd0;      //nop
localparam VRAM_ACC_S1 = 3'd1;      //CS내려갔으면 어드레스 래치에 어드레스 넣기 
localparam VRAM_ACC_S2 = 3'd2;      //WR이면 INLATCH에 CPU데이터 넣고 WR=0, RD면 SEL선택하고 RD=0
localparam VRAM_ACC_S3 = 3'd3;      //WR=1(SEL도 1로 복귀), RD=1 
localparam VRAM_ACC_S4 = 3'd4;      //VRAM_OUT데이터 CPULATCH에 넣기
localparam VRAM_ACC_S5 = 3'd5;      //어드레스 래치에 스크롤 어드레스 넣기, RD=0
localparam VRAM_ACC_S6 = 3'd6;      //RD=1
localparam VRAM_ACC_S7 = 3'd7;      //VRAM_OUT데이터 GFX_LATCH에 넣기

//state register
reg     [2:0]   VRAM_ACC_state = VRAM_ACC_S0;

//flow control
always @(posedge i_EMU_MCLK)
begin
    case(i_EMU_TIMING[4:3])
        2'd0: //pixel 0
        begin
            case(i_EMU_TIMING[2:0])
                4'd0: VRAM_ACC_state <= VRAM_ACC_S1;
                4'd1: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd2: VRAM_ACC_state <= VRAM_ACC_S2;
                4'd3: VRAM_ACC_state <= VRAM_ACC_S3;
                4'd4: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd5: VRAM_ACC_state <= VRAM_ACC_S0;
                default: VRAM_ACC_state <= VRAM_ACC_S0;
            endcase
        end
        2'd1: //pixel 1
        begin
            case(i_EMU_TIMING[2:0])
                4'd0: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd1: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd2: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd3: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd4: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd5: VRAM_ACC_state <= VRAM_ACC_S0;
                default: VRAM_ACC_state <= VRAM_ACC_S0;
            endcase
        end
        2'd2: //pixel 2
        begin
            case(i_EMU_TIMING[2:0])
                4'd0: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd1: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd2: VRAM_ACC_state <= VRAM_ACC_S5;
                4'd3: VRAM_ACC_state <= VRAM_ACC_S6;
                4'd4: VRAM_ACC_state <= VRAM_ACC_S7;
                4'd5: VRAM_ACC_state <= VRAM_ACC_S0;
                default: VRAM_ACC_state <= VRAM_ACC_S0;
            endcase
        end
        2'd3: //pixel 3
        begin
            case(i_EMU_TIMING[2:0])
                4'd0: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd1: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd2: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd3: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd4: VRAM_ACC_state <= VRAM_ACC_S0;
                4'd5: VRAM_ACC_state <= VRAM_ACC_S0;
                default: VRAM_ACC_state <= VRAM_ACC_S0;
            endcase
        end
    endcase
end

//output control
always @(posedge i_EMU_MCLK)
begin
    case(VRAM_ACC_state)
        VRAM_ACC_S0: begin end
        VRAM_ACC_S1: 
        begin 
            if(i_VCS1_n == 1'b0)
            begin
                VRAM1_ADDRLATCH <= i_CPUADDR;
            end

            if(i_VCS2_n == 1'b0)
            begin
                VRAM2_ADDRLATCH <= i_CPUADDR;
            end
        end
        VRAM_ACC_S2:
        begin
            if(i_CPURW == 1'b1) //read
            begin
                if(i_VCS1_n == 1'b0)
                begin
                    if(i_CPUUDS_n == 1'b0)
                    begin
                        VRAM1_SEL0 <= 1'b0;
                    end

                    if(i_CPULDS_n == 1'b0)
                    begin
                        VRAM1_SEL1 <= 1'b0;
                    end

                    VRAM1_RD <= 1'b0;
                end

                if(i_VCS2_n == 1'b0)
                begin
                    VRAM2_WR <= 1'b0;
                end
            end
            else //write
            begin
                if(i_VCS1_n == 1'b0)
                begin
                    if(i_CPUUDS_n == 1'b0)
                    begin
                        VRAM1_0_INLATCH <= io_CPUDATA[15:8];
                        VRAM1_SEL0 <= 1'b0;
                    end

                    if(i_CPULDS_n == 1'b0)
                    begin
                        VRAM1_1_INLATCH <= io_CPUDATA[7:0];
                        VRAM1_SEL1 <= 1'b0;
                    end

                    VRAM1_WR <= 1'b0;
                end

                if(i_VCS2_n== 1'b0)
                begin
                    if(i_CPULDS_n == 1'b0)
                    begin
                        VRAM2_INLATCH <= io_CPUDATA[7:0];
                    end

                    VRAM2_WR <= 1'b0;
                end
            end
        end
        VRAM_ACC_S3:
        begin
            VRAM1_SEL0 <= 1'b1;
            VRAM1_SEL1 <= 1'b1;
            VRAM1_WR <= 1'b1;
            VRAM2_WR <= 1'b1;
            VRAM1_RD <= 1'b1;
            VRAM2_RD <= 1'b1;
        end
        VRAM_ACC_S4:
        begin
            if(i_VCS1_n | ~i_CPURW == 1'b0)
            begin
                if(i_CPUUDS_n == 1'b0)
                begin
                    VRAM1U_CPU_LATCH <= VRAM1_OUT[15:8];
                end

                if(i_CPULDS_n == 1'b0)
                begin
                    VRAM1L_CPU_LATCH <= VRAM1_OUT[7:0];
                end
            end

            if(i_VCS2_n | ~i_CPURW == 1'b0)
            begin
                VRAM2_CPU_LATCH <= VRAM2_OUT;
            end
        end
        VRAM_ACC_S5: 
        begin
            VRAM1_ADDRLATCH <= i_GFXADDR;
            VRAM2_ADDRLATCH <= i_GFXADDR;

            VRAM1_SEL0 <= 1'b0;
            VRAM1_SEL1 <= 1'b0;
            VRAM1_RD <= 1'b0;
            VRAM2_RD <= 1'b0;
        end
        VRAM_ACC_S6:
        begin 
            VRAM1_SEL0 <= 1'b1;
            VRAM1_SEL1 <= 1'b1;
            VRAM1_RD <= 1'b1;
            VRAM2_RD <= 1'b1;
        end
        VRAM_ACC_S7:
        begin 
            o_VRAM1GFXDATA <= VRAM1_OUT;
            o_VRAM2GFXDATA <= VRAM2_OUT;
        end
    endcase
end

endmodule