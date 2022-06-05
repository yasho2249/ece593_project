

//import transaction::*;
`include "transaction.sv"

class generator;
    
    // transaction class declaration
    rand transaction txn;

    // mailbox 
   mailbox gen_driv;

    // number of items to generate
    int rep_count;

    // end of transaction generation
    event ended;

    // constructor
    function new(mailbox gen_driv);
        this.gen_driv = gen_driv;
    endfunction

    //
    task main();
        repeat (1024) begin
            txn = new();
            if(!txn.randomize()) $fatal("txn randomization failed");
            gen_driv.put(txn);
        end
        -> ended;
    endtask

endclass
