module BubSysROM_video
(
    input   wire            i_EMU_MCLK,
    input   wire            i_EMU_CLK18MNCEN_n,

    output  wire            o_EMU_CLK9MPCEN_n, //REF_CLK9M
    output  wire            o_EMU_CLK9MNCEN_n,
    output  wire            o_EMU_CLK6MPCEN_n, //REF_CLK6M
    output  wire            o_EMU_CLK6MNCEN_n,

    input   wire    [15:0]  i_CPU_ADDR,
    input   wire    [16:0]  i_CPU_DIN,
    output  wire    [16:0]  i_CPU_DOUT,
    input   wire            i_CPU_RW,
    input   wire            i_CPU_UDS_n,
    input   wire            i_CPU_LDS_n,

    input   wire            i_VZCS_n,

    input   wire            i_HFLIP,
    input   wire            i_VFLIP


);








///////////////////////////////////////////////////////////
//////  CLOCK DIVIDER
////

/*
    MCLK72  ################################################ or
    MCLK36  |||||||||||||||||||||||||||||||||||||||||||||||| or
    MCLK18  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    18MNCEN ¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||¯¯||

            0   1   2   3   4   5 
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|

    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|
    9MPCEN  ¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||
    9MNCEN  ¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯¯¯||¯¯¯¯

    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
    6MPCEN  ¯¯¯¯¯¯¯¯¯¯||¯¯¯¯¯¯¯¯¯¯||¯¯¯¯¯¯¯¯¯¯||¯¯¯¯¯¯¯¯¯¯||
    6MNCEN  ¯¯¯¯¯¯||¯¯¯¯¯¯¯¯¯¯||¯¯¯¯¯¯¯¯¯¯||¯¯¯¯¯¯¯¯¯¯||¯¯¯¯
*/

reg     [2:0]   clock_counter_6 = 3'd5;
reg     [3:0]   cen_register = 4'b1111;

always @(posedge i_EMU_MCLK) 
begin
    if(!i_EMU_CLK18MNCEN_n) 
    begin
        if(ref_clock_counter_6 < 3'd5) 
        begin
            ref_clock_counter_6 <= ref_clock_counter_6 + 3'd1;
        end
        else 
        begin
            ref_clock_counter_6 <= 3'd0;
        end
    end
end

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK18MNCEN_n)
    begin
        case(ref_clock_counter_12)
            4'd0: cen_register  <= 4'b0110;
            4'd1: cen_register  <= 4'b1001;
            4'd2: cen_register  <= 4'b0111;
            4'd3: cen_register  <= 4'b1010;
            4'd4: cen_register  <= 4'b0101;
            4'd5: cen_register  <= 4'b1011;
            default: cen_register <= 4'b1111;
        endcase
    end
end

//ORed with 18M positive cen
assign  o_EMU_CLK9MPCEN_n = cen_register[3] | i_EMU_CLK18MNCEN_n;
assign  o_EMU_CLK9MNCEN_n = cen_register[2] | i_EMU_CLK18MNCEN_n;
assign  o_EMU_CLK6MPCEN_n = cen_register[1] | i_EMU_CLK18MNCEN_n;
assign  o_EMU_CLK6MNCEN_n = cen_register[0] | i_EMU_CLK18MNCEN_n;

//for reference
wire            __REF_CLK9M = cen_register[3];
wire            __REF_CLK6M = cen_register[1];








///////////////////////////////////////////////////////////
//////  K005292
////

//
//  asic seciton
//

wire            HBLANK_n;
wire            VBLANK_n;
wire            VBLANKH_n;

wire            ABS_256H;
wire            ABS_n256H = ~ABS_256H;
wire            ABS_128H;
wire            ABS_128HA = (ABS_256H & ABS_128H) | (~ABS_256H & ABS_32H);
wire            ABS_64H;
wire            ABS_32H;
wire            ABS_16H;
wire            ABS_8H;
wire            ABS_4H;
wire            ABS_2H;
wire            ABS_1H;

wire            ABS_128V;
wire            ABS_64V;
wire            ABS_32V;
wire            ABS_16V;
wire            ABS_8V;
wire            ABS_4V;
wire            ABS_2V;
wire            ABS_1V;

