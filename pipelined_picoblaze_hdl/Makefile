
#####################################################################
#	Grp 3: Yashodhan Wagle (ywagle@pdx.edu), Supreet Gulavani (sg7@pdx.edu) and Ramaa Potnis (rgp2@pdx.edu)
#	ECE 593 Final Project 
# 			Testbench development for Rojoblaze
#	Makefile for building the design and testbench
#			Add Instructions here
####################################################################

# Target
TARGET		:= picoblaze_hdl

# Directories for source files and builds
SRC_DIR 	:= duv
TB_DIR		:= tb
BUILD_DIR 	:= work transcript *~ vsim.wlf *.log dgs.dbg dmslogdir covhtmlreport

# sources 
SRCS	:= $(wildcard $(SRC_DIR)/*.sv)
TBS		:= $(wildcard $(TB_DIR)/*.sv)

# build recipies
all: setup compile opt $(TARGET)

setup:
		vlib work
		vmap work work

compile:
		vlog -coveropt 3 +cover=sbfec +acc duv/kcpsmx3_inc.sv $(SRCS) $(TBS)

#opt:
#		#vopt top -o top_optimized +acc

release:
		vsim -coverage -vopt work.alt_rojo_tb -c -do "coverage save -onexit -directive -cvg -codeAll func_cov; run -all" 

testcases:
		vsim -coverage -vopt work.top -c -do "coverage save -onexit -directive -cvg -codeAll func_cov; run -all; quit" 
		mv *.mem duv/

report:
		vcover report -verbose func_cov > report_func_cov.txt

html:
		vcover report -html func_cov

build: all 

.PHONY: all clean setup compile opt release report html info testcases

.DEFAULT_GOAL	:= build

clean:
		rm -rf $(BUILD_DIR) $(TARGET) duv/add_test.mem
		@echo "Cleanup done!"

info:
	@echo "Application:" $(TARGET)
	@echo "Design under Test:" $(SRCS)
	@echo "Testbench:" $(TBS)
