/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Driver Class for RojoBlaze 
*/

`include "transaction.sv"

interface intf(input logic clk, reset);
   
  //declaring the signals
    logic [5:0] opcode;
    logic [3:0] sx, sy, constant; 
    logic [17:0] instr;
   
endinterface

class driver;


    int txn_count;
    // virtual interface
    virtual intf vif;

    // mailbox
    mailbox gen_driv;

    function new(virtual intf vif, mailbox gen_driv);
        this.vif = vif;
        this.gen_driv = gen_driv;
    endfunction

    //reset task, initialize all interface values 
    task reset;
        wait(vif.reset);
        $display("DRIVER RESET INITIATE");
        vif.opcode = 0;
        vif.sx = 0;
        vif.sy = 0;
        vif.instr = 0;
        wait(!vif.reset);
        $display("DRIVER RESET END");
    endtask

    // main driver task
    task main;
 	
        forever begin
	    transaction txn;
            gen_driv.get(txn);
            @(posedge vif.clk);
            vif.opcode = txn.opcode;
            vif.sx = txn.sx;
            vif.sy =  txn.sy;
            vif.instr = txn.instr;
            @(posedge vif.clk);
            /*repeat (1) begin
                txn.write_mem(test_name_extention);
            end*/
            txn_count++;
        end
    endtask

endclass
