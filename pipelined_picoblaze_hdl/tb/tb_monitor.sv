/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Monitor module for sampling signals from the dut

*/

class Monitor

        // virtual interface
        virtual intf vif;
        
        // mailbox 
        mailbox mon_scb;

        //constructor
        function new(virtual intf vif,mailbox mon_scb);
                this.vif = vif;
                this.mon_scb = mon_scb;
        endfunction

        task main;
                forever begin
                transaction txn;
                txn = new();
                @(posedge vif.clk);
                txn.opcode = vif.opcode;
                txn.sx = vif.sx;
                txn.sy = vif.sy;
                txn.instr = vif.instr;
                @(posedge vif.clk);
                txn.write_mem();
                mon_scb.put(txn);
                $display("MONITOR");
                end
        endtask

endclass        