wire            FLIP_n256H  = ABS_n256H ^ i_HFLIP;
wire            FLIP_128H;
wire            FLIP_64H;
wire            FLIP_32H;
wire            FLIP_16H;
wire            FLIP_8H;
wire            FLIP_4H;
wire            FLIP_2H;
wire            FLIP_1H;

wire            FLIP_128V;
wire            FLIP_64V;
wire            FLIP_32V;
wire            FLIP_16V;
wire            FLIP_8V;
wire            FLIP_4V;
wire            FLIP_2V;
wire            FLIP_1V;

//declare K005292 core: this core does not have LS393 sprite code up counter
K005292 K005292_main
(
    .i_EMU_MCLK                 (i_EMU_MCLK                 ),
    .i_EMU_CLK6MPCEN_n          (o_EMU_CLK6MPCEN_n          ),

    .i_MRST_n                   (                           ),

    .i_HFLIP                    (                           ),
    .i_VFLIP                    (                           ),

    .o_HBLANK_n                 (                           ),
    .o_VBLANK_n                 (                           ),
    .o_VBLANKH_n                (                           ),  //VBLANK**

    .o_ABS_256H                 (ABS_256H                   ),
    .o_ABS_128H                 (ABS_128H                   ),
    .o_ABS_64H                  (ABS_64H                    ),
    .o_ABS_32H                  (ABS_32H                    ),
    .o_ABS_16H                  (ABS_16H                    ),
    .o_ABS_8H                   (ABS_8H                     ),
    .o_ABS_4H                   (ABS_4H                     ),
    .o_ABS_2H                   (ABS_2H                     ),
    .o_ABS_1H                   (ABS_1H                     ),

    .o_ABS_128V                 (ABS_128V                   ),
    .o_ABS_64V                  (ABS_64V                    ),
    .o_ABS_32V                  (ABS_32V                    ),
    .o_ABS_16V                  (ABS_16V                    ),
    .o_ABS_8V                   (ABS_8V                     ),
    .o_ABS_4V                   (ABS_4V                     ),
    .o_ABS_2V                   (ABS_2V                     ),
    .o_ABS_1V                   (ABS_1V                     ),

    .o_FLIP_128H                (FLIP_128H                  ),
    .o_FLIP_64H                 (FLIP_64H                   ),
    .o_FLIP_32H                 (FLIP_32H                   ),
    .o_FLIP_16H                 (FLIP_16H                   ),
    .o_FLIP_8H                  (FLIP_8H                    ),
    .o_FLIP_4H                  (FLIP_4H                    ),
    .o_FLIP_2H                  (FLIP_2H                    ),
    .o_FLIP_1H                  (FLIP_1H                    ),

    .o_FLIP_128V                (FLIP_128V                  ),
    .o_FLIP_64V                 (FLIP_64V                   ),
    .o_FLIP_32V                 (FLIP_32V                   ),
    .o_FLIP_16V                 (FLIP_16V                   ),
    .o_FLIP_8V                  (FLIP_8V                    ),
    .o_FLIP_4V                  (FLIP_4V                    ),
    .o_FLIP_2V                  (FLIP_2V                    ),
    .o_FLIP_1V                  (FLIP_1V                    ),

    .o_VCLK                     (                           ),

    .o_FRAMEPARITY              (                           ),  //256V
    .o_DMA_n                    (                           ),
    
    .o_VSYNC_n                  (                           ),
    .o_CSYNC_n                  (                           )
);



//
//  MEMORY TIMING GENERATOR SECTION
//

/*
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
            ---(511)---|----(0)----|----(1)----|----(2)----|
    
    TIME1   ___________________|¯¯¯|___________________|¯¯¯|
    TIME2   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|
    CHAMPX  ¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯
    VRTIME  ¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯
    OBJCLRWE¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯
    
    BUFWE   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯
    BUFRAS  ___________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|____
    dl-ras  ____________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|___
*/

//timing singals
wire            TIME1; //SCROLLRAM/OBJRAM read latch enable(active high)
wire            TIME2; //SCROLLRAM/OBJRAM data write enable(active low)
wire            VRTIME; //Video Read TIME
wire            CHAMPX; //CHAracter MultiPleXer
wire            OBJCLRWE; //OBJect CLeaR Write Enable

