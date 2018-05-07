vsim work.execute

#test the ALU
add wave -position insertpoint  \
sim:/execute/ALU/A
add wave -position insertpoint  \
sim:/execute/ALU/B
add wave -position insertpoint  \
sim:/execute/ALU/SEL
add wave -position insertpoint  \
sim:/execute/ALU/F_SRC
add wave -position insertpoint  \
sim:/execute/ALU/F_DST


