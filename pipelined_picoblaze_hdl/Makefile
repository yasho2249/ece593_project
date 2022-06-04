
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
RNDT_FL		:= tb/coverage.sv tb/rojo_bfm.sv
BUILD_DIR 	:= work transcript *~ vsim.wlf *.log dgs.dbg dmslogdir covhtmlreport

# sources 
SRCS	:= $(wildcard $(SRC_DIR)/*.sv)
TBS	:= $(filter-out $(RNDT_FL), $(wildcard $(TB_DIR)/*.sv))

# build recipies
all: setup compile opt $(TARGET)

setup:
		vlib work
		vmap work work

compile:
		vlog -coveropt 3 +cover=sbfec +acc duv/kcpsmx3_inc.sv $(SRCS) $(TBS)

#opt:
#		#vopt top -o top_optimized +acc

instruction:
		vsim -coverage -vopt work.alt_rojo_tb -c -do "coverage save -onexit -directive -cvg -codeAll func_cov; run -all; quit" 

tests:
		vsim -coverage -vopt work.env_top -c -do "coverage save -onexit -directive -cvg -codeAll func_cov; run -all; quit"

release:
		vsim -coverage -vopt work.top -c -do "coverage save -onexit -directive -cvg -codeAll func_cov; run -all; quit" 

report:
		vcover report -verbose func_cov > report_func_cov.txt

html:
		vcover report -html func_cov

build: all 

.PHONY: all clean setup compile opt release report html info tests instruction

.DEFAULT_GOAL	:= build

clean:
		rm -rf $(BUILD_DIR) $(TARGET) *.mem
		@echo "Cleanup done!"

info:
	@echo "Application:" $(TARGET)
	@echo "Design under Test:" $(SRCS)
	@echo "Testbench:" $(TBS)
	@echo "make clean: cleans the builds"
	@echo "make setup: sets up the work lib"
	@echo "make compile: compiles the files in duv/ and tb/"
	@echo "make tests: builds .mem for the DUV"
	@echo "make instruction: build instructions to be executed"
	@echo "make release: runs the design unit"
	@echo "make report: makes functional coverage report in txt format"
	@echo "make html: makes GUI coverage report"
