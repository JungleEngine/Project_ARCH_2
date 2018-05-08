vsim work.execute

#test the ALU
#add wave -position insertpoint  \
#sim:/execute/ALU/A
#add wave -position insertpoint  \
#sim:/execute/ALU/B
#add wave -position insertpoint  \
#sim:/execute/ALU/SEL
#add wave -position insertpoint  \
#sim:/execute/ALU/F_SRC
#add wave -position insertpoint  \
#sim:/execute/ALU/F_DST


add wave -position insertpoint  \
sim:/execute/ALU_Operands_Selection_Unit/dst_in_mem_buffer_src \
sim:/execute/ALU_Operands_Selection_Unit/dst_in_mem_buffer_dst \
sim:/execute/ALU_Operands_Selection_Unit/src_in_mem_buffer_src \
sim:/execute/ALU_Operands_Selection_Unit/src_in_mem_buffer_dst \
sim:/execute/ALU_Operands_Selection_Unit/src_in_wb_buffer_src \
sim:/execute/ALU_Operands_Selection_Unit/src_in_wb_buffer_dst \
sim:/execute/ALU_Operands_Selection_Unit/dst_in_wb_buffer_src \
sim:/execute/ALU_Operands_Selection_Unit/dst_in_wb_buffer_dst \
sim:/execute/ALU_Operands_Selection_Unit/dst_in_immediate
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_in_mem_buffer_src 0 0
# ** Warning: (vsim-8780) Forcing /execute/dst_in_mem_buffer_src as root of /execute/ALU_Operands_Selection_Unit/dst_in_mem_buffer_src specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_in_mem_buffer_dst 0 0
# ** Warning: (vsim-8780) Forcing /execute/dst_in_mem_buffer_dst as root of /execute/ALU_Operands_Selection_Unit/dst_in_mem_buffer_dst specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/src_in_mem_buffer_src 0 0
# ** Warning: (vsim-8780) Forcing /execute/src_in_mem_buffer_src as root of /execute/ALU_Operands_Selection_Unit/src_in_mem_buffer_src specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/src_in_mem_buffer_dst 0 0
# ** Warning: (vsim-8780) Forcing /execute/src_in_mem_buffer_dst as root of /execute/ALU_Operands_Selection_Unit/src_in_mem_buffer_dst specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/src_in_wb_buffer_src 0 0
# ** Warning: (vsim-8780) Forcing /execute/src_in_wb_buffer_src as root of /execute/ALU_Operands_Selection_Unit/src_in_wb_buffer_src specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/src_in_wb_buffer_dst 0 0
# ** Warning: (vsim-8780) Forcing /execute/dst_in_wb_buffer_dst as root of /execute/ALU_Operands_Selection_Unit/src_in_wb_buffer_dst specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_in_wb_buffer_src 0 0
# ** Warning: (vsim-8780) Forcing /execute/dst_in_wb_buffer_src as root of /execute/ALU_Operands_Selection_Unit/dst_in_wb_buffer_src specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_in_wb_buffer_dst 0 0
# ** Warning: (vsim-8780) Forcing /execute/dst_in_wb_buffer_dst as root of /execute/ALU_Operands_Selection_Unit/dst_in_wb_buffer_dst specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_in_immediate 0 0
# ** Warning: (vsim-8780) Forcing /execute/dst_in_immediate as root of /execute/ALU_Operands_Selection_Unit/dst_in_immediate specified in the force.
add wave -position insertpoint  \
sim:/execute/ALU_Operands_Selection_Unit/dst_val_reg_file
add wave -position insertpoint  \
sim:/execute/ALU_Operands_Selection_Unit/src_val_reg_file
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_val_reg_file x\"0003\" 0
# ** Warning: (vsim-8780) Forcing /execute/dst_val_reg_file as root of /execute/ALU_Operands_Selection_Unit/dst_val_reg_file specified in the force.
force -freeze sim:/execute/ALU_Operands_Selection_Unit/src_val_reg_file x\"0001\" 0

add wave -position insertpoint  \
sim:/execute/opcode_alu_buffer
force -freeze sim:/execute/opcode_alu_buffer 00011 0
add wave -position end  sim:/execute/result_dst_val
add wave -position end  sim:/execute/result_src_val
force -freeze sim:/execute/ALU_Operands_Selection_Unit/src_val_reg_file 0000000000000011 0
force -freeze sim:/execute/ALU_Operands_Selection_Unit/dst_val_reg_file 0000000000000011 0
add wave -position end  sim:/execute/ALU/A
add wave -position end  sim:/execute/ALU/B
add wave -position end  sim:/execute/ALU/F_SRC
add wave -position end  sim:/execute/ALU/F_DST
add wave -position end  sim:/execute/ALU_Output_Selection_Unit/result_src
add wave -position end  sim:/execute/ALU_Output_Selection_Unit/result_dst
add wave -position end  sim:/execute/ALU/FLAG_REG
add wave -position insertpoint  \
sim:/execute/ALU_Output_Selection_Unit/buffered_SP_or_EA_unextended
force -freeze sim:/execute/ALU_Output_Selection_Unit/buffered_SP_or_EA_unextended 111111111 0
force -freeze sim:/execute/ALU/FLAG_REG 0000 0
add wave -position insertpoint  \
sim:/execute/src_val_reg_file
add wave -position insertpoint  \
sim:/execute/dst_val_reg_file
run
#noforce sim:/execute/ALU/FLAG_REG
run