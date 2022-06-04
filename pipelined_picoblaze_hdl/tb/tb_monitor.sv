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
mailbox mbox;

//constructor
function new(virtual intf vif,mailbox mbox);
        this.vif = vif;
        this.mbox = mbox;
endfunction

task main;
        forever begin
endclass