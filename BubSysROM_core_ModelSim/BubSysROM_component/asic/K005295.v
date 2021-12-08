/*
    K005295 SPRITE ENGINE
*/

module K005295
#(
    parameter               __ENABLE_DOUBLE_HEIGHT_MODE = 1'b0,
    parameter               __SAVE_FRAMEBUFFER_CAPACITY = 1'b1
)
(
    //emulator
    input   wire            i_EMU_MCLK,
    input   wire            i_EMU_CLK6MPCEN_n,

    //timings
    input   wire            i_DMA_n,
    input   wire            i_VBLANKH_n,
    input   wire            i_VBLANK_n,
    input   wire            i_HBLANK_n,
    input   wire            i_ABS_4H,
    input   wire            i_ABS_2H,
    input   wire            i_ABS_1H,
    input   wire            i_CHAMPX,
    input   wire            i_OBJWR,

    //flip
    input   wire            i_FLIP,

    //clocked shift
    input   wire    [7:0]   i_OBJDATA,
    output  wire    [2:0]   o_ORA,

    //framebuffer CAS
    output  wire            o_CAS,

    //framebuffer
    output  wire    [7:0]   o_FA, //ODD BUFFER
    output  wire    [7:0]   o_FB, //EVEN BUFFER

    output  reg             o_XA7,
    output  reg             o_XB7,

    //peripheral control signals
    input   wire            i_OBJHL,
    output  reg             o_CHAOV,
    output  wire            o_ORINC,

    //005294 control signals
    output  reg             o_WRTIME2,
    output  wire            o_COLORLATCH_n,
    output  wire            o_XPOS_D0,
    output  reg             o_PIXELLATCH_WAIT_n,
    output  wire            o_LATCH_A_D2,
    output  wire    [2:0]   o_PIXELSEL,

    //CHARRAM address
    output  wire    [7:0]   o_OCA
);



///////////////////////////////////////////////////////////
//////  GLOBAL SIGNALS
////

reg             hsize_parity = 1'b0;
reg             pixellatch_wait_n;




/*
    PIXEL3_n generator

PIXEL3_n은 매우 중요합니다. 3픽셀에 한번씩 0이 되며, CHARRAM에서 복사한
스프라이트 라인을 005294가 PIXEL3_n의 상승 엣지에 래치하기 때문입니다.
*/

wire            PIXEL3_n = ~(i_ABS_1H & i_ABS_2H);


/*
    DMA_n register

DMA_n을 4H의 상승엣지에서 항상 샘플링하여 FSM이 새로운 VBLANK의 시작을
알 수 있게 합니다. 만약 샘플링된 DMA_n이 0이고 VBLANK또는 VBLANKH가 0인
경우, 이것이 새로운 VBLANK의 시작입니다.

Sampling DMA_n at every rising edge of 4H allows FSM to know 
the start of a new VBLANK. If the value of sampled DMA_n is 1
and VBLANK or VBLANKH is 0, it is the beginning of a new VBLANK.
*/

