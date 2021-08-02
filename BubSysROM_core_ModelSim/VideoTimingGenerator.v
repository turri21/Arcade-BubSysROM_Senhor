module VideoTimingGenerator
(
    input   wire            i_EMU_MCLK, //36.864(PLL 36.868687)

    output  wire            o_EMU_9MPOSCEN_n,
    output  wire            o_EMU_9MNEGCEN_n,
    output  wire            o_EMU_6MPOSCEN_n,
    output  wire            o_EMU_6MNEGCEN_n,

    input   wire            i_MRST_n,
    
    input   wire            i_HFLIP,
    input   wire            i_VFLIP,

    output  wire            o_HBLANK_n,
    output  reg             o_VBLANK_n = 1'b1,
    output  reg             o_VBLANKH_n = 1'b1,

    output  wire    [8:0]   o_HABSCNTR,     //256H  128H  64H  32H  16H  8H  4H  2H  1H
    output  wire    [7:0]   o_VABSCNTR,     //      128V  64V  32V  16V  8V  4V  2V  1V
    output  wire    [7:0]   o_HFLIPCNTR,    //      128H* 64H* 32H* 16H* 8H* 4H* 2H* 1H*
    output  wire    [7:0]   o_VFLIPCNTR,    //      128V* 64V* 32V* 16V* 8V* 4V* 2V* 1V*
    output  reg             o_VCLK = 1'b0,

    output  wire            o_VSYNC_n,
    output  wire            o_CSYNC_n,
    output  reg             o_FRAMEPARITY = 1'b0,
    output  reg             o_DMA_n = 1'b1,

    output  wire            o_BLANK_n,

    output  wire            o_OBJBUFCLR, //1=clear buffer(write 0x00) data after reading, during an active video period(OBJ CLR on Nemesis schematic)
    output  wire            o_OBJBUFMUX, //1=blanking, 0=active video period(OBJ R/W on Nemesis schematic)





    //test
    output  reg             o_OBJBUFRDCEN_n = 1'b1,
    output  reg             o_OBJBUFWRCEN_n = 1'b1,

    //reference ??
    output  reg             o_CLK9M_ref = 1'b1,
    output  reg             o_CLK6M_ref = 1'b1,

    output  wire            o_TIME1_ref,
    output  wire            o_TIME2_ref,
    output  wire            o_CHRMUX_ref,
    output  wire            o_VRTIME_ref,

    output  wire            o_OBJBUFWE_n_ref, //14H LS157 pin14, clears buffer during WE is down when an active video period(BLK on Nemesis schematic)
    output  wire            o_OBJBUFRAS_n_ref, //should be delayed by a 470pF cap, about 50ns

    //emulator signal
    output  wire    [3:0]   o_MCLKCNTR12_emu
);



///////////////////////////////////////////////////////////
//////  CLOCK ENABLE SIGNAL GENERATOR
////

/*
                                1 1
            0 1 2 3 4 5 6 7 8 9 0 1
    CLK18M  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
*/

reg     [3:0]   ref_clock_counter_12 = 4'd11;
assign o_MCLKCNTR12_emu = ref_clock_counter_12;

