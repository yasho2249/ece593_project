
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
        wait(gen.rep_count == driv.txn_count);
    endtask

    task run;
        pre_test();
        test();
        post_test();
        $finish;
    endtask

endclass
