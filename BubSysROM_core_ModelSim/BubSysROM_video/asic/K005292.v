/*
    K005292 VIDEO TIMING GENERATOR
*/

module K005292
(
    input   wire            i_EMU_MCLK,
    input   wire            i_EMU_CLK6MPCEN_n,

    input   wire            i_MRST_n,

    input   wire            i_HFLIP,
    input   wire            i_VFLIP,

    output  wire            o_HBLANK_n,
    output  reg             o_VBLANK_n = 1'b1,
    output  reg             o_VBLANKH_n = 1'b1,

    output  wire            o_ABS_256H,
    output  wire            o_ABS_128H,
    output  wire            o_ABS_64H, 
    output  wire            o_ABS_32H, 
    output  wire            o_ABS_16H, 
    output  wire            o_ABS_8H,  
    output  wire            o_ABS_4H,  
    output  wire            o_ABS_2H,
    output  wire            o_ABS_1H,

    output  wire            o_ABS_128V,
    output  wire            o_ABS_64V,
    output  wire            o_ABS_32V,
    output  wire            o_ABS_16V,
    output  wire            o_ABS_8V, 
    output  wire            o_ABS_4V, 
    output  wire            o_ABS_2V,
    output  wire            o_ABS_1V,

    output  wire            o_FLIP_128H, 
    output  wire            o_FLIP_64H, 
    output  wire            o_FLIP_32H, 
    output  wire            o_FLIP_16H, 
    output  wire            o_FLIP_8H,  
    output  wire            o_FLIP_4H,  
    output  wire            o_FLIP_2H,
    output  wire            o_FLIP_1H,

    output  wire            o_FLIP_128V,
    output  wire            o_FLIP_64V,
    output  wire            o_FLIP_32V,
    output  wire            o_FLIP_16V,
    output  wire            o_FLIP_8V, 
    output  wire            o_FLIP_4V, 
    output  wire            o_FLIP_2V,
    output  wire            o_FLIP_1V,

    output  reg             o_VCLK = 1'b0,

    output  reg             o_FRAMEPARITY = 1'b0,

    output  wire            o_VSYNC_n,
    output  wire            o_CSYNC_n
);


reg             __REF_DMA_n;



///////////////////////////////////////////////////////////
//////  PIXEL COUNTER/BLANKING/SYNC/DMA
////

reg     [8:0]   horizontal_counter = 9'd511;
assign  {
            o_ABS_256H, 
            o_ABS_128H, 
            o_ABS_64H, 
            o_ABS_32H, 
            o_ABS_16H, 
            o_ABS_8H,  
            o_ABS_4H,  
            o_ABS_2H,
            o_ABS_1H
        } = horizontal_counter;
assign  {
            o_FLIP_128H, 
            o_FLIP_64H, 
            o_FLIP_32H, 
            o_FLIP_16H, 
            o_FLIP_8H,  
            o_FLIP_4H,  
            o_FLIP_2H,
            o_FLIP_1H
        } = horizontal_counter[7:0] ^ {8{i_HFLIP}};
assign  o_HBLANK_n = horizontal_counter[8];

reg     [8:0]   vertical_counter = 9'd248;
assign  {
            o_ABS_128V, 
            o_ABS_64V, 
            o_ABS_32V, 
            o_ABS_16V, 
            o_ABS_8V,  
            o_ABS_4V,  
            o_ABS_2V,
            o_ABS_1V
        } = vertical_counter[7:0];

assign  {
            o_FLIP_128V, 
            o_FLIP_64V, 
            o_FLIP_32V, 
            o_FLIP_16V, 
            o_FLIP_8V,  
            o_FLIP_4V,  
            o_FLIP_2V,
            o_FLIP_1V
        } = vertical_counter[7:0] ^ {8{i_VFLIP}};

always @(posedge i_EMU_MCLK or negedge i_MRST_n)
begin
    if(!i_MRST_n) //asynchronous reset
    begin
        horizontal_counter <= 9'd128;
        vertical_counter <= 9'd248;

        o_VBLANK_n <= 1'b0;
        o_VBLANKH_n <= 1'b0;
        o_FRAMEPARITY <= 1'b0;
        __REF_DMA_n <= 1'b1;
    end
    else
    begin //count up
        if(!i_EMU_CLK6MPCEN_n)
        begin
            if(horizontal_counter < 9'd511) //h count up
            begin
                if(horizontal_counter == 9'd175) //v count up
                begin
                    if(vertical_counter < 9'd511)
                    begin
                        //VBLANK
                        if(vertical_counter > 9'd494 || vertical_counter < 9'd271)
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
                        if(vertical_counter > 9'd478 && vertical_counter < 9'd495)
                        begin
                            __REF_DMA_n <= 1'b0;
                        end
                        else
                        begin
                            __REF_DMA_n <= 1'b1;
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

endmodule