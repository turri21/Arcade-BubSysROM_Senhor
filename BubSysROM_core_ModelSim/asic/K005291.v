module K005291
(
    //emulator
    input   wire            i_EMU_MCLK, //36.864(PLL 36.868687)
    input   wire            i_EMU_6MPOSCEN_n,
    input   wire            i_EMU_6MNEGCEN_n,
    input   wire    [4:0]   i_EMU_TIMING, //asynchronous RAM timings

    //CPU flip
    input   wire            i_HFLIP,
    input   wire            i_VFLIP,

    //HV counters
    input   wire    [8:0]   i_HABSCNTR,     //256H  128H  64H  32H  16H  8H  4H  2H  1H
    input   wire    [7:0]   i_VABSCNTR,     //      128V  64V  32V  16V  8V  4V  2V  1V
    input   wire    [7:0]   i_HFLIPCNTR,    //      128H* 64H* 32H* 16H* 8H* 4H* 2H* 1H*
    input   wire    [7:0]   i_VFLIPCNTR,    //      128V* 64V* 32V* 16V* 8V* 4V* 2V* 1V*
    input   wire            i_VCLK,

    //CPU address/data buses
    input   wire    [11:0]  i_CPUADDR,
    inout   wire    [15:0]  io_CPUDATA,
    input   wire            i_CPURW,
    input   wire            i_CPULDS_n,
    input   wire            i_CPUUDS_n,

    input   wire            i_VZCS_n,
    input   wire            i_VCS1_n,
    input   wire            i_VCS2_n,

    //to CHARRAM
    output  wire    [13:0]  o_TILEADDR,

    //to K005293
    output  wire    [3:0]   o_PRIORITY,
    output  wire    [6:0]   o_PALETTE,
    output  wire            o_HFLIPBIT,

    output  wire            o_SHIFTA1,
    output  wire            o_SHIFTA2,
    output  wire            o_SHIFTB
);

///////////////////////////////////////////////////////////
//////  PIXEL COUNTER BITS
////

wire            ABS_n256H   = ~i_HABSCNTR[8];
wire            ABS_128HA   = (i_HABSCNTR[8] & i_HABSCNTR[7]) | (~i_HABSCNTR[8] & i_HABSCNTR[5]);
wire            ABS_64H     = i_HABSCNTR[6];
wire            ABS_32H     = i_HABSCNTR[5];
wire            ABS_16H     = i_HABSCNTR[4];
wire            ABS_8H      = i_HABSCNTR[3];
wire            ABS_4H      = i_HABSCNTR[2];
wire            ABS_2H      = i_HABSCNTR[1];
wire            ABS_1H      = i_HABSCNTR[0];

wire            FLIP_n256H  = ABS_n256H ^ i_HFLIP;
wire            FLIP_256H   = ~i_HABSCNTR[8] ^ i_HFLIP;
wire            FLIP_128H   = i_HFLIPCNTR[7];
wire            FLIP_128HA  = ABS_128HA ^ i_HFLIP;
wire            FLIP_64H    = i_HFLIPCNTR[6];
wire            FLIP_32H    = i_HFLIPCNTR[5];
wire            FLIP_16H    = i_HFLIPCNTR[4];
wire            FLIP_8H     = i_HFLIPCNTR[3];
wire            FLIP_4H     = i_HFLIPCNTR[2];
wire            FLIP_2H     = i_HFLIPCNTR[1];
wire            FLIP_1H     = i_HFLIPCNTR[0];

wire            ABS_128V    = i_VABSCNTR[7];
wire            ABS_64V     = i_VABSCNTR[6];
wire            ABS_32V     = i_VABSCNTR[5];
wire            ABS_16V     = i_VABSCNTR[4];
wire            ABS_8V      = i_VABSCNTR[3];
wire            ABS_4V      = i_VABSCNTR[2];
wire            ABS_2V      = i_VABSCNTR[1];
wire            ABS_1V      = i_VABSCNTR[0];

wire            FLIP_128V   = i_VFLIPCNTR[7]; 
wire            FLIP_64V    = i_VFLIPCNTR[6];
wire            FLIP_32V    = i_VFLIPCNTR[5];
wire            FLIP_16V    = i_VFLIPCNTR[4];
wire            FLIP_8V     = i_VFLIPCNTR[3];
wire            FLIP_4V     = i_VFLIPCNTR[2];
wire            FLIP_2V     = i_VFLIPCNTR[1];
wire            FLIP_1V     = i_VFLIPCNTR[0];



///////////////////////////////////////////////////////////
//////  SCROLL RAM
////

