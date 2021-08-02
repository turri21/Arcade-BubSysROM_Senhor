module SCROLLRAM
(
    input   wire            i_EMU_MCLK, //36.864(PLL 36.868687)
    input   wire    [4:0]   i_EMU_TIMING,

    input   wire            i_VZCS_n,
    input   wire    [10:0]  i_CPUADDR,
    inout   wire    [15:0]  io_CPUDATA,
    input   wire            i_CPURW,
    input   wire            i_CPULDS_n,

    input   wire    [10:0]  i_GFXADDR,
    output  reg     [7:0]   o_GFXDATA = 8'hF
);


///////////////////////////////////////////////////////////
//////  SCROLL RAM
////

reg     [10:0]  SCROLLRAM_ADDRLATCH;
reg     [7:0]   SCROLLRAM_INLATCH;
wire    [7:0]   SCROLLRAM_OUT;
reg             SCROLLRAM_RD = 1'b1;
reg             SCROLLRAM_WR = 1'b1;

reg     [7:0]   SCROLLRAM_CPU_LATCH = 8'hF;
wire            SCROLLRAM_CPU_LATCH_RD = i_VZCS_n | ~i_CPURW;
assign io_CPUDATA[7:0] = (i_CPULDS_n | SCROLLRAM_CPU_LATCH_RD == 1'b0) ? SCROLLRAM_CPU_LATCH : {8{1'bZ}}; //LDS out

RAM2k8 SCROLLRAM_ELEMENT
(
    .i_EMU_MCLK           (i_EMU_MCLK             ),
    .i_ADDR               (SCROLLRAM_ADDRLATCH    ),
    .i_DIN                (SCROLLRAM_INLATCH      ),
    .o_DOUT               (SCROLLRAM_OUT          ),
    .i_RD_n               (SCROLLRAM_RD           ),
    .i_WR_n               (SCROLLRAM_WR           )
);



///////////////////////////////////////////////////////////
//////  SCROLL RAM INTERFACE STATE MACHINE
////

/*
    This state machine emulates original behavior of asynchronous ZURERAM(SCROLLRAM)
    Consist of 6116 SRAM(access speed about 100-150ns) and a LS373 latch for CPU readout
*/

/*

    Note: TM-A is scroll1 in MAME
          TM-B is scroll2 in MAME

    FETCHES HSCROLL(1 PIXEL ROW) VALUE WHEN VCLK = 1

    EXECUTING           S S S S S S S S S S S S
                        0 1 2 0 3 4 5 6 7 8 0 0 

    MCLK                0 1 2 3 4 5 0 1 2 3 4 5
    CLK18M  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|___|¯¯¯|___|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
            ----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|
                             >SRAM DOUT  >SRAM DOUT  >SRAM DOUT  >SRAM DOUT      SRAM async access speed >150ns (2128-15 on every PCB)
    
    TIME1   ___________________|¯¯¯|___________________|¯¯¯|____________
    TIME2   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯
    VCLK    ___________|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    ADDR               |-------(TM-A LO)-------|-------(TM-A HI)-------|
    DEVICE             |---(CPU)---|---(GFX)---|---(CPU)---|---(GFX)---|
                                   |  TM-A LO  |           |  TM-A HI  |


    FETCHES VSCROLL(8 PIXEL COLUMN) VALUE WHEN VCLK = 0
        (TM-A for 4H = 0, TM-B for 4H = 1)

                                            1 1                     1 1                     1 1                     1 1
                        0 1 2 3 4 5 6 7 8 9 0 1 0 1 2 3 4 5 6 7 8 9 0 1 0 1 2 3 4 5 6 7 8 9 0 1 0 1 2 3 4 5 6 7 8 9 0 1
    CLK18M  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|___|¯¯¯|___|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|___|¯¯¯|___|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
            ----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|----(4)----|----(5)----|----(6)----|----(7)----|

    TIME1   ___________________|¯¯¯|___________________|¯¯¯|___________________|¯¯¯|___________________|¯¯¯|____________
    TIME2   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯
    VCLK    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                                                                        
    SCRLATCH¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|
    SCRADDR --(TM-A)---|--------------------(TM-B)---------------------|--------------------(TM-A)---------------------|
    DEVICE  ---(GFX)---|---(CPU)---|---(GFX)---|---(CPU)---|---(GFX)---|---(CPU)---|---(GFX)---|---(CPU)---|---(GFX)---|

    VRAMADDR--(TM-B)---|--------------------(TM-A)---------------------|--------------------(TM-B)---------------------|
                       t0                                              t1                                              t2                     

    0. HSCROLL values for TM-A and TM-B are latched when VCLK = 1

    t0
    1. MUX provides TM-A VSCROLL address when 4H = 0 & VCLK = 0
    2. 005291 latches TM-A VSCROLL value at posedge of ~(1H & 2H)
    3. Then TM-A VSCROLL value will be valid during next 4px-cycle
    4. In this next 4px-cycle, 005291 provides previously latched(at VCLK = 0) TM-A HSCROLL value
    5. ?????
    6. PROFIT!!

    t1
    1. Again, 005291 latches TM-A VSCROLL value at posedge of ~(1H & 2H) since MUX provided TM-B VSCROLL address
    2. Then TM-B VSCROLL value will be valid during next 4px-cycle
    3. In this next 4px-cycle, 005291 provides previously latched(at VCLK = 0) TM-B HSCROLL value
    4. ?????
    5. PROFIT!!
*/

