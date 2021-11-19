`timescale 10ns/10ns
module BubSysROM_top_tb;

reg             MCLK = 1'b0; //18.432MHz
reg             CLK18MCEN_n = 1'b0;

BubSysROM_top main
(
    .i_EMU_MCLK                     (MCLK                   )
);

always #1 MCLK = ~MCLK;

endmodule