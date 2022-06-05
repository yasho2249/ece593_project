/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Environment class for RojoBlaze 
*/

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"

class environment;

    generator gen;
    driver drv;
    mailbox gen_driv;
    virtual intf vif;

    function new(virtual intf vif);
        this.vif = vif;
        gen_driv =  new();
        gen = new(gen_driv);
        drv = new(vif, gen_driv);
    endfunction

    task pre_test();
        drv.reset();
    endtask;

    task test();
        fork    
            gen.main();
            drv.main();
        join_any
    endtask

    task post_test();
        wait(gen.ended.triggered);
        wait(gen.rep_count == drv.txn_count);
    endtask

    task run;
        pre_test();
        test();
        post_test();
        $finish;
    endtask

endclass
