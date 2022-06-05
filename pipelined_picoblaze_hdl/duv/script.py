# Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
# ECE 593: Final Project
#         Testebench for verification of RojoBlaze
# Python Script to add the multiple mem files generated to create a variable to that runs the mem file in form of a test.sv file 

import sys
f = open("test.sv", "w")
tests_list = []
num_tests = int(sys.argv[1])
num_tests = int((num_tests / 1024) + 1)
for i in range(0, num_tests):
    tests_list.append(f"\"test{i}.mem\"")

test_string = ",".join(tests_list)

S =" `ifndef __MEM_TESTS_SV__\n`define __MEM_TESTS_SV__ \nstring memfile[] = '{" +  test_string + "\n};\n`endif"

f.write(S)
f.close()
