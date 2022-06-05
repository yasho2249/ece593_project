
module top;

rojo_bfm bfm();
alu_tester tester_alu (bfm);
coverage_ifid ifid_cov (bfm);

rojo_module rojo_reference(/*signallsss*/);

endmodule: top