//declare states
localparam SCROLL_ACC_S0 = 4'd0;   //nop
localparam SCROLL_ACC_S1 = 4'd1;   //스크롤램 어드레스 래치에다 CPU 어드레스 넣고, RD=0
localparam SCROLL_ACC_S2 = 4'd2;   //RD=1
localparam SCROLL_ACC_S3 = 4'd3;   //출력값 CPU래치에 넣기(TIME1 LS373 load)
localparam SCROLL_ACC_S4 = 4'd4;   //만약 이때 CPU 비동기 쓰기신호가 내려가있으면 데이터를 INLATCH에 넣고 WR=0(TIME2 6116 /write)
localparam SCROLL_ACC_S5 = 4'd5;   //WR=1
localparam SCROLL_ACC_S6 = 4'd6;   //어드레스 래치에 현재 스크롤좌표 넣고, RD=0
localparam SCROLL_ACC_S7 = 4'd7;   //RD=1
localparam SCROLL_ACC_S8 = 4'd8;   //스크롤값 출력을 GFX래치에 넣기

//state register
reg     [3:0]   SCROLL_ACC_state = SCROLL_ACC_S11;

//flow control
always @(posedge i_EMU_MCLK)
begin
    if(i_EMU_TIMING[3] == 1'b0) //pixel 0
    begin
        case(i_EMU_TIMING[2:0])
            3'd0: SCROLL_ACC_state <= SCROLL_ACC_S2;
            3'd1: SCROLL_ACC_state <= SCROLL_ACC_S0;
            3'd2: SCROLL_ACC_state <= SCROLL_ACC_S3;
            3'd3: SCROLL_ACC_state <= SCROLL_ACC_S4;
            3'd4: SCROLL_ACC_state <= SCROLL_ACC_S5;
            3'd5: SCROLL_ACC_state <= SCROLL_ACC_S6;

            default: SCROLL_ACC_state <= SCROLL_ACC_S0;
        endcase
    end
    else //pixel 1
    begin
        case(i_EMU_TIMING[2:0])
            3'd0: SCROLL_ACC_state <= SCROLL_ACC_S7;
            3'd1: SCROLL_ACC_state <= SCROLL_ACC_S8;
            3'd2: SCROLL_ACC_state <= SCROLL_ACC_S0;
            3'd3: SCROLL_ACC_state <= SCROLL_ACC_S0;
            3'd4: SCROLL_ACC_state <= SCROLL_ACC_S0;
            3'd5: SCROLL_ACC_state <= SCROLL_ACC_S1;

            default: SCROLL_ACC_state <= SCROLL_ACC_S0;
        endcase
    end
end

//output control
always @(posedge i_EMU_MCLK)
begin
    case(SCROLL_ACC_state)
        SCROLL_ACC_S0: begin end
        SCROLL_ACC_S1: begin SCROLLRAM_ADDRLATCH <= i_CPUADDR[10:0]; SCROLLRAM_RD <= 1'b0; end
        SCROLL_ACC_S2: begin SCROLLRAM_RD <= 1'b1; end
        SCROLL_ACC_S3: begin SCROLLRAM_CPU_LATCH <= SCROLLRAM_OUT; end
        SCROLL_ACC_S4: begin if((i_VZCS_n | i_CPURW | i_CPULDS_n) == 1'b0) begin SCROLLRAM_WR <= 1'b0; SCROLLRAM_INLATCH <= io_CPUDATA[7:0]; end end
        SCROLL_ACC_S5: begin SCROLLRAM_WR <= 1'b1; end
        SCROLL_ACC_S6: begin SCROLLRAM_ADDRLATCH <= i_GFXADDR; SCROLLRAM_RD <= 1'b0; end
        SCROLL_ACC_S7: begin SCROLLRAM_RD <= 1'b1; end
        SCROLL_ACC_S8: begin o_GFXDATA <= SCROLLRAM_OUT; end
        
        default: begin end
    endcase
end

endmodule