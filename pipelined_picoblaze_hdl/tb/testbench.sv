/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

 TOP module for RojoBlaze 
*/
module top;

rojo_bfm bfm();
alu_tester tester_alu (bfm);
coverage_ifid ifid_cov (bfm);

rojo_module rojo_reference(/*signallsss*/);

endmodule: top