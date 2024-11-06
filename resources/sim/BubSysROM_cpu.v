`timescale 10ns/10ns
module BubSysROM_cpu (
    input   wire            i_EMU_MCLK,
    input   wire            i_EMU_CLK9M_PCEN,
    input   wire            i_EMU_CLK9M_NCEN,
    input   wire            i_EMU_CLK6M_PCEN,
    input   wire            i_EMU_CLK6M_NCEN,

    input   wire            i_EMU_INITRST_n,
    input   wire            i_EMU_SOFTRST_n,

    //reset control by the sound CPU
    input   wire            i_MAINCPU_RSTCTRL,
    output  wire            o_MAINCPU_RSTSTAT,

    output  wire    [14:0]  o_GFX_ADDR,
    input   wire    [15:0]  i_GFX_DO,
    output  wire    [15:0]  o_GFX_DI, 
    output  wire            o_GFX_RnW,
    output  wire            o_GFX_UDS_n,
    output  wire            o_GFX_LDS_n,

    output  reg             o_VZCS_n,
    output  reg             o_VCS1_n,
    output  reg             o_VCS2_n,
    output  reg             o_CHACS_n,
    output  reg             o_OBJRAM_n,
    
    output  wire            o_HFLIP,
    output  wire            o_VFLIP,

    input   wire            i_ABS_1H_n,
    input   wire            i_ABS_2H,
    input   wire            i_ABS_32H,

    input   wire            i_VBLANK_n,
    input   wire            i_FRAMEPARITY,

    input   wire            i_BLK,

    input   wire    [10:0]  i_CD,

    //sound interrupts/DMA
    output  wire            o_SND_NMI,
    output  wire            o_SND_INT,
    output  wire    [7:0]   o_SND_CODE,
    output  wire            o_SND_DMA_BR,
    input   wire            i_SND_DMA_BG_n,
    output  wire    [14:1]  o_SND_DMA_ADDR,
    output  wire    [7:0]   o_SND_DMA_DO,
    input   wire    [7:0]   i_SND_DMA_DI,
    output  wire            o_SND_DMA_RnW,
    output  wire            o_SND_DMA_LDS_n,
    output  reg             o_SND_DMA_SNDRAM_CS,

    input   wire    [7:0]   i_IN0, i_IN1, i_IN2, i_DIPSW1, i_DIPSW2, i_DIPSW3,

    output  wire    [4:0]   o_VIDEO_R,
    output  wire    [4:0]   o_VIDEO_G,
    output  wire    [4:0]   o_VIDEO_B,

    output  wire    [14:0]  o_EMU_BOOTROM_ADDR,
    input   wire    [15:0]  i_EMU_BOOTROM_DATA,
    output  wire            o_EMU_BOOTROM_RDRQ,

    output  wire    [16:0]  o_EMU_GAMEROM_ADDR,
    input   wire    [15:0]  i_EMU_GAMEROM_DATA,
    output  wire            o_EMU_GAMEROM_RDRQ
);



///////////////////////////////////////////////////////////
//////  CLOCK AND RESET
////

wire            maincpu_pwrup = ~i_EMU_INITRST_n;
wire            maincpu_rst = ~i_EMU_INITRST_n | ~i_EMU_SOFTRST_n | i_MAINCPU_RSTCTRL;
wire            mclk = i_EMU_MCLK;
wire            clk9m_pcen = i_EMU_CLK9M_PCEN;
wire            clk9m_ncen = i_EMU_CLK9M_NCEN;
wire            clk6m_pcen = i_EMU_CLK6M_PCEN;
wire            clk6m_ncen = i_EMU_CLK6M_NCEN;

assign  o_MAINCPU_RSTSTAT = maincpu_rst; //watchdog



///////////////////////////////////////////////////////////
//////  MAIN CPU
////

reg     [15:0]  maincpu_di;
wire    [15:0]  maincpu_do;
wire    [23:1]  maincpu_addr;
reg             maincpu_vpa_n;
reg             maincpu_dtack_n;
wire            maincpu_as_n, maincpu_r_nw, maincpu_lds_n, maincpu_uds_n;
wire    [23:0]  debug_maincpu_addr = {maincpu_addr, maincpu_uds_n};
reg     [2:0]   maincpu_ipl;

assign  o_GFX_ADDR = maincpu_addr[15:1];
assign  o_GFX_DI = maincpu_do;
assign  o_GFX_RnW = maincpu_r_nw;
assign  o_GFX_UDS_n = maincpu_uds_n;
assign  o_GFX_LDS_n = maincpu_lds_n;

fx68k u_maincpu (
    .clk                        (mclk                       ),
    .HALTn                      (1'b1                       ),
    .extReset                   (maincpu_rst                ),
    .pwrUp                      (maincpu_pwrup              ),
    .enPhi1                     (clk9m_pcen                 ),
    .enPhi2                     (clk9m_ncen                 ),

    .eRWn                       (maincpu_r_nw               ),
    .ASn                        (maincpu_as_n               ),
    .LDSn                       (maincpu_lds_n              ),
    .UDSn                       (maincpu_uds_n              ),
    .E                          (                           ),
    .VMAn                       (                           ),

    .iEdb                       (maincpu_di                 ), //data bus in
    .oEdb                       (maincpu_do                 ), //data bus out
    .eab                        (maincpu_addr               ), //23 downto 1

    .FC0                        (                           ),
    .FC1                        (                           ),
    .FC2                        (                           ),
    
    .BGn                        (                           ),
    .oRESETn                    (                           ),
    .oHALTEDn                   (                           ),

    .DTACKn                     (maincpu_dtack_n            ),
    .VPAn                       (maincpu_vpa_n              ),
    
    .BERRn                      (1'b1                       ),

    .BRn                        (1'b1                       ),
    .BGACKn                     (1'b1                       ),

    .IPL0n                      (maincpu_ipl[0]             ),
    .IPL1n                      (maincpu_ipl[1]             ),
    .IPL2n                      (maincpu_ipl[2]             )
);



///////////////////////////////////////////////////////////
//////  ADDRESS DECODER
////

reg             bootrom_rd, gamerom_rd, workram_cs, extram_cs;
reg             dmastat_cs, sndlatch_cs;
reg             palram_cs;
reg             syscfg_cs, dip_cs, btn_cs;
always @(*) begin
    bootrom_rd  = 1'b0; //BIOS/bootloader
    gamerom_rd  = 1'b0;
    workram_cs  = 1'b0;
    extram_cs   = 1'b0;
    
    dmastat_cs  = 1'b0;
    sndlatch_cs = 1'b0;
    o_SND_DMA_SNDRAM_CS = 1'b0;

    syscfg_cs   = 1'b0;
    dip_cs      = 1'b0;
    btn_cs      = 1'b0;
    
    palram_cs   = 1'b0;
    o_VZCS_n    = 1'b1;
    o_VCS1_n    = 1'b1;
    o_VCS2_n    = 1'b1;
    o_CHACS_n   = 1'b1;
    o_OBJRAM_n  = 1'b1;

    maincpu_vpa_n = 1'b1;

    if(!maincpu_as_n && !maincpu_addr[23] &&  maincpu_addr[19]) begin
        gamerom_rd  = 1'b1; //0x080000-0x0BFFFF, 1M*2
    end

    if(!maincpu_as_n && !maincpu_addr[23] && !maincpu_addr[19]) begin
        //1st LS138
        bootrom_rd  =   maincpu_addr[18:16] == 3'b000;  //0x000000-0x00FFFF, 27256*2
        workram_cs  =   maincpu_addr[18:16] == 3'b001;  //0x010000-0x01FFFF, 62256*2
        o_SND_DMA_SNDRAM_CS = maincpu_addr[18:16] == 3'b010;  //0x020000-0x027FFF, sound RAM address space
        o_CHACS_n   = ~(maincpu_addr[18:16] == 3'b011); //0x030000-0x03FFFF, 4416*8
        extram_cs   =   maincpu_addr[18:16] == 3'b111;  //0x070000-0x07FFFF, 6264*2(expansion RAM)
        
        //2nd LS138
        if(maincpu_addr[18:16] == 3'b101) begin
        o_VZCS_n    = ~(maincpu_addr[15:13] == 3'b000); //0x050000-0x050FFF, 16k*1, byte only
        o_VCS1_n    = ~(maincpu_addr[15:13] == 3'b001); //0x052000-0x053FFF, 32k*2, Toshiba 32kbit TC5533
        o_VCS2_n    = ~(maincpu_addr[15:13] == 3'b010); //0x054000-0x055FFF, 32k*1, byte only
        o_OBJRAM_n  = ~(maincpu_addr[15:13] == 3'b011); //0x056000-0x056FFF, 16k*1, byte only
        palram_cs   =   maincpu_addr[15:13] == 3'b101;  //0x05A000-0x05AFFF, 16k*2, byte only
        syscfg_cs   =   maincpu_addr[15:13] == 3'b111;
        end

        //3rd LS138
        if(maincpu_addr[18:13] == 6'b101_110) begin
        sndlatch_cs =   maincpu_addr[12:10] == 3'b000;
        dip_cs      =   maincpu_addr[12:10] == 3'b001;
        btn_cs      =   maincpu_addr[12:10] == 3'b011;
        dmastat_cs  =   maincpu_addr[12:10] == 3'b100;
        end
    end

    maincpu_vpa_n = maincpu_as_n | ~maincpu_addr[23];
end



///////////////////////////////////////////////////////////
//////  MAIN CPU DTACK
////

//work ram timings
reg             abs_32h_z;
wire            abs_32h_pe = i_ABS_32H & ~abs_32h_z;
always @(posedge mclk) if(clk6m_pcen) abs_32h_z <= i_ABS_32H;

reg     [2:0]   workram_rfsh_stat = 3'd0; //0 = idle, 1, 2, 3 = refresh, 4 = refresh pending
always @(posedge mclk) if(clk6m_pcen) begin
    if(workram_rfsh_stat == 3'd0) begin
        if(workram_cs) begin
            if(abs_32h_pe) workram_rfsh_stat <= 3'd4;
        end
        else begin
            if(abs_32h_pe) workram_rfsh_stat <= workram_rfsh_stat + 2'd1;
        end
    end
    else if(workram_rfsh_stat == 3'd4) begin
        if(!workram_cs) workram_rfsh_stat <= 3'd1;
    end
    else begin
        if(workram_rfsh_stat == 3'd3) workram_rfsh_stat <= 3'd0;
        else workram_rfsh_stat <= workram_rfsh_stat + 3'd1;
    end
end

//dtack generator
wire            dtack0_n = 1'b0;
reg             dtack1_n, dtack2_pre_n, dtack2_n;
wire            dtack3_n = ~((workram_rfsh_stat == 3'd0 | workram_rfsh_stat == 3'd4) & workram_cs);
always @(posedge mclk) begin
    if(maincpu_uds_n & maincpu_lds_n) begin
        dtack1_n <= 1'b1;
        dtack2_pre_n <= 1'b1;
        dtack2_n <= 1'b1;
    end
    else begin
        if(clk6m_pcen) begin
            if(!i_ABS_1H_n) dtack1_n <= 1'b0;
            dtack2_pre_n <= 1'b0;
        end

        if(clk6m_ncen) begin
            if({i_ABS_2H, ~i_ABS_1H_n} == 2'b00) dtack2_n <= dtack2_pre_n;
        end
    end
end

//DTACK selector
wire    [1:0]   dtack_sel;
assign  dtack_sel[1] = workram_cs | o_SND_DMA_SNDRAM_CS | ~o_CHACS_n | ~o_VCS1_n | ~o_VCS2_n; // | exdtack <- not used, never used
assign  dtack_sel[0] = workram_cs | ~o_VZCS_n | ~o_OBJRAM_n;
always @(*) begin
    case(dtack_sel)
        2'd0: maincpu_dtack_n = dtack0_n; //bootloader ROM, program ROM(2Mbit), IO spaces
        2'd1: maincpu_dtack_n = dtack1_n; //scrollram, objram
        2'd2: maincpu_dtack_n = dtack2_n; //soundram, charram, vram1, vram2
        2'd3: maincpu_dtack_n = dtack3_n; //workram
    endcase
end



///////////////////////////////////////////////////////////
//////  MAIN CPU IRQ
////

wire            iack_vblank_n, iack_fparity_n, iack_timer_n;
reg             vblank_z, vblank_zz, fparity_z, fparity_zz, timer_z, timer_zz;
reg             irq_vblank_n, irq_fparity_n, irq_timer_n;

always @(posedge mclk) begin
    vblank_z <= ~i_VBLANK_n;
    vblank_zz <= vblank_z;
    fparity_z <= i_FRAMEPARITY;
    fparity_zz <= fparity_z;
    timer_z <= ~i_VBLANK_n;
    timer_zz <= timer_z;

    if(maincpu_rst) begin
        irq_vblank_n <= 1'b1;
        irq_fparity_n <= 1'b1;
        irq_timer_n <= 1'b1;
    end
    else begin
        if(!iack_vblank_n) irq_vblank_n <= 1'b1;
        else begin
            if({vblank_zz, vblank_z} == 2'b01) irq_vblank_n <= 1'b0;
        end
        if(!iack_fparity_n) irq_fparity_n <= 1'b1;
        else begin
            if({fparity_zz, fparity_z} == 2'b01) irq_fparity_n <= 1'b0;
        end
        if(!iack_timer_n) irq_timer_n <= 1'b1;
        else begin
            if({timer_zz, timer_z} == 2'b01) irq_timer_n <= 1'b0;
        end
    end

    if(clk9m_pcen) begin
        if(!irq_timer_n) maincpu_ipl <= 3'b011;
        else begin
            if(!irq_vblank_n) maincpu_ipl <= 3'b101;
            else begin
                if(!irq_fparity_n) maincpu_ipl <= 3'b110;
                else maincpu_ipl <= 3'b111;
            end
        end
    end
end



///////////////////////////////////////////////////////////
//////  OUTLATCH(SYSTEM CONFIGURATION)
////

reg     [5:0]   syscfg[0:1];
always @(posedge mclk) begin
    if(maincpu_rst) begin
        syscfg[0] <= 6'h00;
        syscfg[1] <= 6'h00;
    end
    else begin if(syscfg_cs) begin
        if(!maincpu_uds_n) begin
            case(maincpu_addr[3:1])
                //3'd0: syscfg[0][0] <= maincpu_do[8]; //coin counter 1
                //3'd1: syscfg[0][1] <= maincpu_do[8];
                3'd2: syscfg[0][2] <= maincpu_do[8]; //sound interrupt tick
                3'd3: syscfg[0][3] <= maincpu_do[8]; //dma_busrq
                3'd4: syscfg[0][4] <= maincpu_do[8]; //sound NMI
                3'd7: syscfg[0][5] <= maincpu_do[8]; //timerirq_ack_n
                default: ;
            endcase
        end
        if(!maincpu_lds_n) begin
            case(maincpu_addr[3:1])
                3'd0: syscfg[1][0] <= maincpu_do[0]; //vblankirq_ack_n
                3'd1: syscfg[1][1] <= maincpu_do[0]; //frameirq_ack_n
                3'd2: syscfg[1][2] <= maincpu_do[0]; //gfx_hflip
                3'd3: syscfg[1][3] <= maincpu_do[0]; //gfx_vflip
                //3'd4: syscfg[1][4] <= maincpu_do[0]; //gfx_h288
                //3'd5: syscfg[1][5] <= maincpu_do[0]; //gfx_interlaced
                default: ;
            endcase
        end
    end end
end

assign  iack_vblank_n = syscfg[1][0];
assign  iack_fparity_n = syscfg[1][1];
assign  iack_timer_n = syscfg[0][5];
assign  o_HFLIP = syscfg[1][2];
assign  o_VFLIP = syscfg[1][3];
assign  o_SND_INT = syscfg[0][2];
assign  o_SND_NMI = syscfg[0][4];



///////////////////////////////////////////////////////////
//////  PROGRAM ROM
////


wire    [15:0]  bootrom_q; 
BubSysROM_PROM #(.AW(15), .DW(8), .simhexfile("rom_15l.txt")) u_bootrom_hi (
    .i_MCLK                     (i_EMU_MCLK                 ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b1                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (maincpu_addr[15:1]         ),
    .o_DOUT                     (bootrom_q[15:8]            ),
    .i_RD                       (bootrom_rd                 )
);
BubSysROM_PROM #(.AW(15), .DW(8), .simhexfile("rom_10l.txt")) u_bootrom_lo (
    .i_MCLK                     (i_EMU_MCLK                 ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b1                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (maincpu_addr[15:1]         ),
    .o_DOUT                     (bootrom_q[7:0]             ),
    .i_RD                       (bootrom_rd                 )
); 
/*
assign  o_EMU_BOOTROM_ADDR = maincpu_addr[15:1];
assign  bootrom_q = i_EMU_BOOTROM_DATA;
assign  o_EMU_BOOTROM_RDRQ = bootrom_rd; */

wire    [15:0]  gamerom_q; 
BubSysROM_PROM #(.AW(17), .DW(8), .simhexfile("rom_17l.txt")) u_gamerom_hi (
    .i_MCLK                     (i_EMU_MCLK                 ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b1                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (maincpu_addr[17:1]         ),
    .o_DOUT                     (gamerom_q[15:8]            ),
    .i_RD                       (gamerom_rd                 )
);
BubSysROM_PROM #(.AW(17), .DW(8), .simhexfile("rom_12l.txt")) u_gamerom_lo (
    .i_MCLK                     (i_EMU_MCLK                 ),

    .i_PROG_ADDR                (                           ),
    .i_PROG_DIN                 (                           ),
    .i_PROG_CS                  (1'b1                       ),
    .i_PROG_WR                  (                           ),

    .i_ADDR                     (maincpu_addr[17:1]         ),
    .o_DOUT                     (gamerom_q[7:0]             ),
    .i_RD                       (gamerom_rd                 )
);
/*
assign  o_EMU_GAMEROM_ADDR = maincpu_addr[17:1];
assign  gamerom_q = i_EMU_GAMEROM_DATA;
assign  o_EMU_GAMEROM_RDRQ = gamerom_rd; */

wire    [15:0]  workram_q;
BubSysROM_SRAM #(.AW(15), .DW(8), .simhexfile()) u_workram_hi (
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (maincpu_addr[15:1]         ),
    .i_DIN                      (maincpu_do[15:8]           ),
    .o_DOUT                     (workram_q[15:8]            ),
    .i_WR                       (workram_cs & ~maincpu_r_nw & ~maincpu_uds_n),
    .i_RD                       (workram_cs &  maincpu_r_nw & ~maincpu_uds_n)
);
BubSysROM_SRAM #(.AW(15), .DW(8), .simhexfile()) u_workram_lo (
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (maincpu_addr[15:1]         ),
    .i_DIN                      (maincpu_do[7:0]            ),
    .o_DOUT                     (workram_q[7:0]             ),
    .i_WR                       (workram_cs & ~maincpu_r_nw & ~maincpu_lds_n),
    .i_RD                       (workram_cs &  maincpu_r_nw & ~maincpu_lds_n)
);

//6264*2, gradius uses this
wire    [15:0]  extram_q;
BubSysROM_SRAM #(.AW(13), .DW(8), .simhexfile()) u_extram_hi (
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (maincpu_addr[13:1]         ),
    .i_DIN                      (maincpu_do[15:8]           ),
    .o_DOUT                     (extram_q[15:8]            ),
    .i_WR                       (extram_cs & ~maincpu_r_nw & ~maincpu_uds_n),
    .i_RD                       (extram_cs &  maincpu_r_nw & ~maincpu_uds_n)
);
BubSysROM_SRAM #(.AW(13), .DW(8), .simhexfile()) u_extram_lo (
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (maincpu_addr[13:1]         ),
    .i_DIN                      (maincpu_do[7:0]            ),
    .o_DOUT                     (extram_q[7:0]             ),
    .i_WR                       (extram_cs & ~maincpu_r_nw & ~maincpu_lds_n),
    .i_RD                       (extram_cs &  maincpu_r_nw & ~maincpu_lds_n)
);




///////////////////////////////////////////////////////////
//////  Palette RAM
////

//make palram wr signal
wire            palram_hi_cs = &{palram_cs, ~maincpu_uds_n};
wire            palram_lo_cs = &{palram_cs, ~maincpu_lds_n};

//make colorram address
wire    [10:0]  palram_addr = palram_cs ? maincpu_addr[11:1] : i_CD;

//declare COLORRAM
wire    [7:0]   palram_lo_q, palram_hi_q;
wire    [15:0]  palram_q = {palram_hi_q, palram_lo_q};

BubSysROM_SRAM #(.AW(11), .DW(8), .simhexfile()) u_palram_hi (
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (palram_addr                ),
    .i_DIN                      (maincpu_do[15:8]           ),
    .o_DOUT                     (palram_hi_q                ),
    .i_WR                       (palram_hi_cs & ~maincpu_r_nw),
    .i_RD                       (1'b1                       )
);

BubSysROM_SRAM #(.AW(11), .DW(8), .simhexfile()) u_palram_lo (
    .i_MCLK                     (i_EMU_MCLK                 ),
    .i_ADDR                     (palram_addr                ),
    .i_DIN                      (maincpu_do[7:0]            ),
    .o_DOUT                     (palram_lo_q                ),
    .i_WR                       (palram_lo_cs & ~maincpu_r_nw),
    .i_RD                       (1'b1                       )
);

//rgb driver latch
reg     [14:0]  rgblatch;
always @(posedge mclk) if(clk6m_pcen) begin
    rgblatch <= {palram_hi_q[6:0], palram_lo_q};
end

assign  o_VIDEO_B = i_BLK ? rgblatch[14:10] : 5'd0;
assign  o_VIDEO_G = i_BLK ? rgblatch[9:5] : 5'd0;
assign  o_VIDEO_R = i_BLK ? rgblatch[4:0] : 5'd0;



///////////////////////////////////////////////////////////
////// SOUNDLATCH
////

reg     [7:0]   soundlatch = 8'h00;
assign  o_SND_CODE = soundlatch;
always @(posedge mclk) begin
    if(sndlatch_cs && !maincpu_r_nw && !maincpu_lds_n) soundlatch <= maincpu_do[7:0];
end



///////////////////////////////////////////////////////////
//////  DMA
////

assign  o_SND_DMA_BR = syscfg[0][3]; //sound cpu bus request
assign  o_SND_DMA_ADDR = maincpu_addr[14:1];
assign  o_SND_DMA_DO   = maincpu_do[7:0];
assign  o_SND_DMA_RnW  = maincpu_r_nw;
assign  o_SND_DMA_LDS_n = maincpu_lds_n;




///////////////////////////////////////////////////////////
//////  READ BUS MUX
////

wire            gfx_cs = ~&{o_VZCS_n, o_VCS1_n, o_VCS2_n, o_CHACS_n, o_OBJRAM_n};

//CDC synchronizer
reg     [7:0]   snd_dma_di_sync[0:1];
reg     [1:0]   snd_dma_bg_n_sync;
always @(posedge mclk) begin
    snd_dma_di_sync[0] <= i_SND_DMA_DI;
    snd_dma_di_sync[1] <= snd_dma_di_sync[0];

    snd_dma_bg_n_sync[0] <= i_SND_DMA_BG_n;
    snd_dma_bg_n_sync[1] <= snd_dma_bg_n_sync[0];
end

wire mod = maincpu_addr == 23'h8021;

always @(*) begin
    maincpu_di = 16'hFFFF;

    if(bootrom_rd) begin /*
             if(maincpu_addr == 23'h080) maincpu_di = 16'h13FC;
        else if(maincpu_addr == 23'h081) maincpu_di = 16'h0001;
        else if(maincpu_addr == 23'h082) maincpu_di = 16'h0005;
        else if(maincpu_addr == 23'h083) maincpu_di = 16'hE008;
        else if(maincpu_addr == 23'h084) maincpu_di = 16'h13FC;
        else if(maincpu_addr == 23'h085) maincpu_di = 16'h0000;
        else if(maincpu_addr == 23'h086) maincpu_di = 16'h0005;
        else if(maincpu_addr == 23'h087) maincpu_di = 16'hE008;
        else if(maincpu_addr == 23'h088) maincpu_di = 16'h13FC;
        else if(maincpu_addr == 23'h089) maincpu_di = 16'h0001;
        else if(maincpu_addr == 23'h08A) maincpu_di = 16'h0005;
        else if(maincpu_addr == 23'h08B) maincpu_di = 16'hE006;
        else if(maincpu_addr == 23'h08C) maincpu_di = 16'h0839;
        else if(maincpu_addr == 23'h08D) maincpu_di = 16'h0000;
        else if(maincpu_addr == 23'h08E) maincpu_di = 16'h0005;
        else if(maincpu_addr == 23'h08F) maincpu_di = 16'hD001;
        else if(maincpu_addr == 23'h090) maincpu_di = 16'h66F6;
        else if(maincpu_addr == 23'h091) maincpu_di = 16'h43F9;
        else if(maincpu_addr == 23'h092) maincpu_di = 16'h0002;
        else if(maincpu_addr == 23'h093) maincpu_di = 16'h0000;
        else if(maincpu_addr == 23'h094) maincpu_di = 16'h41F9;
        else if(maincpu_addr == 23'h095) maincpu_di = 16'h0001;
        else if(maincpu_addr == 23'h096) maincpu_di = 16'h0200;
        else if(maincpu_addr == 23'h097) maincpu_di = 16'h323C;
        else if(maincpu_addr == 23'h098) maincpu_di = 16'h000F;
        else if(maincpu_addr == 23'h099) maincpu_di = 16'h2418;
        else if(maincpu_addr == 23'h09A) maincpu_di = 16'h05C9;
        else if(maincpu_addr == 23'h09B) maincpu_di = 16'h0001;
        else if(maincpu_addr == 23'h09C) maincpu_di = 16'h43E9;
        else if(maincpu_addr == 23'h09D) maincpu_di = 16'h0008;
        else if(maincpu_addr == 23'h09E) maincpu_di = 16'h51C9;
        else if(maincpu_addr == 23'h09F) maincpu_di = 16'hFFF4;
        else if(maincpu_addr == 23'h0A0) maincpu_di = 16'h13FC;
        else if(maincpu_addr == 23'h0A1) maincpu_di = 16'h0000;
        else if(maincpu_addr == 23'h0A2) maincpu_di = 16'h0005;
        else if(maincpu_addr == 23'h0A3) maincpu_di = 16'hE006; */
        if(maincpu_addr == 23'h081) maincpu_di = 16'h000F;
        else maincpu_di = bootrom_q;
    end
    else if(gamerom_rd) maincpu_di = gamerom_q;
    else if(workram_cs) begin
        if(maincpu_addr == 23'h8021) maincpu_di = 16'hA000;
        else if(maincpu_addr >= 23'h8022 && maincpu_addr <= 23'h8035) maincpu_di = 16'h4E71;
        else maincpu_di = workram_q;
    end
    else if(extram_cs) maincpu_di = extram_q;
    else if(palram_cs) maincpu_di = palram_q;
    else if(gfx_cs) maincpu_di = i_GFX_DO;
    else if(btn_cs) begin
        case(maincpu_addr[2:1])
            2'd0: maincpu_di = {8'hFF, i_IN0};
            2'd1: maincpu_di = {8'hFF, i_IN1};
            2'd2: maincpu_di = {8'hFF, i_IN2};
            2'd3: maincpu_di = {16'hFFFF};
        endcase
    end
    else if(dip_cs) begin
        case(maincpu_addr[2:1])
            2'd0: maincpu_di = {16'hFFFF};
            2'd1: maincpu_di = {8'hFF, i_DIPSW1};
            2'd2: maincpu_di = {8'hFF, i_DIPSW2};
            2'd3: maincpu_di = {8'hFF, i_DIPSW3};
        endcase
    end
    else if(o_SND_DMA_SNDRAM_CS) maincpu_di = {8'hFF, snd_dma_di_sync[1]};
    else if(dmastat_cs) maincpu_di = {{15{1'b1}}, snd_dma_bg_n_sync[1]};
end


endmodule