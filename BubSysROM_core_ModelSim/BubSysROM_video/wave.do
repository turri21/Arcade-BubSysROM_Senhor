onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /BubSysROM_video_tb/main/i_EMU_MCLK
add wave -noupdate /BubSysROM_video_tb/main/__REF_CLK9M
add wave -noupdate /BubSysROM_video_tb/main/__REF_CLK6M
add wave -noupdate -radix unsigned -childformat {{{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[8]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[7]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[6]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[5]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[4]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[3]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[2]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[1]} -radix unsigned} {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[0]} -radix unsigned}} -subitemconfig {{/BubSysROM_video_tb/main/K005292_main/horizontal_counter[8]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[7]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[6]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[5]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[4]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[3]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[2]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[1]} {-height 15 -radix unsigned} {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[0]} {-height 15 -radix unsigned}} /BubSysROM_video_tb/main/K005292_main/horizontal_counter
add wave -noupdate -radix unsigned {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[2]}
add wave -noupdate -radix unsigned {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[1]}
add wave -noupdate -radix unsigned {/BubSysROM_video_tb/main/K005292_main/horizontal_counter[0]}
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_VCLK
add wave -noupdate -radix unsigned /BubSysROM_video_tb/main/K005292_main/vertical_counter
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_HBLANK_n
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_VBLANK_n
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_VBLANKH_n
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_FRAMEPARITY
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_DMA_n
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_VSYNC_n
add wave -noupdate /BubSysROM_video_tb/main/K005292_main/o_CSYNC_n
add wave -noupdate /BubSysROM_video_tb/main/TIME1
add wave -noupdate /BubSysROM_video_tb/main/TIME2
add wave -noupdate /BubSysROM_video_tb/main/CHAMPX
add wave -noupdate /BubSysROM_video_tb/main/VRTIME
add wave -noupdate /BubSysROM_video_tb/main/OBJCLRWE
add wave -noupdate /BubSysROM_video_tb/main/OBJRW
add wave -noupdate /BubSysROM_video_tb/main/OBJCLR
add wave -noupdate /BubSysROM_video_tb/main/BLK
add wave -noupdate -radix hexadecimal -childformat {{{/BubSysROM_video_tb/main/scrollram_addr[10]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[9]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[8]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[7]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[6]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[5]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[4]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[3]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[2]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[1]} -radix hexadecimal} {{/BubSysROM_video_tb/main/scrollram_addr[0]} -radix hexadecimal}} -subitemconfig {{/BubSysROM_video_tb/main/scrollram_addr[10]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[9]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[8]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[7]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[6]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[5]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[4]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[3]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[2]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[1]} {-height 15 -radix hexadecimal} {/BubSysROM_video_tb/main/scrollram_addr[0]} {-height 15 -radix hexadecimal}} /BubSysROM_video_tb/main/scrollram_addr
add wave -noupdate -radix unsigned /BubSysROM_video_tb/main/scrollram_dout
add wave -noupdate -radix unsigned /BubSysROM_video_tb/main/K005291_main/TMA_HSCROLL_VALUE
add wave -noupdate /BubSysROM_video_tb/main/K005291_main/o_SHIFTA1
add wave -noupdate /BubSysROM_video_tb/main/K005291_main/o_SHIFTA2
add wave -noupdate -radix unsigned /BubSysROM_video_tb/main/K005291_main/TMB_HSCROLL_VALUE
add wave -noupdate /BubSysROM_video_tb/main/K005291_main/o_SHIFTB
add wave -noupdate -radix unsigned /BubSysROM_video_tb/main/K005291_main/TMAB_VSCROLL_VALUE
add wave -noupdate -radix hexadecimal /BubSysROM_video_tb/main/K005291_main/o_VRAMADDR
add wave -noupdate -radix hexadecimal /BubSysROM_video_tb/main/tile_code
add wave -noupdate /BubSysROM_video_tb/main/VVFF
add wave -noupdate -radix hexadecimal /BubSysROM_video_tb/main/K005291_main/o_TILELINEADDR
add wave -noupdate -radix hexadecimal /BubSysROM_video_tb/main/__REF_VCA_ORIGINAL
add wave -noupdate /BubSysROM_video_tb/main/charram_ras_n
add wave -noupdate /BubSysROM_video_tb/main/charram_cas_n
add wave -noupdate /BubSysROM_video_tb/main/VCA
add wave -noupdate -radix hexadecimal /BubSysROM_video_tb/main/PR
add wave -noupdate /BubSysROM_video_tb/main/VHFF
add wave -noupdate -radix unsigned /BubSysROM_video_tb/main/VC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {537190 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 179
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
WaveRestoreZoom {536820 ns} {539010 ns}
