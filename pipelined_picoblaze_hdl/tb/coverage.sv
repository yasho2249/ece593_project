/*

Group 3: Yashodhan Wagle, Ramaa Potnis, Supreet Gulavani
ECE 593: Final Project
        Testebench for verification of RojoBlaze

Coverage module consist of Input covergroups 

*/

`ifndef __COVERAGE_SV__
`define __COVERAGE_SV__




module coverage_ifid (rojo_bfm bfm);
    
   

    // Inputs _rojo
    bit [PORT_WIDTH-1:0]    in_port;        // Port input
    bit                     interrupt;      // Interrupt req
    bit                     reset;          // Reset
    bit                     clk;             // Clock

    // Outputs _rojo
    bit [PORT_DEPTH-1:0]   port_id;        // Port address.
    bit                    write_strobe;   // Port output strobe
    bit [PORT_WIDTH-1:0]   out_port;       // Port output
    bit                    read_strobe;    // Port input strobe
    bit                    interrupt_ack;  // Interrupt acknowledge


    // blockram signals
    bit en, we;
    bit [DEPTH-1:0] ad;
    bit [WIDTH-1:0] din;
    bit [WIDTH-1:0] dout;

    // scratch signals
    bit write_enable;
    bit [SCRATCH_DEPTH-1:0] address;
    bit [SCRATCH_WIDTH-1:0] data_in;
    bit [SCRATCH_WIDTH-1:0] data_out;

    // alu  
    bit opcode_t operation;
    bit shift_op_t shift_operation;
    bit shift_direction;
    bit shift_constant;
    bit [OPERAND_WIDTH-1:0] operand_a, operand_b;	
    bit carry_in;
    bit [OPERAND_WIDTH-1:0] result;
    bit zero_out;
    bit carry_out;

    // Covergroup for inputs
    covergroup cg_input_signals
        // Coverpoints for inputs
        rojob_in_port :     coverpoint in_port {
                option.at_least = 1;    // more than 1??
            bins IN0 = {8'h00};
            bins IN1 = {[8'h01:8'hFE]};
            bins IN2 = {8'hFF};

            // Consider transitions of specific cases 
            // eg. {8'h00 => 8'h01}

        }
        rojob_interrupt :   coverpoint interrupt;
        rojob_reset :       coverpoint reset;

        // Crosspoints for inputs

        //rojo
        rojob_in_portxrojob_interrupt : cross rojob_in_port, rojob_interrupt;
        rojob_in_portxrojob_reset :     cross rojob_in_port, rojob_reset;
        rojob_interruptxrojob_reset :   cross rojob_interrupt, rojob_reset; 

        // blockram
        rojob_in_en : coverpoint en;
        rojob_in_we : coverpoint we;
        rojob_in_enxwe : cross rojob_in_en, rojob_in_we;
        rojob_in_ad : coverpoint ad{
            options.at_least = 1;
            bins ad0 = {[DEPTH-1]'h00};
            bins ad1 = {[DEPTH-1]'h01:[DEPTH-1]'hFF};
        }
        rojob_in_din : coverpoint din{
            options.at_least = 1;
            bins din0 = {[WIDTH-1]'h00};
            bins din1 = {[WIDTH-1]'h01:[WIDTH-1]'hFF};
        }

        // scratch
        rojob_in_write_enable : coverpoint write_enable;

        // alu
        rojob_in_operation : coverpoint operation;
        rojob_in_shiftop : coverpoint shift_operation;
        rojob_in_shiftdir : coverpoint shift_direction;
        rojob_in_shiftcons : coverpoint shift_constant;
        rojob_in_operanda : coverpoint operand_a {
            bins opa0 = {[OPERAND_WIDTH-1]'h00};
            bins opa1 = {[OPERAND_WIDTH-1]'h01:[OPERAND_WIDTH-1]'hFF};
        }
        rojob_in_operandb : coverpoint operand_b {
            bins opb0 = {[OPERAND_WIDTH-1]'h00};
            bins opb1 = {[OPERAND_WIDTH-1]'h01:[OPERAND_WIDTH-1]'hFF};
        }
        rojob_in_carryin : coverpoint carry_in;

        rojob_in_operationxopa : cross rojob_in_operation, rojob_in_operanda;
        rojob_in_operationxopb : cross rojob_in_operation, rojob_in_operandb;
        rojob_in_shiftopxshiftdir : cross rojob_in_shiftop, rojob_in_shiftdir;
        rojob_in_shiftopxshiftcons : cross rojob_in_shiftop, rojob_in_shiftcons;
        rojob_in_shiftdirxshiftcons : cross rojob_in_shiftdir, rojob_in_shiftcons;
        rojob_in_operandaxb : cross rojob_in_operanda, rojob_in_operandb;
        rojob_in_operandaxcin : cross rojob_in_operanda, rojob_in_carryin;
        rojob_in_operandbxcin : cross rojob_in_operandb, rojob_in_carryin;

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

        rojob_out_dout : coverpoint dout{
            options.at_least = 1;
            bins dout0 = {[WIDTH-1]'h00};
            bins dout1 = {[WIDTH-1]'h01:[WIDTH-1]'hFF};
        }
    
        //alu
        rojob_out_result : coverpoint result {
            bins res0 = {[OPERAND_WIDTH-1]'h00};
            bins res1 = {[OPERAND_WIDTH-1]'h01:[OPERAND_WIDTH-1]'hFF};
        }
        rojob_out_zout : coverpoint zero_out;
        rojob_out_carryout : coverpoint carry_out;
        rojob_out_resultxzout : cross rojob_out_result, rojob_out_zout;
        rojob_out_resultxcout : cross rojob_out_result, rojob_out_carryout;
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

`endif
