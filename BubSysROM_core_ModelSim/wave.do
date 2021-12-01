onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_HBLANK_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_VBLANK_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_VBLANKH_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/FSM_RESUME
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/FSM_SUSPEND
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/new_vblank_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_DMA_n
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/objtable_addr
add wave -noupdate /BubSysROM_top_tb/main/video_main/objtable_wr
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/OBJ
add wave -noupdate /BubSysROM_top_tb/main/video_main/__REF_CLK6M
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_ABS_4H
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_ABS_2H
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/i_ABS_1H
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/x_out_of_screen
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/y_out_of_screen
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005295_main/ypos_cnt_dly_n[1]}
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/evenbuffer_xpos_counter
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/oddbuffer_xpos_counter
add wave -noupdate {/BubSysROM_top_tb/main/video_main/K005295_main/ypos_cnt_dly_n[2]}
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/buffer_ypos_counter
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/drawing_status
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/sprite_engine_state
add wave -noupdate -radix hexadecimal /BubSysROM_top_tb/main/video_main/objtable_dout
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/o_ORA
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/o_WRTIME2
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/o_PIXELLATCH_WAIT_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hsize_parity
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_rst_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_cnt_n
add wave -noupdate -radix binary -radixshowbase 0 /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_acc
add wave -noupdate -radix binary -childformat {{{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[10]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[9]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[8]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[7]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[6]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[5]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[4]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[3]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[2]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[1]} -radix unsigned} {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[0]} -radix unsigned}} -subitemconfig {{/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[10]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[9]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[8]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[7]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[6]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[5]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[4]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[3]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[2]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[1]} {-height 15 -radix unsigned} {/BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval[0]} {-height 15 -radix unsigned}} /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_nextval
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/hline_complete
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/hzoom_tileline_num
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/vtile_complete_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/vzoom_cnt_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005295_main/vzoom_rst_n
add wave -noupdate -radix binary /BubSysROM_top_tb/main/video_main/K005295_main/vzoom_acc
add wave -noupdate -radix binary /BubSysROM_top_tb/main/video_main/K005295_main/vzoom_nextval
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005295_main/vzoom_vtile_num
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6411670 ns} 0}
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
WaveRestoreZoom {6330360 ns} {6458360 ns}
