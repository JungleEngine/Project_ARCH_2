vsim work.processor

add wave -position end  sim:/processor/FETCH_DECODE_BUFFER/D
add wave -position end  sim:/processor/FETCH_DECODE_BUFFER/Q
add wave -position end  sim:/processor/DECODE_EXECUTE_BUFFER/D
add wave -position end  sim:/processor/DECODE_EXECUTE_BUFFER/Q
add wave -position end  sim:/processor/EXECUTE_MEMORY_BUFFER/D
add wave -position end  sim:/processor/EXECUTE_MEMORY_BUFFER/Q
add wave -position end  sim:/processor/MEMORY_WRITEBACK_BUFFER/D
add wave -position end  sim:/processor/MEMORY_WRITEBACK_BUFFER/Q
add wave -position end  sim:/processor/CLK
add wave -position end  sim:/processor/RST
add wave -position 4  sim:/processor/EXECUTE_STAGE/result_src_val
add wave -position 5  sim:/processor/EXECUTE_STAGE/result_dst_val
add wave -position end  sim:/processor/REGISTER_FILE/R1_IN_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R1_OUT_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R2_IN_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R2_OUT_DATA
add wave -position end  sim:/processor/WRITEBACK_STAGE/WB_SIGNALS
add wave -position end  sim:/processor/WRITEBACK_STAGE/RAM_VALUE_or_DST_RESULT
add wave -position end  sim:/processor/REGISTER_FILE/R0_OUT_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R1_OUT_DATA
	mem load -filltype value -filldata {0111010000000001 } -fillradix binary /processor/INST_MEMORY/RAM(0)
	# test loadm
	mem load -filltype value -filldata {0000000000000101 } -fillradix binary /processor/INST_MEMORY/RAM(1)
	mem load -filltype value -filldata {0111010000000010 } -fillradix binary /processor/INST_MEMORY/RAM(2)
	# test loadm
	mem load -filltype value -filldata {0000000000000111 } -fillradix binary /processor/INST_MEMORY/RAM(3)

	force -freeze sim:/processor/INTERRUPT_PIN 0 0
	force -freeze sim:/processor/CLK 1 0, 0 {50 ps} -r 100
	force -freeze sim:/processor/RST 1 0
	run

	force -freeze sim:/processor/RST 0 0
	run
run


