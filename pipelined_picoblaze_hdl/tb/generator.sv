/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Generator class for RojoBlaze 
*/

`include "transaction.sv"

class generator;
    
    string txn_type;

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
        int tests;
        int test_name_extention = 0;
        int test_files;
        int f;
        string filename;

        if ($value$plusargs ("NumberOfTests=%d", tests))
        test_files = (tests/1024) + 1;
        repeat (test_files) begin
            $sformat(filename, "test%0d.mem", test_name_extention);
		    f = $fopen(filename, "a");
            $fwrite(f, "@000\n");
            $fclose(f);
            repeat (1024) begin
                txn = new();
                txn.randomize();
            txn.write_mem(test_name_extention);
	        if(!txn.randomize()) $fatal("txn randomization failed");
                gen_driv.put(txn);
            end
        test_name_extention = test_name_extention + 1;
        end
        -> ended;
    endtask

endclass
