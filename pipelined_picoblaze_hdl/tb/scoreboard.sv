/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Scoreboard module 

*/


class Scoreboard
    virtual rojo_bfm bfm;

    function new (virtual rojo_bfm b);
    bfm = b;
    endfunction : new

    //writing a task for the execute stage
    //will add more such tasks for all the stages
    task exec();
     int known_result;
     forever begin : self_check
        @(posedge bfm.done)
            #5;
            case (bfm.opcode)
                add_op :known_result = bfm.A + bfm.B;
                sub_op :known_result = bfm.A - bfm.B;
                or_op :known_result = bfm.A | bfm.B;
                and_op :known_result = bfm.A & bfm.B;
                xor_op :known_result = bfm.A ^ bfm.B;
                //adding all the operations
            endcase

        //if the operation is not performed as per what is intended, throw an error
        if(known_result != bfm.result)
         $error("Operation FAILED: A = %0h B = %0h OPCODE = %s RESULT = %0h", bfm.A, bfm.B, bfm.opcode, bfm.rsult);

     end : self_check
    endtask : exec

endclass : scoreboard

