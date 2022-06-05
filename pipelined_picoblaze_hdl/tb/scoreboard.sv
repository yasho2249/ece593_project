/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Scoreboard module 

*/


class scoreboard

    mailbox mon_scb;

    function new(mailbox mon_scb);
        this.mon_scb = mon_scb;
    endfunction

    task main;
        transaction txn;
        forever begin
            mon_scb.get(txn);
            
        end
endclass : scoreboard