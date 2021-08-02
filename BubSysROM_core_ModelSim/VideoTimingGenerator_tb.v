`timescale 10ps/10ps

module VideoTimingGenerator_tb;

//reset & clock
reg             MCLK = 1'b1;
reg             MRST_n = 1'b0;

wire            POSCEN9M_n;
wire            NEGCEN9M_n;
wire            POSCEN6M_n;
wire            NEGCEN6M_n;
wire            HBLANK_n;
wire            VBLANK_n;
wire            VBLANKH_n;
wire    [8:0]   HABSCNTR;
wire    [7:0]   VABSCNTR;
wire    [7:0]   HFLIPCNTR;
wire    [7:0]   VFLIPCNTR;
wire            VCLK;
wire            VSYNC_n;
wire            CSYNC_;
wire            FRAMEPARITY;
wire            DMA_n;
wire            BLANK_n;
wire            TIME1;
wire            TIME2;
wire            CHRMUX;
wire            VRTIME;
wire            OBJBUFWE_n;
wire            OBJBUFRAS_n; 
wire            OBJBUFCLR;
wire            OBJBUFMUX;
wire            OBJBUFRDCEN_n;
wire            OBJBUFWRCEN_n;
wire            CLK9M_ref;
wire            CLK6M_ref;

wire            CPUDATA;
wire    [4:0]   MCLKCNTR12_emu;

VideoTimingGenerator VTG0
(
    .i_MCLK                 (MCLK                   ),   
    .i_MRST_n               (MRST_n                 ),   
    .i_HFLIP                (1'b0                   ),   
    .i_VFLIP                (1'b0                   ),   
    .o_9MPOSCEN_n           (POSCEN9M_n             ),       
    .o_9MNEGCEN_n           (NEGCEN9M_n             ),       
    .o_6MPOSCEN_n           (POSCEN6M_n             ),       
    .o_6MNEGCEN_n           (NEGCEN6M_n             ),       
    .o_HBLANK_n             (HBLANK_n               ),       
    .o_VBLANK_n             (VBLANK_n               ),       
    .o_VBLANKH_n            (VBLANKH_n              ),       
    .o_HABSCNTR             (HABSCNTR               ),   
    .o_VABSCNTR             (VABSCNTR               ),
    .o_HFLIPCNTR            (HFLIPCNTR              ),   
    .o_VFLIPCNTR            (VFLIPCNTR              ),   
    .o_VCLK                 (VCLK                   ),   
    .o_VSYNC_n              (VSYNC_n                ),   
    .o_CSYNC_n              (CSYNC_n                ),   
    .o_FRAMEPARITY          (FRAMEPARITY            ),       
    .o_DMA_n                (DMA_n                  ),   
    .o_BLANK_n              (BLANK_n                ),   
    .o_TIME1_ref            (TIME1                  ),   
    .o_TIME2_ref            (TIME2                  ),   
    .o_CHRMUX_ref           (CHRMUX                 ),   
    .o_VRTIME_ref           (VRTIME                 ),   
    .o_OBJBUFWE_n_ref       (OBJBUFWE_n             ),       
    .o_OBJBUFRAS_n_ref      (OBJBUFRAS_n            ),       
    .o_OBJBUFCLR            (OBJBUFCLR              ),       
    .o_OBJBUFMUX            (OBJBUFMUX              ),       
    .o_OBJBUFRDCEN_n        (OBJBUFRDCEN_n          ),           
    .o_OBJBUFWRCEN_n        (OBJBUFWRCEN_n          ),           
    .o_CLK9M_ref            (CLK9M_ref              ),       
    .o_CLK6M_ref            (CLK6M_ref              ),
    .o_MCLKCNTR12_emu       (MCLKCNTR12_emu         )
);
 
K005291 TG0 
( 
    .i_MCLK                 (MCLK                   ),   
    .i_HFLIP                (1'b0                   ),   
    .i_VFLIP                (1'b0                   ),
 
    .i_6MPOSCEN_n           (POSCEN6M_n             ),       
    .i_6MNEGCEN_n           (NEGCEN6M_n             ),
 
    .i_HABSCNTR             (HABSCNTR               ),   
    .i_VABSCNTR             (VABSCNTR               ),
    .i_HFLIPCNTR            (HFLIPCNTR              ),   
    .i_VFLIPCNTR            (VFLIPCNTR              ),
    .i_VCLK                 (VCLK                   ),
 
    .i_CPUADDR              (12'b111111111111       ),
    .io_CPUDATA             (CPUDATA                ),
    .i_CPURW                (1'b1                   ),
    .i_CPUUDS_n             (1'b1                   ),
    .i_CPULDS_n             (1'b1                   ),
    .i_VZCS_n               (1'b1                   ),
    .i_VCS1_n               (1'b1                   ),
    .i_VCS2_n               (1'b1                   ),
    .i_MCLKCNTR12_emu       (MCLKCNTR12_emu         )
);

always #1 MCLK = ~MCLK;

initial
begin
    #7 MRST_n = 1'b1;
end
endmodule