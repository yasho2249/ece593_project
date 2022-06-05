/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Environment class top for RojoBlaze 
*/


`include "environment.sv"

program test(intf intf);
   
    environment env;
   
    initial begin
        env = new(intf);
        env.gen.rep_count = 10; 
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

endmodule
