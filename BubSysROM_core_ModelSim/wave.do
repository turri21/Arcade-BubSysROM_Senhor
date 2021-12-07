onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_HBLANK_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_VBLANK_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_VBLANKH_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/__REF_CLK6M
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_ABS_4H
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_ABS_2H
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_ABS_1H
add wave -noupdate /BubSysROM_top_tb/main/video_main/OBJCLR
add wave -noupdate /BubSysROM_top_tb/main/video_main/OBJWR
add wave -noupdate /BubSysROM_top_tb/main/video_main/OBJCLRWE
add wave -noupdate /BubSysROM_top_tb/main/video_main/CHAMPX
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/buffer_frame_parity
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/OBJ
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/ORA
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/objtable_addr
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/objtable_dout
add wave -noupdate /BubSysROM_top_tb/main/video_main/__REF_CLK6M
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/sprite_engine_state
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/drawing_status
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_acc
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005295_main/xpos_cnt_dly_n[1]}
add wave -noupdate -color {Blue Violet} -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/TILELINE_ADDR
add wave -noupdate -color {Blue Violet} -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/HLINE_ADDR
add wave -noupdate -color Cyan -radix unsigned -childformat {{{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[7]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[6]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[5]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[4]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[3]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[2]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[1]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[0]} -radix unsigned}} -subitemconfig {{/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[7]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[6]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[5]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[4]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[3]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[2]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[1]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter[0]} {-color Cyan -height 15 -radix unsigned}} /BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter
add wave -noupdate -color Cyan -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/oddbuffer_xpos_counter
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005295_main/ypos_cnt_dly_n[3]}
add wave -noupdate -color {Blue Violet} -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/VTILE_ADDR
add wave -noupdate -color Cyan -radix unsigned -childformat {{{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[7]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[6]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[5]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[4]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[3]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[2]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[1]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[0]} -radix unsigned}} -subitemconfig {{/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[7]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[6]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[5]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[4]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[3]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[2]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[1]} {-color Cyan -height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter[0]} {-color Cyan -height 15 -radix unsigned}} /BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/x_out_of_screen
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/y_out_of_screen
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hsize_parity
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/oddsize_wrtime0
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/evensize_wrtime0
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/o_PIXELLATCH_WAIT_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/CHAOV
add wave -noupdate -radix hexadecimal -childformat {{{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[13]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[12]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[11]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[10]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[9]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[8]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[7]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[6]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[5]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[4]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[3]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[2]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[1]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[0]} -radix hexadecimal}} -subitemconfig {{/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[13]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[12]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[11]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[10]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[9]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[8]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[7]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[6]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[5]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[4]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[3]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[2]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[1]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR[0]} {-height 15 -radix hexadecimal}} /BubSysROM_top_tb/main/video_main/K005295_main/CHARRAM_ADDR
add wave -noupdate -radix hexadecimal -childformat {{{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[13]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[12]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[11]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[10]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[9]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[8]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[7]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[6]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[5]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[4]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[3]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[2]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[1]} -radix hexadecimal} {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[0]} -radix hexadecimal}} -subitemconfig {{/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[13]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[12]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[11]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[10]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[9]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[8]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[7]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[6]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[5]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[4]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[3]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[2]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[1]} {-height 15 -radix hexadecimal} {/BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR[0]} {-height 15 -radix hexadecimal}} /BubSysROM_top_tb/main/video_main/CHARRAM_PX1/ADDR
add wave -noupdate /BubSysROM_top_tb/main/video_main/CHARRAM_PX3/i_RAS_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/CHARRAM_PX3/i_CAS_n
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/i_GFXDATA
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/i_TILELINELATCH_n
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/OBJ_TILELINELATCH
add wave -noupdate /BubSysROM_top_tb/main/video_main/COLORLATCH_n
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/OBJ_PALETTE
add wave -noupdate /BubSysROM_top_tb/main/video_main/__REF_CLK6M
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hsize_parity
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/pixellatch_wait_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/PIXELLATCH_WAIT_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/WRTIME2
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005294_main/wrtime2_dly[1]}
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_acc
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/PIXELSEL
add wave -noupdate -radix unsigned {/BubSysROM_top_tb/main/video_main/K005294_main/pixelsel_dly[3]}
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005294_main/pixellatch_n
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/OBJ_PIXEL_LATCHED
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/OBJ_PIXEL_UNLATCHED
add wave -noupdate -color Coral -radix unsigned /BubSysROM_top_tb/main/video_main/XPOS_D0
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/buffer_x_screencounter
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/buffer_y_screencounter
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005295_main/EVENBUFFER_ADDR
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005295_main/ODDBUFFER_ADDR
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/EVENBUF/ADDR
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/ODDBUF/ADDR
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005294_main/pixellatch_wait_dly[2]}
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005294_main/pixellatch_wait_dly[3]}
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_EMU_MCLK
add wave -noupdate -color Magenta -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/o_DA
add wave -noupdate -color Magenta -radix hexadecimal /BubSysROM_top_tb/main/video_main/K005294_main/o_DB
add wave -noupdate /BubSysROM_top_tb/main/video_main/objbuf_ras_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/OBJBUF_CAS
add wave -noupdate /BubSysROM_top_tb/main/video_main/objbuf_we_n
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/evenbuffer_din
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/oddbuffer_din
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/evenbuffer_dout
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/oddbuffer_dout
add wave -noupdate /BubSysROM_top_tb/main/video_main/evenbuffer_overwrite_disable
add wave -noupdate /BubSysROM_top_tb/main/video_main/oddbuffer_overwrite_disable
add wave -noupdate /BubSysROM_top_tb/main/video_main/i_EMU_MCLK
add wave -noupdate /BubSysROM_top_tb/main/video_main/__REF_CLK6M
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_1H
add wave -noupdate /BubSysROM_top_tb/main/video_main/o_BLK
add wave -noupdate /BubSysROM_top_tb/main/video_main/OBJWR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6539470 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {29998270 ns} {30000100 ns}
