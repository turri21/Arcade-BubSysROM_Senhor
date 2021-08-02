module K005292
(
    input   wire            i_EMU_MCLK, //36.864(PLL 36.868687)
    output  wire            o_EMU_9MPOSCEN_n,
    output  wire            o_EMU_9MNEGCEN_n,
    output  wire            o_EMU_6MPOSCEN_n,
    output  wire            o_EMU_6MNEGCEN_n,
    output  wire    [4:0]   o_EMU_TIMING,
    output  reg             o_REF_CLK9M = 1'b1,
    output  reg             o_REF_CLK6M = 1'b1,

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

    output  reg             o_FRAMEPARITY = 1'b0,
    output  reg             o_DMA_n = 1'b1,

    output  wire            o_VSYNC_n,
    output  wire            o_CSYNC_n,

    output  wire            o_BLANK_n,
    output  wire            o_OBJBUFCLR, //1=clear buffer(write 0x00) data after reading, during an active video period(OBJ CLR on Nemesis schematic)
    output  wire            o_OBJBUFMUX, //1=blanking, 0=active video period(OBJ R/W on Nemesis schematic)
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
reg     [2:0]   ref_clock_counter_6 = 4'd5;

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

    if(ref_clock_counter_6 < 3'd5)
    begin
        ref_clock_counter_6 <= ref_clock_counter_6 + 3'd1;
    end
    else
    begin
        ref_clock_counter_6 <= 3'd0;
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
        if(o_6MPOSCEN_n == 1'b0)
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
//////  EMULATOR ASYNCHRONOUS RAM TIMING
////

assign o_EMU_TIMING[4:3] = horizontal_counter[1:0];
assign o_EMU_TIMING[2:0] = ref_clock_counter_6;

endmodule