//17H LS74A(1HF)
reg             DFF_17H_A; //1HF
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MPCEN_n)
    begin
        DFF_17H_A <= ABS_1H;
    end
end

//15H LS164
reg     [3:0]   SR_15H; //QA QB QC QD
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK18MNCEN_n)
    begin
        SR_15H[3] <= DFF_17H_A;
        SR_15H[2:0] <= SR_15H[3:1];
    end
end

assign  TIME1 = ~(~DFF_17H_A | __REF_CLK6M); //16H LS02 NOR
assign  TIME2 = ~(DFF_17H_A & SR_15H[2]); //15G LS00 NAND
assign  VRTIME = ~(DFF_17H_A & ~SR_15H[3]); //15G LS00 NAND
assign  CHAMPX = SR_15H[2] | SR_15H[1]; //CHAMPX+CHAMPX1 14H LS32 OR
assign  OBJCLRWE = SR_15H[2] | ~SR_15H[1]; //14H LS32 OR



//
//  VIDEO TIMING GENERATOR SECTION
//

//timing singals
wire            OBJRW; //switches mux between active display+buffer clear/005295 write
wire            OBJCLR; //fix mux output as 0 when clearing the buffer by writing 0s
wire            BLK; //LS09 driver disable

//19H LS74A
reg             DFF_19H_A;
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MPCEN_n)
    begin
        if({ABS_8H, ABS_4H, ABS_2H, ABS_1H} == 4'd15) //posedge of 16H
        begin
            DFF_19H_A <= ~(HBLANK_n & VBLANKH_n); //15G LS00 NAND
        end        
    end
end

//19H LS74B
reg             DFF_19H_B;
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MNCEN_n) //negedge cen
    begin
        if(ABS_1H == 1'b0) //every EVEN pixel
        begin
            DFF_19H_B <= DFF_19H_A;
        end        
    end
end

//20H LS74B
reg             DFF_20H_B;
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MPCEN_n)
    begin
        if({ABS_2H, ABS_1H} == 2'd3) //posedge of 4H
        begin
            DFF_20H_B <= DFF_19H_A;
        end        
    end
end

//20H LS74B
reg             DFF_20H_A;
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MPCEN_n)
    begin
        DFF_20H_A <= DFF_20H_B;   
    end
end

//17A LS74A
reg             DFF_17A_A;
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MPCEN_n)
    begin
        DFF_17A_A <= ~DFF_20H_A & VBLANK_n; //21H LS08 AND
    end
end

assign  OBJRW = DFF_19H_B;
assign  OBJCLR = ~DFF_19H_B;
assign  BLK = DFF_17A_A;








///////////////////////////////////////////////////////////
//////  K005291
////

//
//  scrollram seciton
//

/*
    Note: TM-A is scroll1 in MAME
          TM-B is scroll2 in MAME

    FETCHES HSCROLL(1 PIXEL ROW) VALUE WHEN VCLK = 1

    MCLK                0 1 2 3 4 5 0 1 2 3 4 5
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|
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
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
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

    t1
    1. Again, 005291 latches TM-A VSCROLL value at posedge of ~(1H & 2H) since MUX provided TM-B VSCROLL address
    2. Then TM-B VSCROLL value will be valid during next 4px-cycle
    3. In this next 4px-cycle, 005291 provides previously latched(at VCLK = 0) TM-B HSCROLL value
*/

