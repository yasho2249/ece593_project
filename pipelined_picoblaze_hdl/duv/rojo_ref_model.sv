/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Reference model implementing the required fucntionality of the design

*/


module rojo_ref_model(
    input        [7:0]              in_port,        ///< Port input
    input                           interrupt,      ///< Interrupt request
    input                           reset,          ///< Reset input
    input                           clk             ///< Clock input
    output logic [7:0]              port_id,        ///< Port address.
    output logic                    write_strobe,   ///< Port output strobe
    output logic [7:0]              out_port,       ///< Port output
    output logic                    read_strobe,    ///< Port input strobe
    output logic                    interrupt_ack,  ///< Interrupt acknowledge
);

// what all regs and datastructs to create 
// INT_ENABLE
// registers named s[x]. should be unpacked array
// flag registers
// temp_reg which was created for TEST instruction 
// PORT_ID and PORT_VALUE for input and output instr
// mem array for scratch pad mem. should be byte type fixed array
// pc

bit [7:0] s [16];           // Registers
bit carry_flag, zero_flag;  // Carry and Zero flag
bit [7:0] temp_reg;         // Temp register used for COMPARE nad other instructions
bit INT_ENABLE;             // Interrupt Enable register
bit [9:0] pc;               // Program Counter 
//byte mem [64];                


kcpsmx_scratch scratch_mem(
    .address(scratch_address),
    .write_enable(scratch_write_enable),
    .data_in(scratch_data_in),
    .data_out(scratch_data_out),
    .reset(reset),
    .clk(clk)
);