always @(posedge i_EMU_MCLK)
begin
    if(ref_clock_counter_12 < 4'd11)
    begin
        ref_clock_counter_12 <= ref_clock_counter_12 + 4'd1;
    end
    else
    begin
        ref_clock_counter_12 <= 4'd0;
    end
end

reg     [3:0]   cen_register = 4'b1111;
assign {o_EMU_9MPOSCEN_n, o_EMU_9MNEGCEN_n, o_EMU_6MPOSCEN_n, o_EMU_6MNEGCEN_n} = cen_register;

always @(negedge i_EMU_MCLK)
begin
    case(ref_clock_counter_12)

        4'd0: cen_register  <= 4'b1111;
        4'd1: cen_register  <= 4'b1011;
        4'd2: cen_register  <= 4'b1111;
        4'd3: cen_register  <= 4'b0110;
        4'd4: cen_register  <= 4'b1111;
        4'd5: cen_register  <= 4'b1001;
        4'd6: cen_register  <= 4'b1111;
        4'd7: cen_register  <= 4'b0111;
        4'd8: cen_register  <= 4'b1111;
        4'd9: cen_register  <= 4'b1010;
        4'd10: cen_register <= 4'b1111;
        4'd11: cen_register <= 4'b0101;

        default: cen_register <= 4'b1111;
    endcase
end



///////////////////////////////////////////////////////////
//////  PIXEL COUNTER/BLANKING/SYNC/DMA
////

reg     [8:0]   horizontal_counter = 9'd511;
assign o_HABSCNTR = horizontal_counter;
assign o_HFLIPCNTR = horizontal_counter[7:0] ^ {8{i_HFLIP}};
assign o_HBLANK_n = horizontal_counter[8];

reg     [8:0]   vertical_counter = 9'd511;
assign o_VABSCNTR = vertical_counter[7:0];
assign o_VFLIPCNTR = vertical_counter[7:0] ^ {8{i_VFLIP}};
assign o_VSYNC_n = vertical_counter[8];

always @(posedge i_EMU_MCLK)
begin
    if(i_MRST_n == 1'b0) //synchronous reset
    begin
        horizontal_counter <= 9'd511;
    end
    else
    begin //count up
        if(o_EMU_6MPOSCEN_n == 1'b0)
        begin
            if(horizontal_counter < 9'd511) //h count up
            begin
                if(horizontal_counter == 9'd175) //v count up
                begin
                    if(vertical_counter < 9'd511)
                    begin
                        //VBLANK
                        if(vertical_counter > 9'd495 || vertical_counter < 9'd271)
                        begin
                            o_VBLANK_n <= 1'b0;
                        end
                        else
                        begin
                            o_VBLANK_n <= 1'b1;
                        end
                        
                        //VBLANK**
                        if(vertical_counter > 9'd247 && vertical_counter < 9'd271)
                        begin
                            o_VBLANKH_n <= 1'b0;
                        end
                        else
                        begin
                            o_VBLANKH_n <= 1'b1;
                        end
                        
                        //256V
                        if(vertical_counter == 9'd495) //flip parity value
                        begin
                            o_FRAMEPARITY <= ~o_FRAMEPARITY;
                        end

                        //DMA
                        if(vertical_counter > 9'd478 && vertical_counter < 9'd496)
                        begin
                            o_DMA_n <= 1'b0;
                        end
                        else
                        begin
                            o_DMA_n <= 1'b1;
                        end

                        vertical_counter <= vertical_counter + 9'd1;
                    end
                    else
                    begin
                        vertical_counter <= 9'd248;
                    end
                end

                if(horizontal_counter > 9'd174 && horizontal_counter < 9'd207)
                begin
                    o_VCLK <= 1'b1;
                end
                else
                begin
                    o_VCLK <= 1'b0;
                end

                horizontal_counter <= horizontal_counter + 9'd1;
            end
            else    //h loop
            begin
                horizontal_counter <= 9'd128;
            end
        end
    end
end



///////////////////////////////////////////////////////////
//////  SYNC GENERATOR
////

assign o_VSYNC_n = vertical_counter[8];
assign o_CSYNC_n = o_VSYNC_n & ~o_VCLK;



///////////////////////////////////////////////////////////
//////  BLANK SCREEN/OBJBUF CLR/MUX SIGNAL GENERATOR
////

/*
    This block generates:
        o_BLANK_n       (BLK)
        o_OBJBUFCLR     (OBJ CLR)
        o_OBJBUFMUX     (OBJ R/W)
*/ 

reg     [21:0]  delay_shift_register = {22{1'b1}};
assign o_BLANK_n = delay_shift_register[21];
assign o_OBJBUFCLR = delay_shift_register[17];
assign o_OBJBUFMUX = ~delay_shift_register[17];

always @(posedge i_EMU_MCLK)
begin
    if(o_EMU_6MPOSCEN_n == 1'b0)
    begin
        delay_shift_register[0] <= o_HBLANK_n & o_VBLANK_n;
        delay_shift_register[21:1] <= delay_shift_register[20:0];
    end
end



///////////////////////////////////////////////////////////
//////  RAM CONTROL SIGNAL GENERATOR
////

/*
    This block generates:
        o_TIME1         (TIME1)         SCROLL/SPRITE RAM read latch enable(active high: LS373)
        o_TIME2         (TIME2)         SCROLL/SPRITE RAM write enable(active low: 6116 WE)
        o_CHRMUX        (CHAMPX)
        o_VRTIME        (VRTIME)        VRAM1/2 chip enable(active high: 6264 CE)
        o_OBJBUFWE_n    (dram WE)       SPRITE FRAME BUFFER write enable(active low: 4164 WE)
        o_OBJBUFRAS_n   (dram RAS)      SPRITE FRAME BUFFER row address strobe(active low: 4164 RAS)

                                            1 1
                        0 1 2 3 4 5 6 7 8 9 0 1 
    CLK18M  ¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|¯|_|
    CLK9M   ¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|¯¯¯|___|
    CLK6M   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯|___|
            ---(511)---|----(0)----|----(1)----|----(2)----|
    
    TIME1   ___________________|¯¯¯|___________________|¯¯¯|
    TIME2   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|
    CHRMUX  ¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|_______|¯¯¯¯
    VRTIME  ¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯
    BUFWE   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯
    BUFRAS  ___________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|____
    dl-ras  ____________|¯¯¯¯¯¯¯|_______________|¯¯¯¯¯¯¯|___

    for block ram
    BUFWR   ¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯
    BUFRD   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|
*/

reg     [5:0]   ram_control_register = 6'b011011;
assign  o_TIME1         = ram_control_register[5];
assign  o_TIME2         = ram_control_register[4];
assign  o_CHRMUX        = ram_control_register[3];
assign  o_VRTIME        = ram_control_register[2];
assign  o_OBJBUFWE_n    = ram_control_register[1];
assign  o_OBJBUFRAS_n   = ram_control_register[0];

always @(posedge i_EMU_MCLK)
begin
    case(o_MCLKCNTR12_emu[3:0])
        4'd0: ram_control_register <= 6'b010011; //cycle 1
        4'd1: ram_control_register <= 6'b010111; //cycle 2
        4'd2: ram_control_register <= 6'b010111; //cycle 3
        4'd3: ram_control_register <= 6'b101110; //cycle 4
        4'd4: ram_control_register <= 6'b101110; //cycle 5
        4'd5: ram_control_register <= 6'b011110; //cycle 6
        4'd6: ram_control_register <= 6'b011110; //cycle 7
        4'd7: ram_control_register <= 6'b011110; //cycle 8
        4'd8: ram_control_register <= 6'b011110; //cycle 9
        4'd9: ram_control_register <= 6'b011100; //cycle 10
        4'd10: ram_control_register <= 6'b011100; //cycle 11
        4'd11: ram_control_register <= 6'b010011; //cycle 0

        default: ram_control_register <= 6'b011011;
    endcase
end


///////////////////////////////////////////////////////////
//////  REFERENCE CLOCK GENERATOR
////

always @(posedge i_EMU_MCLK)
begin
    if(o_EMU_6MPOSCEN_n == 1'b0)
    begin
        o_CLK6M_ref <= 1'b1;
    end
    else if(o_EMU_6MNEGCEN_n == 1'b0)
    begin
        o_CLK6M_ref <= 1'b0;
    end
    else
    begin
        o_CLK6M_ref <= o_CLK6M_ref;
    end
end

always @(posedge i_EMU_MCLK)
begin
    if(o_EMU_9MPOSCEN_n == 1'b0)
    begin
        o_CLK9M_ref <= 1'b1;
    end
    else if(o_EMU_9MNEGCEN_n == 1'b0)
    begin
        o_CLK9M_ref <= 1'b0;
    end
    else
    begin
        o_CLK9M_ref <= o_CLK9M_ref;
    end
end

endmodule