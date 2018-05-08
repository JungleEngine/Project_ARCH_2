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
add wave -position end  sim:/processor/REGISTER_FILE/R2_OUT_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R3_OUT_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R4_OUT_DATA
add wave -position end  sim:/processor/REGISTER_FILE/R5_OUT_DATA

mem load -filltype value -filldata {0111010000000001 } -fillradix binary /processor/INST_MEMORY/RAM(0)
mem load -filltype value -filldata {0000000000000111 } -fillradix binary /processor/INST_MEMORY/RAM(1)
mem load -filltype value -filldata {0111010000000010 } -fillradix binary /processor/INST_MEMORY/RAM(2)
mem load -filltype value -filldata {0000000000000110 } -fillradix binary /processor/INST_MEMORY/RAM(3)
mem load -filltype value -filldata {0111010000000000 } -fillradix binary /processor/INST_MEMORY/RAM(4)
mem load -filltype value -filldata {0000000000000101 } -fillradix binary /processor/INST_MEMORY/RAM(5)
mem load -filltype value -filldata {0111010000000100 } -fillradix binary /processor/INST_MEMORY/RAM(6)
mem load -filltype value -filldata {0000000000001010 } -fillradix binary /processor/INST_MEMORY/RAM(7)
mem load -filltype value -filldata {0000100000010001 } -fillradix binary /processor/INST_MEMORY/RAM(8)
mem load -filltype value -filldata {0001100000000010 } -fillradix binary /processor/INST_MEMORY/RAM(9)
mem load -filltype value -filldata {0001000000000100 } -fillradix binary /processor/INST_MEMORY/RAM(10)
mem load -filltype value -filldata {0000010000001011 } -fillradix binary /processor/INST_MEMORY/RAM(11)
mem load -filltype value -filldata {0001010000010001 } -fillradix binary /processor/INST_MEMORY/RAM(12)
mem load -filltype value -filldata {0010010000001000 } -fillradix binary /processor/INST_MEMORY/RAM(13)
mem load -filltype value -filldata {0000110000010001 } -fillradix binary /processor/INST_MEMORY/RAM(14)

	
	force -freeze sim:/processor/INTERRUPT_PIN 0 0
	force -freeze sim:/processor/CLK 1 0, 0 {50 ps} -r 100
	force -freeze sim:/processor/RST 1 0
	run

	force -freeze sim:/processor/RST 0 0
	run
run