wire    [10:0]  scrollram_address;
assign scrollram_address = (~i_VCLK == 1'b0) ? 
                           {1'b0, ABS_4H, ABS_2H, FLIP_128V, FLIP_64V,  FLIP_32V,  FLIP_16V,  FLIP_8V,  FLIP_4V,  FLIP_2V, FLIP_1V} : //HORIZONTAL SCROLL
                           {1'b1,   1'b1,   1'b1,      1'b1,   ABS_4H, FLIP_256H, FLIP_128H, FLIP_64H, FLIP_32H, FLIP_16H, FLIP_8H};  //VERTICAL SCROLL
wire    [7:0]   scroll_value_data;

SCROLLRAM SCROLLRAM_DEVICE
(
    .i_EMU_MCLK             (i_EMU_MCLK             ),
    .i_EMU_TIMING           (i_EMU_TIMING           ),

    .i_VZCS_n               (i_VZCS_n               ),
    .i_CPUADDR              (i_CPUADDR              ),
    .io_CPUDATA             (io_CPUDATA             ),
    .i_CPURW                (i_CPURW                ),
    .i_CPULDS_n             (i_CPULDS_n             ),

    .i_GFXADDR              (scrollram_address      ),
    .o_GFXDATA              (scroll_value_data      ) 
);



///////////////////////////////////////////////////////////
//////  SCROLL DATA LATCHES
////

//HSCROLL
reg     [8:0]   TMA_HSCROLL_VALUE = 9'h1F;
reg     [8:0]   TMB_HSCROLL_VALUE = 9'h1F; 

always @(posedge i_EMU_MCLK)
begin
    if(i_EMU_6MPOSCEN_n == 1'b0)
    begin
        case({ABS_4H, ABS_2H, ABS_1H})
            3'd1: begin TMA_HSCROLL_VALUE[7:0] <= scroll_value_data; end //latch TM-A lower bits at px1
            3'd3: begin TMA_HSCROLL_VALUE[8] <= scroll_value_data[0]; end   //latch TM-B high bit at px3
            3'd5: begin TMB_HSCROLL_VALUE[7:0] <= scroll_value_data; end //latch TM-A lower bits at px5
            3'd7: begin TMB_HSCROLL_VALUE[8] <= scroll_value_data[0]; end   //latch TM-B high bit at px7
            default: begin end
        endcase
    end
end

//VSCROLL
reg     [7:0]   TMAB_VSCROLL_VALUE = 8'hF;

always @(posedge i_EMU_MCLK)
begin
    if(i_EMU_6MPOSCEN_n == 1'b0)
    begin
        case({ABS_4H, ABS_2H, ABS_1H})
            3'd3: begin TMAB_VSCROLL_VALUE <= scroll_value_data; end  //latch TM-B second at px3
            3'd7: begin TMAB_VSCROLL_VALUE <= scroll_value_data; end  //latch TM-A first at px7
            default: begin end
        endcase
    end
end



///////////////////////////////////////////////////////////
//////  SHIFT SIGNAL GENERATOR
////

assign o_SHIFTA1 = (TMA_HSCROLL_VALUE[2:0] + {FLIP_4H, FLIP_2H, FLIP_1H} == 3'd7) ? 1'b0 : 1'b1;
assign o_SHIFTA2 = (TMB_HSCROLL_VALUE[2:0] + {FLIP_4H, FLIP_2H, FLIP_1H} == 3'd3) ? 1'b0 : 1'b1;
assign o_SHIFTB = (TMB_HSCROLL_VALUE[2:0] + {FLIP_4H, FLIP_2H, FLIP_1H} == 3'd3) ? 1'b0 : 1'b1;



///////////////////////////////////////////////////////////
//////  VRAM TILE ADDRESS GENERATOR
////

wire    [5:0]   horizontal_tile_address_bus; //6 bit: 64 horizontal tiles(512 horizontal pixels)
assign horizontal_tile_address_bus = (ABS_4H == 1'b0) ? 
                                     TMA_HSCROLL_VALUE[8:3] + {FLIP_n256H, FLIP_128HA, FLIP_64H, FLIP_32H, FLIP_16H, FLIP_8H} :
                                     TMB_HSCROLL_VALUE[8:3] + {FLIP_n256H, FLIP_128HA, FLIP_64H, FLIP_32H, FLIP_16H, FLIP_8H};
wire    [7:0]   vertical_tile_address_bus;
assign vertical_tile_address_bus = TMAB_VSCROLL_VALUE + {FLIP_128V, FLIP_64V, FLIP_32V, FLIP_16V, FLIP_8V, FLIP_4V, FLIP_2V, FLIP_1V};

wire    [11:0]  vram_tile_address_bus;
assign vram_tile_address_bus = {ABS_4H, vertical_tile_address_bus[7:3], horizontal_tile_address_bus};



///////////////////////////////////////////////////////////
//////  VRAM1+2
////

wire    [15:0]  vram1_gfx_data;
wire    [7:0]   vram2_gfx_data;

assign o_PRIORITY = vram1_gfx_data[15:12];
assign o_HFLIPBIT = vram2_gfx_data[7];
assign o_PALETTE = vram2_gfx_data[6:0];

VRAM VRAM_DEVICE
(
    .i_EMU_MCLK             (i_EMU_MCLK             ),
    .i_EMU_TIMING           (i_EMU_TIMING           ),

    .i_VCS1_n               (i_VCS1_n               ),
    .i_VCS2_n               (i_VCS2_n               ),
    .i_CPUADDR              (i_CPUADDR              ),
    .io_CPUDATA             (io_CPUDATA             ),
    .i_CPURW                (i_CPURW                ),
    .i_CPUUDS_n             (i_CPUUDS_n             ),
    .i_CPULDS_n             (i_CPULDS_n             ),

    .i_GFXADDR              (vram_tile_address_bus  ),
    .o_VRAM1GFXDATA         (vram1_gfx_data         ),
    .o_VRAM2GFXDATA         (vram2_gfx_data         )
);



///////////////////////////////////////////////////////////
//////  CHARRAM ADDRESS GENERATOR
////

always @(i_EMU_MCLK)
begin
    if(i_EMU_6MPOSCEN_n == 1'b0)
    begin
        if({ABS_2H, ABS_1H} == 2'd3) //at every negedge of 2H(pixel 3)
        begin
            o_TILEADDR[2:0] <= ({FLIP_4V, FLIP_2V, FLIP_1V} + TMAB_VSCROLL_VALUE[2:0]) ^ {3{vram1_gfx_data[11]}}; //{VA1, 2, 4} ^ vflip register bit = tile line address
            o_TILEADDR[13:3] <= vram1_gfx_data[10:0]; //tile address
        end
    end
end

endmodule