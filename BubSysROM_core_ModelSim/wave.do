onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /BubSysROM_top_tb/main/video_main/__REF_CLK6M
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005292_main/horizontal_counter
add wave -noupdate -radix unsigned /BubSysROM_top_tb/main/video_main/K005292_main/vertical_counter
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_1H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_2H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_4H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_8H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_16H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_32H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_64H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_128H
add wave -noupdate /BubSysROM_top_tb/main/video_main/ABS_256H
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_HBLANK_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/hsync_clken_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/narrow_hsync_on_vsync_clken_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/vclk_clken_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/VCLK
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_1V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_2V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_4V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_8V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_16V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_32V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_64V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_ABS_128V
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_VBLANKH_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_VBLANK_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_FRAMEPARITY
add wave -noupdate /BubSysROM_top_tb/main/video_main/K005292_main/o_VSYNC_n
add wave -noupdate /BubSysROM_top_tb/main/video_main/CSYNC_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12893610 ns} 0}
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
WaveRestoreZoom {12854180 ns} {13007680 ns}
