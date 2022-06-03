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
        rojob_in_portxrojob_interrupt : coverpoint rojob_in_port, rojob_interrupt;
        rojob_in_portxrojob_reset :     coverpoint rojob_in_port, rojob_reset;
        rojob_interruptxrojob_reset :   coverpoint rojob_interrupt, rojob_reset; 

    endgroup

    /*
    // Covergroup for Instructions
    // Will this work?? 
    covergroup cg_input_inst
        // Coverpoints for instructions

    endgroup
    */

endmodule