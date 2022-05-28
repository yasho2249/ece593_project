// module rojo_tester(rojo_bfm bfm);


// /*function to get stimulus for C_data 
//  --> static probability is used to select a value*/
// function bit [31:0] get_Cdata();
//   bit [1:0] max_min;
//   max_min = $random;
//   if(max_min == 2'b00)
//     return 32'h00000000;
//   else if(max_min == 2'b11)
//     return 32'hFFFFFFFF;
//   else
//     return $random;
// endfunction: get_Cdata

// /*function to get stimulus for bidAmt
//  --> static probability is used to select a value*/
// function bit [15:0] get_bidAmt();
//   bit [1:0] max_min;
//   max_min = $random;
//   if(max_min == 2'b00)
//     return 16'h0000;
//   else if(max_min == 2'b11)
//     return 16'hFFFF;
//   else
//     return $random;
// endfunction: get_bidAmt

// //function to get stimulus for C_start, X_bid, Y_bid, Z_bid, and retract Control signals
// function bit get_cSignal();
//   bit [1:0] max_min;
//   max_min = $random;
//   if(max_min == 2'b00)
//     return 1'b1;
//   else if(max_min == 2'b11)
//     return 1'b1;
//   else if(max_min == 2'b10)
//     return 1'b1;
//   else
//     return 1'b0;
// endfunction: get_cSignal

// initial begin
//   bit [31:0] tCdata;
//   bit [15:0] tXbidAmt, tYbidAmt, tZbidAmt;
//   bit tXbid, tYbid, tZbid;
//   bit tXretract, tYretract, tZretract; 
//   bit tCstart; 
//   operation_t op_set;
//   bit tXack, tYack, tZack;
//   bit [1:0] tXerr, tYerr, tZerr;
//   bit [31:0] tXbalance, tYbalance, tZbalance;
//   bit tXwin, tYwin, tZwin;
//   bit tready;
//   bit [2:0] terr;
//   bit troundOver;
//   bit [31:0] tmaxBid;
  
//   int runs;
//   string Initial_Task;
  
//   //dynamic selection of a task to set initial conditions
//   if($value$plusargs("InitialTask=%s", Initial_Task));
//   if(Initial_Task == "ResetTask")
//     bfm.reset_BIDmodel();
//   else if(Initial_Task == "UnlockTask")
//     bfm.unlock_BIDmodel();
//   else
//     $display("No initial task given");

//   //dynamic selection of a number of runs
//   if($value$plusargs("RUNS=%d", runs));
  
//   $display("RUNS: %d", runs);
//   $display("InitialTask: %s", Initial_Task);
  
//   repeat (runs) begin: random_loop
//     op_set = get_op();
// 	tCdata = get_Cdata();
//     tXbidAmt = get_bidAmt();
// 	tYbidAmt = get_bidAmt();
// 	tZbidAmt = get_bidAmt();
//     tXbid = get_cSignal();
// 	tYbid = get_cSignal();
// 	tZbid = get_cSignal();
//     tXretract = get_cSignal();
// 	tYretract = get_cSignal();
// 	tZretract = get_cSignal();
//     tCstart = get_cSignal();
	
// 	bfm.send_op(tXbidAmt, tYbidAmt, tZbidAmt, tXbid, tYbid, tZbid,
//       tXretract, tYretract, tZretract, tCdata, tCstart, op_set,
// 	  tXack, tYack, tZack, tXerr, tYerr, tZerr, tXbalance, tYbalance,
// 	  tZbalance, tXwin, tYwin, tZwin, tready, terr, troundOver, tmaxBid);

//   end: random_loop
//   $stop;
  
// end

// endmodule: BIDS22tester