case (instruction)
    // JUMP
    18'b11010xxxxxxxxxxxxx: begin
                            case (instruction)
                            // Conditional ZERO high JUMP
                            18'b11010100xxxxxxxxxx: begin
                                if (zero_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Conditional ZERO low JUMP
                            18'b11010101xxxxxxxxxx: begin
                                if (!zero_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Conditional CARRY high JUMP
                            18'b11010110xxxxxxxxxx: begin
                                if (carry_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Conditional CARRY low JUMP
                            18'b11010111xxxxxxxxxx: begin
                                if (!carry_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Unconditional
                            18'b110100xxxxxxxxxxxx: begin
                                pc = instruction[9:0];
                            end
                            endcase
                            end
    // CALL
    // CHECK THIS. MAYBE FIX IT
    18'b11000xxxxxxxxxxxxx: begin
                            case (instruction)
                            // Conditional ZERO high CALL
                            18'b11000100xxxxxxxxxx: begin
                                if (zero_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Conditional ZERO low CALL
                            18'b11000101xxxxxxxxxx: begin
                                if (!zero_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Conditional CARRY high CALL
                            18'b11000110xxxxxxxxxx: begin
                                if (carry_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Conditional CARRY low CALL
                            18'b11000111xxxxxxxxxx: begin
                                if (!carry_flag) pc = instruction[9:0];
                                else pc = pc + 1;
                            end
                            // Unconditional
                            18'b110000xxxxxxxxxxxx: begin
                                pc = instruction[9:0];
                            end
                            endcase
                            end
    // RETURN 

    // RETURNI

    // ENABLE INTERRUPT 
    18'b111100000000000001: begin
                            INT_ENABLE = 1'b1;
                            end
    
    // DISABLE INTERRUPT
    18'b111100000000000000: begin
                            INT_ENABLE = 1'b0;
                            end

    // LOAD 
    18'b00000xxxxxxxxxxxxx: begin
                            case (instruction)
                            // LOAD constant
                            18'b000000xxxxxxxxxxxx: begin 
                                                    s[instruction[11:8]] = instruction[7:0];
                                                    end
                            // LOAD from another register s[y]
                            18'b000001xxxxxxxx0000: begin 
                                                    s[instruction[11:8]] = s[instruction[7:4]];
                                                    end
                            endcase
                            end
    // AND
    18'b00101xxxxxxxxxxxxx: begin
                            case (instruction)
                                // AND with const
                                18'b001010xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] & instruction[7:0];
                                                        carry_flag = 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                // AND with another reg value
                                18'b001011xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] & s[instruction[7:4]];
                                                        carry_flag = 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                            endcase
                            end
    // OR
    18'b00110xxxxxxxxxxxxx: begin
                            case (instruction)
                                // OR with const
                                18'b001100xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] | instruction[7:0];
                                                        carry_flag = 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end 
                                // OR with const
                                18'b001101xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] | s[instruction[7:4]];
                                                        carry_flag = 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                default: 
                            endcase
                            end
    // XOR
    18'b00111xxxxxxxxxxxxx: begin
                            case (instruction)
                                // XOR with const
                                18'b001110xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] ^ instruction[7:0];
                                                        carry_flag = 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end 
                                // XOR with const
                                18'b001111xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] ^ s[instruction[7:4]];
                                                        carry_flag = 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                default: 
                            endcase
                            end
    // TEST
    18'b01001xxxxxxxxxxxxx: begin
                            case (instruction)
                                18'b010010xxxxxxxxxxxx: begin
                                                        temp_reg = s[instruction[11:8]] & instruction[7:0];
                                                        carry_flag = ^temp_reg ? 1'b1 : 1'b0;
                                                        zero_flag = temp_reg ? 1'b0 : 1'b1;
                                                        end 
                                18'b010011xxxxxxxx0000: begin
                                                        temp_reg = s[instruction[11:8]] & s[instruction[7:4]];
                                                        carry_flag = ^temp_reg ? 1'b1 : 1'b0;
                                                        zero_flag = temp_reg ? 1'b0 : 1'b1;
                                                        end 
                                default: 
                            endcase
                            end
    // ADD
    18'b01100xxxxxxxxxxxxx: begin
                            case (instruction)
                                // ADD with const
                                18'b011000xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] + instruction[7:0];
                                                        carry_flag = s[instruction[11:8]] > 8'hFF ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                // ADD with another reg value
                                18'b011001xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] + s[instruction[7:4]];
                                                        carry_flag = s[instruction[11:8]] > 8'hFF ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                            endcase
                            end
    // ADDCY
    18'b01101xxxxxxxxxxxxx: begin
                            case (instruction)
                                // ADD with const and carry
                                18'b011010xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] + instruction[7:0] + carry_flag;
                                                        carry_flag = s[instruction[11:8]] > 8'hFF ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                // ADD with another reg value and carry
                                18'b011011xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] + s[instruction[7:4]] + carry_flag;
                                                        carry_flag = s[instruction[11:8]] > 8'hFF ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                            endcase
                            end
    // SUB
    18'b01110xxxxxxxxxxxxx: begin
                            case (instruction)
                                // SUB with const
                                18'b011100xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] - instruction[7:0];
                                                        carry_flag = s[instruction[11:8]] < instruction[7:0] ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                // SUB with another reg value
                                18'b011101xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] - s[instruction[7:4]];
                                                        carry_flag = s[instruction[11:8]] < instruction[7:0] ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                            endcase
                            end
    // SUBCY
    18'b01111xxxxxxxxxxxxx: begin
                            case (instruction)
                                // SUB with const and carry
                                18'b011110xxxxxxxxxxxx: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] - instruction[7:0] - carry_flag;
                                                        carry_flag = s[instruction[11:8]] < (instruction[7:0] + carry_flag) ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                                // SUB with another reg value and carry
                                18'b011111xxxxxxxx0000: begin
                                                        s[instruction[11:8]] = s[instruction[11:8]] - s[instruction[7:4]] - carry_flag;
                                                        carry_flag = s[instruction[11:8]] < (instruction[7:0] + carry_flag) ? 1'b1 : 1'b0;
                                                        zero_flag = s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                        end
                            endcase
                            end
    // COMPARE
    18'b01010xxxxxxxxxxxxx: begin
                            case (instruction)
                                // COMPARE with const
                                18'b010100xxxxxxxxxxxx: begin
                                                        temp_reg = s[instruction[11:8]] - instruction[7:0];
                                                        carry_flag = s[instruction[11:8]] < instruction[7:0] ? 1'b1 : 1'b0;
                                                        zero_flag = temp_reg ? 1'b0 : 1'b1;
                                                        end
                                // COMPARE with another reg value
                                18'b010101xxxxxxxx0000: begin
                                                        temp_reg = s[instruction[11:8]] - s[instruction[7:4]];
                                                        carry_flag = s[instruction[11:8]] < instruction[7:0] ? 1'b1 : 1'b0;
                                                        zero_flag = temp_reg ? 1'b0 : 1'b1;
                                                        end
                            endcase
                            end
    // Shifts and Rotates
    18'b100000xxxx0000xxxx: begin
                            case (instruction)
                                // Right
                                18'b100000xxxx00001xxx: begin
                                                        case (instruction)
                                                            // RR
                                                            18'b100000xxxx00001100: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][0] , s[instruction[11:8]][7:1]};
                                                                                    carry_flag = s[instruction[11:8]][0];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                            // SR0
                                                            18'b100000xxxx00001110: begin
                                                                                    s[instruction[11:8]] = {1'b0 , s[instruction[11:8]][7:1]};
                                                                                    carry_flag = s[instruction[11:8]][0];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                            // SR1
                                                            18'b100000xxxx00001111: begin
                                                                                    s[instruction[11:8]] = {1'b1 , s[instruction[11:8]][7:1]};
                                                                                    carry_flag = s[instruction[11:8]][0];
                                                                                    zero_flag = 1'b0;
                                                                                    end
                                                            //SRX
                                                            18'b100000xxxx00001010: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][7] , s[instruction[11:8]][7:1]};
                                                                                    carry_flag = s[instruction[11:8]][0];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                            // SRA
                                                            18'b100000xxxx00001000: begin
                                                                                    s[instruction[11:8]] = {carry_flag , s[instruction[11:8]][7:1]};
                                                                                    carry_flag = s[instruction[11:8]][0];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                        endcase
                                                        end 
                                // Left
                                18'b100000xxxx00000xxx: begin
                                                        case (instruction)
                                                            // RL
                                                            18'b100000xxxx00000010: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][6:0], s[instruction[11:8]][7]};
                                                                                    carry_flag = s[instruction[11:8]][7];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                            // SL0
                                                            18'b100000xxxx00000110: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][6:0], 1'b0};
                                                                                    carry_flag = s[instruction[11:8]][7];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                            // SL1
                                                            18'b100000xxxx00000111: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][6:0], 1;b1};
                                                                                    carry_flag = s[instruction[11:8]][7];
                                                                                    zero_flag =  1'b0;
                                                                                    end
                                                            // SLX
                                                            18'b100000xxxx00000100: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][6:0], s[instruction[11:8]][0]};
                                                                                    carry_flag = s[instruction[11:8]][7];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                            // SLA
                                                            18'b100000xxxx00000000: begin
                                                                                    s[instruction[11:8]] = {s[instruction[11:8]][6:0], carry_flag};
                                                                                    carry_flag = s[instruction[11:8]][7];
                                                                                    zero_flag =  s[instruction[11:8]] ? 1'b0 : 1'b1;
                                                                                    end
                                                        endcase
                                                        end
                            endcase
                            end
    // OUTPUT
    18'b10110xxxxxxxxxxxxx: begin
                            case (instruction)
                                // OUTPUT PP. PP hehehehe
                                18'b101100xxxxxxxxxxxx: begin
                                                        PORT_ID = instruction[7:0];
                                                        PORT_VALUE = s[instruction[11:8]];
                                                        end 
                                // OUTPUT (sY)
                                18'b101101xxxxxxxx0000: begin
                                                        PORT_ID = s[instruction[7:4]];
                                                        PORT_VALUE = s[instruction[11:8]];
                                                        end 
                            endcase
                            end
    // INPUT
    18'b00010xxxxxxxxxxxxx: begin
                            case (instruction)
                                // INPUT PP. niceeeee
                                18'b000100xxxxxxxxxxxx: begin
                                                        PORT_ID = instruction[7:0];
                                                        s[instruction[11:8]] = PORT_VALUE;
                                                        end 
                                // INPUT (sY)
                                18'b000101xxxxxxxx0000: begin
                                                        PORT_ID = s[instruction[7:4]];
                                                        s[instruction[11:8]] = PORT_VALUE;
                                                        end 
                            endcase
                            end
    // STORE 
    18'b10111xxxxxxxxxxxxx: begin
                            case (instruction)
                                // STORE PP
                                18'b101110xxxx00xxxxxx: begin
                                                        scratch_address = instruction[5:0];
                                                        scratch_write_enable = 1'b1;
                                                        scratch_data_in = s[instruction[11:8]];
                                                        scratch_data_out = z;
                                                        end
                                // STORE (sY)
                                18'b101111xxxxxxxx0000: begin
                                                        scratch_address = s[instruction[7:4]];
                                                        scratch_write_enable = 1'b1;
                                                        scratch_data_in = s[instruction[11:8]];
                                                        scratch_data_out = z;
                                                        end
                            endcase
                            end
    // FETCH
    18'b00011xxxxxxxxxxxxx: begin
                            case (instruction)
                                // FETCH PP heheheheh
                                18'b000110xxxx00xxxxxx: begin
                                                        s[instruction[11:8]] = scratch_mem[instruction[5:0]];
                                                        end
                                // FETCH (sY)
                                18'b000110xxxx00xxxxxx: begin
                                                        s[instruction[11:8]] = scratch_mem[s[instruction[7:4]]];
                                                        end
                            endcase
                            end
    default: fatal ("Invalid opcode")
endcase

endmodule