//make scrollram address
wire    [10:0]  scrollval_addr;
assign  scrollval_addr =    (~i_VCLK == 1'b0) ? 
                                {1'b0, ABS_4H, ABS_2H, FLIP_128V, FLIP_64V,  FLIP_32V,  FLIP_16V,  FLIP_8V,  FLIP_4V,  FLIP_2V, FLIP_1V} : //HORIZONTAL SCROLL
                                {1'b1,   1'b1,   1'b1,      1'b1,   ABS_4H,FLIP_n256H, FLIP_128H, FLIP_64H, FLIP_32H, FLIP_16H, FLIP_8H};  //VERTICAL SCROLL

wire    [10:0]  scrollram_addr;
assign  scrollram_addr =    (~ABS_1H == 1'b0) ?
                                scrollval_addr :
                                i_CPU_ADDR;

//make scrollram wr signal
wire            scrollram_wr = (i_VZCS_n | i_CPU_RW | i_CPU_LDS_n | TIME2);

//declare SCROLLRAM
wire    [7:0]   scrollram_dout;
SRAM2k8 SCROLLRAM_LOW
(
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (scrollram_addr             ),
    .i_DIN                      (i_CPU_DIN[7:0]             ),
    .o_DOUT                     (scrollram_dout             ),
    .i_WR_n                     (scrollram_wr               ),
    .i_RD_n                     (1'b0                       )
);

//declare CPU side latch
wire    [7:0]   scrollram_cpulatch_q;
LOGIC373 SCROLLRAM_CPULATCH
(
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_D                        (scrollram_dout             ),
    .o_Q                        (scrollram_readlatch_q      ),
    .i_LE_n                     (TIME1                      )
);



//
//  asic seciton
//

wire    [11:0]  vram_addr;
wire    [2:0]   line_addr;

//declare K005291 core: requires clock
K005291 K005291_main
(
    .i_EMU_MCLK                 (i_EMU_MCLK                 ),
    .i_EMU_CLK6MPCEN_n          (o_EMU_CLK6MPCEN_n          ),

    .i_HFLIP                    (                           ),
    .i_VFLIP                    (                           ),

    .i_ABS_n256H                (ABS_n256H                  ),
    .i_ABS_128HA                (ABS_128HA                  ),
    .i_ABS_64H                  (ABS_64H                    ),
    .i_ABS_32H                  (ABS_32H                    ),
    .i_ABS_16H                  (ABS_16H                    ),
    .i_ABS_8H                   (ABS_8H                     ),
    .i_ABS_4H                   (ABS_4H                     ),
    .i_ABS_2H                   (ABS_2H                     ),
    .i_ABS_1H                   (ABS_1H                     ),

    .i_ABS_128V                 (ABS_128V                   ),
    .i_ABS_64V                  (ABS_64V                    ),
    .i_ABS_32V                  (ABS_32V                    ),
    .i_ABS_16V                  (ABS_16V                    ),
    .i_ABS_8V                   (ABS_8V                     ),
    .i_ABS_4V                   (ABS_4V                     ),
    .i_ABS_2V                   (ABS_2V                     ),
    .i_ABS_1V                   (ABS_1V                     ),
    
    .i_VCLK                     (                           ),

    .i_CPUADDR                  (                           ),
    .i_GFXDATA                  (                           ),

    .o_TILELINEADDR             (line_addr                  ),

    .o_VRAMADDR                 (vram_addr                  ),

    .o_SHIFTA1                  (                           ),
    .o_SHIFTA2                  (                           ),
    .o_SHIFTB                   (                           )
);



//
//  VRAM1+2 section
//

/*
    MCLK                           
                        0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
    PIXEL   ----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|----(4)----|----(5)----|----(6)----|----(7)----|
    /DTACK  ¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                                   >SRAM CPU DIN           >SRAM GFX DOUT          >SRAM CPU DOUT          >SRAM GFX DOUT    SRAM async access speed 100ns (TC5533-P on every PCB)
    VRTIME  ¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     6264 CE2 is always 1 in cpu access cycle
    DEVICE             |---------(CPU)---------|---------(GFX)---------|---------(CPU)---------|---------(GFX)---------|
                                   |(RD VALID)-|                                   |(RD VALID)-|                             ext. gates allow RD during pixel 0 and 1 cycles
                             |WRVAL|                                         |WRVAL|                                         ext. gates allow WR during pixel 0 cycle
                       |                 VRAM ADDR TM-A                |                 VRAM ADDR TM-B                |

                                                                       >VRAM ADDR TM-A latched by LS273 at /2H
                                                                                                                       >CHARRAM TM-A line data latched
*/

//make vram wr signal
wire            vram1h_wr = (i_VCS1_n | i_CPU_RW | i_CPU_UDS_n | ABS_1H | ABS_2H); //pixel 0 and 4
wire            vram1l_wr = (i_VCS1_n | i_CPU_RW | i_CPU_LDS_n | ABS_1H | ABS_2H);
wire            vram2l_wr = (i_VCS2_n | i_CPU_RW | i_CPU_LDS_n | ABS_1H | ABS_2H);

//declare vram1
wire    [15:0]  vram1_dout;
SRAM4k8 VRAM1_HIGH
(
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (vram_addr                  ),
    .i_DIN                      (i_CPU_DIN[15:8]            ),
    .o_DOUT                     (vram1_dout[15:8]           ),
    .i_WR_n                     (vram1h_wr                  ),
    .i_RD_n                     (VRTIME                     )
);

SRAM4k8 VRAM1_LOW
(
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (vram_addr                  ),
    .i_DIN                      (i_CPU_DIN[7:0]             ),
    .o_DOUT                     (vram1_dout[7:0]            ),
    .i_WR_n                     (vram1l_wr                  ),
    .i_RD_n                     (VRTIME                     )
);

//declare vram2
wire    [7:0]   vram2_dout;
SRAM4k8 VRAM2_LOW
(
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (vram_addr                  ),
    .i_DIN                      (i_CPU_DIN[7:0]             ),
    .o_DOUT                     (vram2_dout                 ),
    .i_WR_n                     (vram2l_wr                  ),
    .i_RD_n                     (VRTIME                     )
);








///////////////////////////////////////////////////////////
//////  CHARRAM
////

/*
    MCLK                                    1 1
                        0 1 2 3 4 5 6 7 8 9 0 1 
    CLK18M  _|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
    PIXEL   ----(3)----|----(4)----|----(5)----|----(6)----|----(7)----|----(0)----|----(1)----|----(2)----|----(3)----|
    /DTACK  ¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯S0¯¯S1¯¯S2¯¯S3¯¯S4¯|_w___w__S5__S6|¯S7¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                               >row >column            >row >column
    CHAMPX1 ¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    /RAS    ___________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|________________     15ns(LS14) delayed
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

//
//  VRAM1 tile code DFF
//

reg     [10:0]  tile_code;
reg             VVFF;
always @(posedge i_EMU_MCLK)
begin
    if(!o_EMU_CLK6MPCEN_n)
    begin
        if({ABS_4H, ABS_2H, ABS_1H} == 3'd3 || {ABS_4H, ABS_2H, ABS_1H} == 3'd7) //posedge of /2H
        begin
            tile_code <= vram1_dout[10:0];
            VVFF <= vram1_dout[11];
        end
    end
end

//
//  tile address
//

wire    [8:0]   VCA;
assign  VCA =   (CHAMPX == 1'b0) ?
                    {   //CAS
                        1'b1,
                        tile_code[10],
                        tile_code[9],
                        tile_code[8],
                        tile_code[7],
                        tile_code[6],
                        tile_code[5],
                        1'b1
                    } :
                    {   //RAS
                        tile_code[4], 
                        tile_code[3],
                        tile_code[2],
                        tile_code[1],
                        tile_code[0],
                        line_addr[2] ^ VVFF,
                        line_addr[1] ^ VVFF,
                        line_addr[0] ^ VVFF
                    };


wire    [8:0]   gfx_addr;
assign  gfx_addr =  () ? VCA : OCA;

wire    [8:0]   cpu_addr;
assign  cpu_addr =  (CHAMPX == 1'b0) ?
                        {   //CAS
                            1'b1,          //HIGH
                            i_CPUADDR[14], //A15
                            i_CPUADDR[13], //A14
                            i_CPUADDR[12], //A13
                            i_CPUADDR[11], //A12
                            i_CPUADDR[10], //A11
                            i_CPUADDR[9],  //A10
                            1'b1           //HIGH
                        } :
                        {   //RAS
                            i_CPUADDR[8], //A9
                            i_CPUADDR[7], //A8
                            i_CPUADDR[6], //A7
                            i_CPUADDR[5], //A6
                            i_CPUADDR[4], //A5
                            i_CPUADDR[3], //A4
                            i_CPUADDR[2], //A3
                            i_CPUADDR[1]  //A2
                        };








endmodule