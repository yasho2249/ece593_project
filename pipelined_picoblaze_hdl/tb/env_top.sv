
`include "environment.sv"

program test(intf intf);
   
    environment env;
   
    initial begin
        env = new(intf);
        env.gen.rep_count = 10; //if($value$plusargs("RUNS=%d", runs));;
        env.run();
    end

endprogram

module env_top;

  
    bit clk, reset;

    always #5 clk = ~clk;

    initial begin
        reset = 1;
        #5;
        reset = 0;
    end    

    intf i_intf(clk, reset);
    test t1(i_intf);

    /*ojo_bfm bfm(.clk(i_intf.clk),
                 .reset(i_intf.reset)
                );
    */
endmodule