reg             DMA_4H_CLKD_n = 1'b1;
wire            new_vblank_n = DMA_4H_CLKD_n | i_VBLANKH_n;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if({i_ABS_4H, i_ABS_2H, i_ABS_1H} == 3'd3)
        begin
            DMA_4H_CLKD_n <= i_DMA_n;
        end
    end
end




/*
    ORA/register enable generation
*/

//latch enable signal
wire            LATCH_A_en_n; //OBJRAM BYTE 2: zoom MSBs[7:6], size[5:3], unknown size bits[2:1], hflip[0]
wire            LATCH_B_en_n; //OBJRAM BYTE 4: zoom LSBs[7:0]
wire            LATCH_C_en_n; //OBJRAM BYTE 6: sprite code LSBs[7:0]
wire            LATCH_D_en_n; //OBJRAM BYTE 8: sprite code MSBs[7:6], vflip[5], obj palette[4:1], xpos MSB[0]
wire            LATCH_E_en_n; //OBJRAM BYTE A: xpos LSBs[7:0]
wire            LATCH_F_en_n; //OBJRAM BYTE C: ypos[7:0]

assign  o_COLORLATCH_n = LATCH_D_en_n;

//if /A ORA = 2, if /B ORA = 3, ... ,if /F, ORA = 7
//MUDA MUDA MUDA MUDA MUDA MUDA
//ORA ORA ORA ORA ORA ORA ORA
assign  o_ORA[2] = ~&{                                LATCH_C_en_n,   LATCH_D_en_n,   LATCH_E_en_n,   LATCH_F_en_n};
assign  o_ORA[1] = ~&{LATCH_A_en_n,   LATCH_B_en_n,                                   LATCH_E_en_n,   LATCH_F_en_n};
assign  o_ORA[0] = ~&{                LATCH_B_en_n,                   LATCH_D_en_n,                   LATCH_F_en_n};

//latch enable shift register
reg             latching_start;
reg     [6:0]   attr_latch_en_sr;
assign  {LATCH_A_en_n, LATCH_B_en_n, LATCH_C_en_n,
         LATCH_D_en_n, LATCH_E_en_n, LATCH_F_en_n, o_ORINC} = attr_latch_en_sr;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(i_ABS_1H == 1'b0)
        begin
            attr_latch_en_sr[6]   <= ~latching_start;
            attr_latch_en_sr[5:0] <= attr_latch_en_sr[6:1];
        end
    end
end



/*
    Sprite attribute latches
*/

//LATCH_F is not shown here since ypos data is directly loaded into ypos counter
reg     [7:0]   LATCH_A; //OBJRAM BYTE 2: zoom MSBs[7:6], size[5:3], unknown size bits[2:1], hflip[0]
reg     [7:0]   LATCH_B; //OBJRAM BYTE 4: zoom LSBs[7:0]
reg     [7:0]   LATCH_C; //OBJRAM BYTE 6: sprite code LSBs[7:0]
reg     [7:0]   LATCH_D; //OBJRAM BYTE 8: sprite code MSBs[7:6], vflip[5], obj palette[4:1], xpos MSB[0]
reg     [7:0]   LATCH_E; //OBJRAM BYTE A: xpos LSBs[7:0]

assign  o_XPOS_D0 = LATCH_E[0];
assign  o_LATCH_A_D2 = LATCH_A[2];

//LATCH_A
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(!LATCH_A_en_n)
        begin
            LATCH_A <= i_OBJDATA & {6'b1111_11, __ENABLE_DOUBLE_HEIGHT_MODE, 1'b1};
        end

        if(!LATCH_B_en_n)
        begin
            LATCH_B <= i_OBJDATA;
        end

        if(!LATCH_C_en_n)
        begin
            LATCH_C <= i_OBJDATA;
        end

        if(!LATCH_D_en_n)
        begin
            LATCH_D <= i_OBJDATA;
        end

        if(!LATCH_E_en_n)
        begin
            LATCH_E <= i_OBJDATA;
        end
    end
end



///////////////////////////////////////////////////////////
//////  HZOOM FEEDBACK COUNTER
////

reg             hzoom_cnt_n;
reg             hzoom_rst_n;
reg     [9:0]   hzoom_acc = 10'd0;
wire    [10:0]  hzoom_nextval = hzoom_acc + {LATCH_A[7:6], LATCH_B};
reg     [2:0]   hzoom_tileline_cntr;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(!hzoom_rst_n)
        begin
            hzoom_acc <= 10'd0;
            hzoom_tileline_cntr <= 3'd0;
        end
        else
        begin
            if(!hzoom_cnt_n)
            begin
                hzoom_acc <= hzoom_nextval[9:0];
                if(hzoom_nextval[10] == 1'b1)
                begin
                    hzoom_tileline_cntr <= hzoom_tileline_cntr + 3'd1;
                end
            end
        end
    end
end



///////////////////////////////////////////////////////////
//////  TILELINE/HLINE COMPLETE FLAG
////

/*
    "tileline complete" 플래그는 피드백 어큐뮬레이터와 같은 신호로 스프라
    이트의 타일라인(8픽셀 한 줄) 하나 그리기가 끝났음을 알립니다.

    "hline complete" 플래그는 타일라인 카운터와 캐리가 AND되어, 피드백
    어큐뮬레이터의 다음 값에서 캐리가 발생하는 경우 발생합니다. 즉, 스프라
    이트의 한 라인 그리기가 끝났음을 알립니다.
*/

reg             hline_complete;
wire            tileline0_complete = hzoom_nextval[10];
wire            tileline1_complete = &{hzoom_nextval[10], hzoom_tileline_cntr[0]};
wire            tileline3_complete = &{hzoom_nextval[10], hzoom_tileline_cntr[0], hzoom_tileline_cntr[1]};
wire            tileline7_complete = &{hzoom_nextval[10], hzoom_tileline_cntr[0], hzoom_tileline_cntr[1], hzoom_tileline_cntr[2]};

always @(*)
begin
    case({LATCH_A[5:3]})
        4'h0: hline_complete <= tileline3_complete; //32*32     4 horizontal tileline
        4'h1: hline_complete <= tileline1_complete; //16*32     2 horizontal tileline
        4'h2: hline_complete <= tileline3_complete; //32*16     4 horizontal tileline
        4'h3: hline_complete <= tileline7_complete; //64*64     8 horizontal tileline
        4'h4: hline_complete <= tileline0_complete; //8*8       1 horizontal tileline
        4'h5: hline_complete <= tileline1_complete; //16*8      2 horizontal tileline
        4'h6: hline_complete <= tileline0_complete; //8*16      1 horizontal tileline
        4'h7: hline_complete <= tileline1_complete; //16*16     2 horizontal tileline
    endcase
end





///////////////////////////////////////////////////////////
//////  VZOOM FEEDBACK COUNTER
////

reg             vzoom_cnt_n;
reg             vzoom_rst_n;
reg     [9:0]   vzoom_acc = 10'd0;
wire    [10:0]  vzoom_nextval = vzoom_acc + {LATCH_A[7:6], LATCH_B};
reg     [3:0]   vzoom_vtile_cntr;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(!vzoom_rst_n)
        begin
            vzoom_acc <= 10'd0;
            vzoom_vtile_cntr <= 4'd0;
        end
        else
        begin
            if(!vzoom_cnt_n)
            begin
                vzoom_acc <= vzoom_nextval[9:0];
                if(vzoom_nextval[10] == 1'b1)
                begin
                    vzoom_vtile_cntr <= vzoom_vtile_cntr + 4'd1;
                end
            end
        end
    end
end





///////////////////////////////////////////////////////////
//////  DRAWING COMPLETE FLAG
////

/*
    "vtile_complete" 플래그는 현재 스프라이트 라인이 마지막이라 더 이상
    그릴 필요가 없다는 의미를 나타냅니다. 피드백 래치에 현재 라인 숫자가
    출력되지만, 현재 라인 숫자와 zoom factor를 더한 값이 덧셈기에서 다시
    출력되고 있으므로 캐리가 1이면 다음 라인을 그리지 않아야 한다는 것을
    미리 알 수 있습니다.
*/

reg             vtile_complete_n;
wire            vtile0_complete_n  = ~vzoom_nextval[10];
wire            vtile1_complete_n  = ~&{vzoom_nextval[10], vzoom_vtile_cntr[0]};
wire            vtile3_complete_n  = ~&{vzoom_nextval[10], vzoom_vtile_cntr[0], vzoom_vtile_cntr[1]};
wire            vtile7_complete_n  = ~&{vzoom_nextval[10], vzoom_vtile_cntr[0], vzoom_vtile_cntr[1], vzoom_vtile_cntr[2]};
wire            vtile15_complete_n = ~&{vzoom_nextval[10], vzoom_vtile_cntr[0], vzoom_vtile_cntr[1], vzoom_vtile_cntr[2], vzoom_vtile_cntr[3]};

always @(*)
begin
    case({LATCH_A[1], LATCH_A[5:3]})
        4'h0: vtile_complete_n <= vtile3_complete_n; //32*32    4 vetrical tiles
        4'h1: vtile_complete_n <= vtile3_complete_n; //16*32    4 vetrical tiles
        4'h2: vtile_complete_n <= vtile1_complete_n; //32*16    2 vetrical tiles
        4'h3: vtile_complete_n <= vtile7_complete_n; //64*64    8 vetrical tiles
        4'h4: vtile_complete_n <= vtile0_complete_n; //8*8      1 vetrical tiles
        4'h5: vtile_complete_n <= vtile0_complete_n; //16*8     1 vetrical tiles
        4'h6: vtile_complete_n <= vtile1_complete_n; //8*16     2 vetrical tiles
        4'h7: vtile_complete_n <= vtile1_complete_n; //16*16    2 vetrical tiles
        4'h8: vtile_complete_n <= vtile7_complete_n; //32*64    8 vetrical tiles
        4'h9: vtile_complete_n <= vtile7_complete_n; //16*64    8 vetrical tiles
        4'hA: vtile_complete_n <= vtile3_complete_n; //32*32    4 vetrical tiles
        4'hB: vtile_complete_n <= vtile15_complete_n; //64*128  16 vetrical tiles
        4'hC: vtile_complete_n <= vtile1_complete_n; //8*16     2 vetrical tiles
        4'hD: vtile_complete_n <= vtile1_complete_n; //16*32    2 vetrical tiles
        4'hE: vtile_complete_n <= vtile3_complete_n; //8*32     4 vetrical tiles
        4'hF: vtile_complete_n <= vtile3_complete_n; //16*32    4 vetrical tiles
    endcase
end



///////////////////////////////////////////////////////////
//////  FRAMEBUFFER XYPOS COUNTER
////

//countup signal delay registers
reg     [1:0]   xpos_cnt_dly_n;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        xpos_cnt_dly_n[0] <= ~o_WRTIME2;
        xpos_cnt_dly_n[1] <= xpos_cnt_dly_n[0];
    end
end

reg             ypos_cnt_n;
reg     [3:0]   ypos_cnt_dly_n;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        ypos_cnt_dly_n[0] <= ypos_cnt_n;
        ypos_cnt_dly_n[3:1] <= ypos_cnt_dly_n[2:0];
    end
end


//xpos counter
reg     [7:0]   evenbuffer_xpos_counter;
reg     [7:0]   oddbuffer_xpos_counter;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(LATCH_F_en_n == 1'b0) //2clk delay AND LATCH_F_en_n -> preload data before sprite drawing
        begin
            evenbuffer_xpos_counter <= {LATCH_D[0], LATCH_E[7:1]} + LATCH_E[0];
            oddbuffer_xpos_counter <= {LATCH_D[0], LATCH_E[7:1]};
        end
        else if(ypos_cnt_dly_n[3] == 1'b0)
        begin
            evenbuffer_xpos_counter <= {LATCH_D[0], LATCH_E[7:1]} + LATCH_E[0];
            oddbuffer_xpos_counter <= {LATCH_D[0], LATCH_E[7:1]};
        end
        else
        begin
            if(xpos_cnt_dly_n[1] == 1'b0)
            begin
                evenbuffer_xpos_counter <= evenbuffer_xpos_counter + 8'd1;
                oddbuffer_xpos_counter <= oddbuffer_xpos_counter + 8'd1;
            end
        end
    end
end


//ypos counter
reg     [7:0]   buffer_ypos_counter;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(LATCH_F_en_n == 1'b0)
        begin
            buffer_ypos_counter <= i_OBJDATA;
        end
        else
        begin
            if(ypos_cnt_dly_n[3] == 1'b0)
            begin
                buffer_ypos_counter <= buffer_ypos_counter + 8'd1;
            end
        end
    end
end



///////////////////////////////////////////////////////////
//////  DRAWING STATUS FLAGS
////

wire            x_out_of_screen = ~(~oddbuffer_xpos_counter[7] | oddbuffer_xpos_counter[6]); //0-255 or 384-511
wire            y_out_of_screen = (buffer_ypos_counter == 8'd255) ? 1'b1 : 1'b0;

wire            end_of_tileline = tileline0_complete | x_out_of_screen;
wire            end_of_hline = hline_complete | x_out_of_screen;
//wire            end_of_last_hline_n = ~(~(vtile_complete_n | vzoom_cnt_n) | y_out_of_screen);
wire            end_of_last_hline_n = ~(~(vtile_complete_n) | y_out_of_screen);







///////////////////////////////////////////////////////////
//////  SPRITE ENGINE MegaPAL
////

// DIRECT REPLACEMENT OF MegaPAL IMPLEMENTATION

/*
    [Comb] STATUS FLAGS
*/

wire    [2:0]   drawing_status = {end_of_last_hline_n, end_of_hline, end_of_tileline};

localparam KEEP_DRAWING     = 3'b100;
localparam END_OF_TILELINE  = 2'b01; //3'bX01 will not work
localparam END_OF_HLINE     = 3'b111;
localparam END_OF_SPRITE    = 3'b011;



/*
    [4H CLK] FSM SUSPEND AND RESUME
*/

reg     [1:0]   FSM_SUSPEND_DLY;
wire            FSM_SUSPEND = ((i_HBLANK_n & i_VBLANKH_n) | FSM_SUSPEND_DLY[1]) | ~DMA_4H_CLKD_n;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if({i_ABS_4H, i_ABS_2H, i_ABS_1H} == 3'd3)
        begin
            FSM_SUSPEND_DLY[0] <= (i_HBLANK_n & i_VBLANKH_n);
            FSM_SUSPEND_DLY[1] <= FSM_SUSPEND_DLY[0];
        end
    end
end



/*
    [6M CLK] CHA O/V
*/

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(PIXEL3_n == 1'b0)
        begin
            o_CHAOV <= FSM_SUSPEND;
        end
    end
end



/*
    [4H CLK] FOR ATTRIBUTE FETCHING END DETECTION
*/

reg             LATCH_F_2H_NCLKD_en_n = 1'b1;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(PIXEL3_n == 1'b0)
        begin
            LATCH_F_2H_NCLKD_en_n <= LATCH_F_en_n;
        end
    end
end



/*
    [6M CLK] HSIZE PARITY
*/

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(hzoom_rst_n == 1'b0) //preload, new hline
        begin
            hsize_parity <= 1'b1;
        end
        else
        begin
            if(hzoom_cnt_n == 1'b0)
            begin
                hsize_parity <= ~hsize_parity;
            end
        end
    end
end



/*
    [6M CLK] FINITE STATE MACHINE
*/

/*
    ATTR_LATCHING_S0:
        1픽셀동안 latching_start을 1로 올립니다. 이후 1H 클럭의 시프트 
        레지스터가 0을 시프트하며 차례대로 스프라이트 속성을 차례로 래치합니다.
    ATTR_LATCHING_S1:
        14픽셀동안 1H 클럭의 시프트 레지스터가 스프라이트 속성을 래치하는동안
        FSM은 아무것도 하지 않습니다. 4H의 상승 엣지에서 샘플링된 LATCH_F_2H_NCLKD_en_n
        과 PIXEL3_n의 OR이 0인 경우 HCOUNT_S0으로 점프합니다.

    HCOUNT_S0:
        임의의 HCOUNT_S0동안 hcounter_en_n을 0으로 내려 동작시킵니다. 이 신호는
        카운터의 캐리와 OR되어있어 캐리가 1로 출력되는 엣지 다음 엣지부터는 카운터가
        증가하지 않습니다.
    HWAIT_S0:
        현재 타일라인의 데이터는 2H의 상승 엣지(PIXEL3_n = 0)에서 항상 래치되므로,
        그 전에 타일라인 그리기가 끝났을 경우 다음 데이터를 기다리기 위해 HWAIT사이클
        을 삽입합니다. 상승 엣지가 감지되면 HCOUNT로 복귀하거나 FSM_SUSPEND의 상태에 따라
        SUSPENSION_S0으로 갑니다.

    ODDSIZE_S0:
        확대축소된 스프라이트의 가로 픽셀 수가 홀수이고 해당 스프라이트 라인 그리기
        를 마쳐야 할 때 발생합니다. 홀짝 판단은 내부의 1비트 레지스터 값으로 수행하며, 
        2H의 상승 엣지에서 이전 상태가 HCOUNT나 HWAIT이였고, END_OF_HLINE플래그가
        활성화되었고, 가로 픽셀 수가 홀수일때 이 상태로 옵니다. 이 상태가 존재하는
        이유는 다음과 같습니다:
        1. 스프라이트의 쓰기는 2픽셀씩 이루어지며, 짝수픽셀을 래치시킨 후에 홀수픽셀을
           띄워둔 상태에서 프레임버퍼에 쓰는 방식입니다.
        2. 짝수픽셀만 가져온 상태로 타일라인이 끝나면, 아직 프레임 버퍼에 기록하지 않았
           기 때문에 WRTIME은 0인 상태이고, 피드백 카운터의 캐리가 1이 되어 005294 내부
           에서 짝수픽셀의 래치를 보류하고 있는 상태입니다.
        3. 이 상태는 2H의 상승 엣지가 들어올 동안 지속됩니다. ODDSIZE_S0은 이 래치되지
           않은 짝수 픽셀을 래치시키고 프레임 버퍼에 짝수 픽셀 데이터와 홀수 픽셀에는 0
           을 기록할 시간을 제공합니다

    SUSPEND_S0:
        FSM_SUSPEND = (i_HBLANK_n & i_VBLANKH_n) | ~i_DMA_n 이 0이 되었을 때 발생합니다. 
        ATTR_LATCHING_S1일때는 이 상태로 가지 않습니다. 이외의 상태에서는 2H의 상승
        엣지마다 FSM_SUSPEND을 확인하여 이 신호가 1일 경우에는 무조건 작업을 중단하고 이
        상태로 갑니다. WRTIME이나 다른 신호들은 외부 플립플롭에 의해 딜레이되기 때문에
        FSM이 이 상태로 가도 잠시동안은 다른 신호들이 유지됩니다.

*/

//Declare states
localparam ATTR_LATCHING_S0 = 3'd1;
localparam ATTR_LATCHING_S1 = 3'd2;
localparam HCOUNT_S0 = 3'd3;
localparam HWAIT_S0 = 3'd4;
localparam ODDSIZE_S0 = 3'd5;
localparam SUSPEND_S0 = 3'd0;

//Declare state register
reg     [2:0]   sprite_engine_state = SUSPEND_S0; //3'd0 = reset state, Quartus always reset FSM as 0

//Determine the next state synchronously, based on the current state and the input
always @ (posedge i_EMU_MCLK) 
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        case(sprite_engine_state)
            // ATTRIBUTE LATCHING START
            ATTR_LATCHING_S0:
                sprite_engine_state <= ATTR_LATCHING_S1;
            
            // WAIT FOR LATCHING COMPLETION
            ATTR_LATCHING_S1:
                if(PIXEL3_n == 1'b0) //exit condition: 1 pixel just after end of ORINC(negative logic)
                begin
                    if(LATCH_F_2H_NCLKD_en_n == 1'b0)
                    begin
                        if(FSM_SUSPEND == 1'b0) //keep going
                        begin
                            sprite_engine_state <= HCOUNT_S0;
                        end
                        else //if not, go suspend_s0
                        begin
                            sprite_engine_state <= SUSPEND_S0;
                        end
                    end
                    else
                    begin
                        sprite_engine_state <= ATTR_LATCHING_S1;
                    end
                end
                else
                begin
                    sprite_engine_state <= ATTR_LATCHING_S1;
                end

            // DRAWING
            // IMPORTANCE LEVEL:  END_OF_SPRITE > END_OF_HLINE > END_OF_TILELINE > KEEP_DRAWING
            HCOUNT_S0:
                if(drawing_status == END_OF_SPRITE)
                begin
                    if(PIXEL3_n == 1'b0) //at pixel 3
                    begin
                        if(FSM_SUSPEND == 1'b0) //keep going
                        begin
                            sprite_engine_state <= ATTR_LATCHING_S0;
                        end
                        else //if not, go suspend_s0
                        begin
                            sprite_engine_state <= SUSPEND_S0;
                        end
                    end
                    else //at pixel 0, 1, 2
                    begin
                        sprite_engine_state <= HWAIT_S0;
                    end
                end
                else if(drawing_status == END_OF_HLINE)
                begin
                    if(PIXEL3_n == 1'b0) //at pixel 3
                    begin
                        if(FSM_SUSPEND == 1'b0) //keep going
                        begin
                            if(hsize_parity == 1'b0) //zoomed horizontal size is even
                            begin
                                sprite_engine_state <= HCOUNT_S0;
                            end
                            else //zoomed horizontal size is odd
                            begin
                                sprite_engine_state <= ODDSIZE_S0;
                            end
                        end
                        else //if not, go SUSPEND_S0
                        begin
                            sprite_engine_state <= SUSPEND_S0;
                        end
                    end
                    else //at pixel 0, 1, 2
                    begin
                        sprite_engine_state <= HWAIT_S0;
                    end
                end
                else if(drawing_status[1:0] == END_OF_TILELINE)
                begin
                    if(PIXEL3_n == 1'b0) //at pixel 3
                    begin
                        if(FSM_SUSPEND == 1'b0) //keep going
                        begin
                            sprite_engine_state <= HCOUNT_S0;
                        end
                        else //if not, go suspend_s0
                        begin
                            sprite_engine_state <= SUSPEND_S0;
                        end
                    end
                    else //at pixel 0, 1, 2
                    begin
                        sprite_engine_state <= HWAIT_S0;
                    end
                end
                else // `KEEP_DRAWING
                begin
                    if(PIXEL3_n == 1'b0) //at pixel 3
                    begin
                        if(FSM_SUSPEND == 1'b0) //keep going
                        begin
                            sprite_engine_state <= HCOUNT_S0;
                        end
                        else //if not, go SUSPEND_S0
                        begin
                            sprite_engine_state <= SUSPEND_S0;
                        end
                    end
                    else //at pixel 0, 1, 2
                    begin
                        sprite_engine_state <= HCOUNT_S0;
                    end
                end



            // WAIT STATE: WAITING FOR /PX3
            HWAIT_S0:
                if(PIXEL3_n == 1'b0) //exit condition: encounter px3
                begin
                    if(FSM_SUSPEND == 1'b0) //keep going, return to HCOUNT_S0 or fetch new attributes
                    begin
                        if(drawing_status == END_OF_SPRITE)
                        begin
                            if(hsize_parity == 1'b0) //zoomed horizontal size is even
                            begin
                                sprite_engine_state <= ATTR_LATCHING_S0;
                            end
                            else //zoomed horizontal size is odd
                            begin
                                sprite_engine_state <= ODDSIZE_S0;
                            end
                        end
                        else if(drawing_status == END_OF_HLINE)
                        begin
                            if(hsize_parity == 1'b0) //zoomed horizontal size is even
                            begin
                                sprite_engine_state <= HCOUNT_S0;
                            end
                            else //zoomed horizontal size is odd
                            begin
                                sprite_engine_state <= ODDSIZE_S0;
                            end
                        end
                        else
                        begin
                            sprite_engine_state <= HCOUNT_S0;
                        end
                    end
                    else //if not, go suspend_s0
                    begin
                        sprite_engine_state <= SUSPEND_S0;
                    end
                end
                else
                begin
                    sprite_engine_state <= HWAIT_S0;
                end
            
            
            // WAIT FOR WRITE ONLY A SINGLE PIXEL
            ODDSIZE_S0:
                if(PIXEL3_n == 1'b0) //exit condition: encounter px3
                begin
                    if(FSM_SUSPEND == 1'b0) //keep going, return to HCOUNT_S0 or fetch new attributes
                    begin
                        if(drawing_status == END_OF_SPRITE)
                        begin
                            sprite_engine_state <= ATTR_LATCHING_S0;
                        end
                        else
                        begin
                            sprite_engine_state <= HCOUNT_S0;
                        end
                    end
                    else //if not, go suspend_s0
                    begin
                        sprite_engine_state <= SUSPEND_S0;
                    end
                end
                else
                begin
                    sprite_engine_state <= ODDSIZE_S0;
                end


            // SUSPEND STATE: WAITING FOR /PX3
            SUSPEND_S0: begin
                if(PIXEL3_n == 1'b0) //exit condition: encounter px3
                begin
                    if(new_vblank_n == 1'b0)
                    begin
                        sprite_engine_state <= ATTR_LATCHING_S0; //new vblank
                    end
                    else if(FSM_SUSPEND == 1'b0) //return to HCOUNT_S0  or fetch new attributes
                    begin
                        if(drawing_status == END_OF_SPRITE)
                        begin
                            sprite_engine_state <= ATTR_LATCHING_S0;
                        end
                        else if(drawing_status == END_OF_HLINE)
                        begin
                            if(hsize_parity == 1'b0) //zoomed horizontal size is even
                            begin
                                sprite_engine_state <= HCOUNT_S0;
                            end
                            else //zoomed horizontal size is odd
                            begin
                                sprite_engine_state <= ODDSIZE_S0;
                            end
                        end
                        else
                        begin
                            sprite_engine_state <= HCOUNT_S0;
                        end
                    end
                    else
                    begin
                        sprite_engine_state <= SUSPEND_S0;
                    end
                end
            end
        endcase
    end
end

//Determine the output based only on the current state and the input (do not wait for a clock edge)
//signal list:
//  latching_start
//  hzoom_cnt_n
//  hzoom_rst_n
//  vzoom_cnt_n
//  vzoom_rst_n
//  ypos_cnt_n
//  pixellatch_wait_n
always @(*) //Quartus
begin
    case(sprite_engine_state)
        ATTR_LATCHING_S0: begin
            latching_start <= 1'b1;

            hzoom_cnt_n <= 1'b1;
            hzoom_rst_n <= 1'b1;

            vzoom_cnt_n <= 1'b1;
            vzoom_rst_n <= 1'b1;

            ypos_cnt_n <= 1'b1;

            pixellatch_wait_n <= 1'b0;
        end
        ATTR_LATCHING_S1: begin
            if(LATCH_F_2H_NCLKD_en_n == 1'b0 && PIXEL3_n == 1'b0)
            begin
                latching_start <= 1'b0;

                hzoom_cnt_n <= 1'b1;
                hzoom_rst_n <= 1'b0;

                vzoom_cnt_n <= 1'b1;
                vzoom_rst_n <= 1'b0;

                ypos_cnt_n <= 1'b1;

                pixellatch_wait_n <= 1'b0;
            end
            else
            begin
                latching_start <= 1'b0;

                hzoom_cnt_n <= 1'b1;
                hzoom_rst_n <= 1'b1;

                vzoom_cnt_n <= 1'b1;
                vzoom_rst_n <= 1'b1;

                ypos_cnt_n <= 1'b1;

                pixellatch_wait_n <= 1'b0;
            end    
        end

        HCOUNT_S0: begin
        /*
            HCOUNT_S0
            대기 상태: 다음 PIXEL3_n까지 기다립니다.

            1. END_OF_SPRITE가 PIXEL3_n전에 감지되었을 경우 pixellatch_wait_n
            은 0이 되고, hv피드백 카운터를 정지해야 합니다. HWAIT_S0에서 hv피드백
            카운터를 조작하기 때문입니다. PIXEL3_n에 감지되었을 경우는 
            pixellatch_wait_n가 1이고, hv피드백 카운터를 조작해야 합니다.
            2. END_OF_SPRITE가 PIXEL3_n전에 감지되었을 경우 pixellatch_wait_n
            은 0이 되고, hv피드백 카운터를 정지해야 합니다. HWAIT_S0에서 hv피드백
            카운터를 조작하기 때문입니다. PIXEL3_n에 감지되었을 경우는 
            pixellatch_wait_n가 1이고, hv피드백 카운터를 조작해야 합니다.
            3. END_OF_SPRITE가 PIXEL3_n전에 감지되었을 경우 pixellatch_wait_n
            은 0이 되고, hv피드백 카운터를 정지해야 합니다. HWAIT_S0에서 hv피드백
            카운터를 조작하기 때문입니다. PIXEL3_n에 감지되었을 경우는 
            pixellatch_wait_n가 1이고, hv피드백 카운터를 조작해야 합니다.
            4. KEEP_DRAWING에는 pixellatch_wait_n은 1이 되고, hv피드백 카운터를
            계속 증가시켜야 합니다.
        */

            latching_start <= 1'b0;

            if(drawing_status == END_OF_SPRITE)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
            end
            else if(drawing_status == END_OF_HLINE)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b0;

                    vzoom_cnt_n <= 1'b0;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b0;

                    pixellatch_wait_n <= 1'b1;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end     
            end
            else if(drawing_status[1:0] == END_OF_TILELINE)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0 | ~hsize_parity;
                end
            end
            else //`KEEP_DRAWING
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
            end
        end

    
        HWAIT_S0: begin
        /*
            HWAIT_S0
            대기 상태: 다음 PIXEL3_n까지 기다립니다.

            1. END_OF_SPRITE인 경우 hsize_parity에 따라 출력이 달라집니다. 
            짝수개를 그린 후라면 스프라이트를 그만 그려도 되지만, 홀수개를
            그린 후라면 ODDSIZE_S0을 삽입해야 하기 때문에 hv피드백 카운터를 
            조작해서는 안 됩니다.
            2. END_OF_HLINE인 경우 hsize_parity에 따라 출력이 달라집니다. 
            짝수개를 그린 후라면 바로 다음 tileline을 그려야 하지만, 홀수개를
            그린 후라면 ODDSIZE_S0을 삽입해야 하기 때문에 hv피드백 카운터를 
            조작해서는 안 됩니다.
            3. END_OF_TILELINE인 경우 PIXEL3_n이 오면 카운터를 증가시킵니다
            4. KEEP_DRAWING은 발생할 수 없지만 모든 경우를 기술해야 하므로
            작성합니다.
        */

            latching_start <= 1'b0;

            if(drawing_status == END_OF_SPRITE)
            begin
                if(hsize_parity == 1'b0) //after drawing even pixels
                begin
                    if(PIXEL3_n == 1'b0) //pixel 3
                    begin
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b1;
                    end
                    else
                    begin //before pixel 3
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b0;
                    end
                end
                else //after drawing odd pixels: everything will be changed in ODDSIZE_S0
                begin
                    if(PIXEL3_n == 1'b0) //pixel 3
                    begin
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b1;
                    end
                    else
                    begin //before pixel 3
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b0;
                    end
                end
            end
            else if(drawing_status == END_OF_HLINE)
            begin
                if(hsize_parity == 1'b0) //after drawing even pixels
                begin
                    if(PIXEL3_n == 1'b0) //pixel 3
                    begin
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b0;

                        vzoom_cnt_n <= 1'b0;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b0;

                        pixellatch_wait_n <= 1'b1;
                    end
                    else
                    begin //before pixel 3
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b0;
                    end
                end
                else //after drawing odd pixels: everything will be changed in ODDSIZE_S0
                begin
                    if(PIXEL3_n == 1'b0) //pixel 3
                    begin
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b1;
                    end
                    else
                    begin //before pixel 3
                        hzoom_cnt_n <= 1'b1;
                        hzoom_rst_n <= 1'b1;

                        vzoom_cnt_n <= 1'b1;
                        vzoom_rst_n <= 1'b1;

                        ypos_cnt_n <= 1'b1;

                        pixellatch_wait_n <= 1'b0;
                    end
                end 
            end
            else if(drawing_status[1:0] == END_OF_TILELINE)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
            end
            else //`KEEP_DRAWING: WILL NOT HAPPEN
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b1;
                end
            end
        end

        ODDSIZE_S0: begin
        /*
            ODDSIZE_S0
            지금까지 그린 픽셀 갯수가 홀수인 상황에서 짝수 버퍼에 0을 쓰고 한
            라인 그리기를 마쳐야 하는 경우입니다. 이 상태로 넘어온 경우 hsize_
            parity가 홀수인 것은 확정된 상황입니다.

            1. END_OF_SPRITE인 경우 스프라이트 그리기를 마쳐야 합니다.
            2. END_OF_HLINE인 경우 ypos와 vzoom을 증가시켜야 합니다.
            3. END_OF_TILELINE은 발생할 수 없지만 모든 경우를 기술해야 하므로
            작성합니다.
            4. KEEP_DRAWING은 발생할 수 없지만 모든 경우를 기술해야 하므로
            작성합니다.
        */

            latching_start <= 1'b0;
            
            if(drawing_status == END_OF_SPRITE)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b0;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b0;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
            end
            else if(drawing_status == END_OF_HLINE)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b0;

                    vzoom_cnt_n <= 1'b0;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b0;

                    pixellatch_wait_n <= 1'b0;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end     
            end
            else if(drawing_status[1:0] == END_OF_TILELINE) //WILL NOT HAPPEN
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
            end
            else //`KEEP_DRAWING(WILL NOT HAPPEN)
            begin
                if(PIXEL3_n == 1'b0) //pixel 3
                begin
                    hzoom_cnt_n <= 1'b0;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
                else
                begin //before pixel 3
                    hzoom_cnt_n <= 1'b1;
                    hzoom_rst_n <= 1'b1;

                    vzoom_cnt_n <= 1'b1;
                    vzoom_rst_n <= 1'b1;

                    ypos_cnt_n <= 1'b1;

                    pixellatch_wait_n <= 1'b0;
                end
            end
        end

        SUSPEND_S0: begin
        /*
            SUSPEND_S0
            작업이 재개될 때 까지 기다립니다.
        */
            latching_start <= 1'b0;

            hzoom_cnt_n <= 1'b1;
            hzoom_rst_n <= 1'b1;

            vzoom_cnt_n <= 1'b1;
            vzoom_rst_n <= 1'b1;

            ypos_cnt_n <= 1'b1;

            pixellatch_wait_n <= 1'b0;
        end

        default: begin
            latching_start <= 1'b0;

            hzoom_cnt_n <= 1'b1;
            hzoom_rst_n <= 1'b1;

            vzoom_cnt_n <= 1'b1;
            vzoom_rst_n <= 1'b1;

            ypos_cnt_n <= 1'b1;

            pixellatch_wait_n <= 1'b0;
        end
    endcase
end



/*
    [6M CLK] WRTIME DELAY
*/

reg             wrtime1;
wire            oddsize_wrtime0 = (sprite_engine_state == ODDSIZE_S0 && PIXEL3_n == 1'b0) ? 1'b1 : 1'b0;
wire            evensize_wrtime0 = (sprite_engine_state == HCOUNT_S0) ? ~hsize_parity : 1'b0;
always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        //feed hsize_parity normally, but it should be 1 when PIXEL3 at ODDSIZE_S0
        wrtime1 <= evensize_wrtime0 | oddsize_wrtime0;
        o_WRTIME2 <= wrtime1;
    end
end



/*
    [6M CLK] o_PIXELLATCH_WAIT_n DELAY
*/

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        o_PIXELLATCH_WAIT_n <= pixellatch_wait_n;
    end
end






///////////////////////////////////////////////////////////
//////  PIXEL SELECT(005294), LINE SELECT, TILE SELECT
////

//005294 PIXEL SELECT
assign  o_PIXELSEL = hzoom_acc[9:7] ^ {3{LATCH_A[0]}}; //OBJ_HFLIP

//CHARRAM ADDRESS
wire    [2:0]   TILELINE_ADDR = hzoom_tileline_cntr ^ {3{LATCH_A[0]}};
wire    [2:0]   HLINE_ADDR = vzoom_acc[9:7] ^ {3{LATCH_D[5]}};
wire    [3:0]   VTILE_ADDR = vzoom_vtile_cntr ^ {4{LATCH_D[5]}};
reg     [13:0]  CHARRAM_ADDR; //unmultiplexed
assign  o_OCA = (i_CHAMPX == 1'b0) ? CHARRAM_ADDR[7:0] : {1'b1, CHARRAM_ADDR[13:8], 1'b1}; //RAS : CAS

always @(*)
begin
    case({LATCH_A[1], LATCH_A[5:3]})
        //                     |-------(OBJ CODE)-------| 
        4'h0: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:3], VTILE_ADDR[1:0], HLINE_ADDR[2:0], TILELINE_ADDR[1:0]}; //32*32    4 vetrical tiles
        4'h1: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:2], VTILE_ADDR[1:0], HLINE_ADDR[2:0], TILELINE_ADDR[0:0]}; //16*32    4 vetrical tiles
        4'h2: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:2], VTILE_ADDR[0:0], HLINE_ADDR[2:0], TILELINE_ADDR[1:0]}; //32*16    2 vetrical tiles
        4'h3: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:5], VTILE_ADDR[2:0], HLINE_ADDR[2:0], TILELINE_ADDR[2:0]}; //64*64    8 vetrical tiles
        4'h4: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:0],            1'b0, HLINE_ADDR[2:0]                    }; //8*8      1 vetrical tiles
        4'h5: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:0],                  HLINE_ADDR[2:0], TILELINE_ADDR[0:0]}; //16*8     1 vetrical tiles
        4'h6: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:0], VTILE_ADDR[0:0], HLINE_ADDR[2:0]                    }; //8*16     2 vetrical tiles
        4'h7: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:1], VTILE_ADDR[0:0], HLINE_ADDR[2:0], TILELINE_ADDR[0:0]}; //16*16    2 vetrical tiles

        4'h8: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:4], VTILE_ADDR[2:0], HLINE_ADDR[2:0], TILELINE_ADDR[1:0]}; //32*64    8 vetrical tiles
        4'h9: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:3], VTILE_ADDR[2:0], HLINE_ADDR[2:0], TILELINE_ADDR[0:0]}; //16*64    8 vetrical tiles
        4'hA: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:4], VTILE_ADDR[1:0], HLINE_ADDR[2:0], TILELINE_ADDR[1:0]}; //32*32    4 vetrical tiles
        4'hB: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:6], VTILE_ADDR[3:0], HLINE_ADDR[2:0], TILELINE_ADDR[2:0]}; //64*128   16 vetrical tiles
        4'hC: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:0], VTILE_ADDR[0:0], HLINE_ADDR[2:0]                    }; //8*16     2 vetrical tiles
        4'hD: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:1], VTILE_ADDR[0:0], HLINE_ADDR[2:0], TILELINE_ADDR[0:0]}; //16*16    2 vetrical tiles
        4'hE: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:1], VTILE_ADDR[1:0], HLINE_ADDR[2:0]                    }; //8*32     4 vetrical tiles
        4'hF: CHARRAM_ADDR <= {LATCH_D[7:6], LATCH_C[7:2], VTILE_ADDR[1:0], HLINE_ADDR[2:0], TILELINE_ADDR[0:0]}; //16*32    4 vetrical tiles
    endcase
end








///////////////////////////////////////////////////////////
//////  SCREEN COUNTER
////

//X Screen Counter
reg     [6:0]   buffer_x_screencounter = 7'd0;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        if(i_ABS_1H == 1'b1) //negedge of 1H
        begin
            if(i_OBJWR == 1'b1)
            begin
                buffer_x_screencounter <= 7'd0;
            end
            else
            begin
                if(buffer_x_screencounter == 7'd127)
                begin
                    buffer_x_screencounter <= 7'd0;
                end 
                else
                begin
                    buffer_x_screencounter <= buffer_x_screencounter + 7'd1;
                end
            end
        end
    end
end

/*
    Y Screen Counter

    This Y Screen Counter increases at a rising edge of i_HBLANK_n,
    asynchronously. But we need to synchronize all flip-flops to 
    the master clock, so there was no choice but to install an edge 
    detector, and counting was delayed by one clock. However, a rising 
    edge of HBLANK increases the Y Counter before OBJ WR switches MUX 
    and the timing is not stern, so this delay is invisible from the 
    outside and does not affect the behavior.
*/

reg             prev_hblank;
reg     [7:0]   buffer_y_screencounter = 8'd15;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        prev_hblank <= i_HBLANK_n;

        if(i_VBLANK_n == 1'b0) //async reset by VBLANK
        begin
            buffer_y_screencounter <= 8'd15;
            
        end
        else
        begin
            if(i_HBLANK_n == 1'b1 && prev_hblank == 1'b0) //1 clk after the positive edge of vblank
            begin
                if(buffer_y_screencounter == 8'd255)
                begin
                    buffer_y_screencounter <= 8'd0;
                end 
                else
                begin
                    buffer_y_screencounter <= buffer_y_screencounter + 8'd1;
                end
            end
        end
    end
end








///////////////////////////////////////////////////////////
//////  BUFFER MUX
////

/*
    GX400 uses 1Mb of frame buffer, but 256*256 size sprite field consumes
    only 512kb. I think Konami engineers designed the hardware that can
    support interlaced mode that was never used.
*/

reg             buffer_frame_parity = 1'b0;
reg             prev_vblank;

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        prev_vblank <= i_VBLANK_n;

        if(i_VBLANK_n == 1'b0 && prev_vblank == 1'b1) //async reset by VBLANK
        begin
            buffer_frame_parity <= ~buffer_frame_parity | __SAVE_FRAMEBUFFER_CAPACITY;
        end
    end
end


reg     [15:0]  EVENBUFFER_ADDR; //unmultiplexed, buffer A on the Nemesis schematics
reg     [15:0]  ODDBUFFER_ADDR; //unmultiplexed, buffer B on the Nemesis schematics
assign  o_FA = (o_CAS == 1'b0) ? EVENBUFFER_ADDR[7:0] : EVENBUFFER_ADDR[15:8]; //RAS : CAS
assign  o_FB = (o_CAS == 1'b0) ?  ODDBUFFER_ADDR[7:0] :  ODDBUFFER_ADDR[15:8]; //RAS : CAS

always @(*)
begin
    case(i_OBJWR)
        1'b1: begin //sprite drawing period
            EVENBUFFER_ADDR <= {buffer_frame_parity, buffer_ypos_counter, evenbuffer_xpos_counter[6:0]};
            ODDBUFFER_ADDR  <= {buffer_frame_parity, buffer_ypos_counter, oddbuffer_xpos_counter[6:0]};
        end
        1'b0: begin //active video period
            EVENBUFFER_ADDR <= {buffer_frame_parity, buffer_y_screencounter ^ {8{i_FLIP}}, buffer_x_screencounter ^ {7{i_FLIP}}};
            ODDBUFFER_ADDR  <= {buffer_frame_parity, buffer_y_screencounter ^ {8{i_FLIP}}, buffer_x_screencounter ^ {7{i_FLIP}}};
        end
    endcase
end








///////////////////////////////////////////////////////////
//////  XA7 XB7
////

/*
    When the X coordinate goes out of the screen (xpos>255), the xpos counter
    value wraps around, which can damage the sprite drawn before, so make XA/XB
    as 1 and overwrite it with the existing data without updating the value.

    Need to delay 1 clk.
*/

always @(posedge i_EMU_MCLK)
begin
    if(!i_EMU_CLK6MPCEN_n)
    begin
        o_XA7 <= evenbuffer_xpos_counter[7];
        o_XB7 <= oddbuffer_xpos_counter[7];
    end
end








///////////////////////////////////////////////////////////
//////  CAS
////

assign  o_CAS = i_OBJHL;


endmodule