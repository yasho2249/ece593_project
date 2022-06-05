f = open("test.sv", "w")
tests_list = []
for i in range(0, 10):
    tests_list.append(f"\"test{i}.mem\"")

test_string = ",".join(tests_list)

S =" `ifndef __MEM_TESTS_SV__\n`define __MEM_TESTS_SV__ \nstring memfile[] = '{" +  test_string + "\n};\n`endif"

f.write(S)
f.close()
