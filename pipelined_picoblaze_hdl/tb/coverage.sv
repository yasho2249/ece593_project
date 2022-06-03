/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Coverage module consist of Input covergroups 

*/


module coverage_ifid (rojo_bfm bfm);
    
    import rojobpkg::*;

    // Inputs
    bit [PORT_WIDTH-1:0]    in_port;        // Port input
    bit                     interrupt;      // Interrupt req
    bit                     reset;          // Reset
    bit                     clk;             // Clock

    // Outputs
    bit [PORT_DEPTH-1:0]   port_id;        // Port address.
    bit                    write_strobe;   // Port output strobe
    bit [PORT_WIDTH-1:0]   out_port;       // Port output
    bit                    read_strobe;    // Port input strobe
    bit                    interrupt_ack;  // Interrupt acknowledge

    // Covergroup for inputs
    covergroup cg_input_signals
        // Coverpoints for inputs
        rojob_in_port :     coverpoint cp_Input_port {
                option.at_least = 1;    // more than 1??
            bins IN0 = {8'h00};
            bins IN1 = {[8'h01:8'hFE]};
            bins IN2 = {8'hFF};

            // Consider transitions of specific cases 
            // eg. {8'h00 => 8'h01}

        }
        rojob_interrupt :   coverpoint cp_Interrupt;
        rojob_reset :       coverpoint cp_Reset;

        // Crosspoints for inputs
        rojob_in_portxrojob_interrupt : cross rojob_in_port, rojob_interrupt;
        rojob_in_portxrojob_reset :     cross rojob_in_port, rojob_reset;
        rojob_interruptxrojob_reset :   cross rojob_interrupt, rojob_reset; 

    endgroup

    // Covergroup for Output Signals
    covergroup cg_output_signals
        rojob_out_portid: coverpoint port_id{
            option.at_least = 1;
            bins portid0 = {8'h00};
            bins portid1 = {[8'h01:8'hFE]};
            bins portid2 = {8'hFF};
        }

        rojob_out_writestrobe: coverpoint write_strobe;
        rojob_out_readstrobe: coverpoint read_strobe;
        rojob_out_interruptack: coverpoint interrupt_ack;
        rojob_out_outport: coverpoint out_port{
            option.at_least = 1;
            bins outport0 = {8'h00};
            bins outport1 = {[8'h01:8'hFE]};
            bins outport2 = {8'hFF};
        }

        rojob_out_portidxreadstrobe: cross rojob_out_portid, rojob_out_readstrobe;
        rojob_out_portidxwritestrobe: cross rojob_out_portid, rojob_out_writestrobe;
        rojob_out_portidxinterruptack: cross rojob_out_portid, rojob_out_interruptack;
        rojob_out_readstrobexinterruptack: cross rojob_out_readstrobe, rojob_out_interruptack;
        rojob_out_writestrobexinterruptack: cross rojob_out_writestrobe, rojob_out_interruptack;
    
    endgroup
    /*
    // Covergroup for Instructions
    // Will this work?? 
    covergroup cg_input_inst
        // Coverpoints for instructions

    endgroup
    */

    cg_input_signals input_signals;
    cg_output_signals output_signals;

    initial begin: coverage_block
  
        input_signals = new();
        output_signals = new();
  
        forever begin: sampling_block
            @(posedge bfm.clk);
            in_port = bfm.in_port;
            interrupt = bfm.interrupt;
            reset = bfm.reset;
            port_id = bfm.port_id;
            write_strobe = bfm.write_strobe;
            read_strobe = bfm.read_strobe;
            out_port = bfm.out_port;
            interrupt_ack = bfm.interrupt_ack;

	        input_signals.sample();
	        output_signals.sample();
	
        end: sampling_block
     end: coverage_block


endmodule : coverage_ifid