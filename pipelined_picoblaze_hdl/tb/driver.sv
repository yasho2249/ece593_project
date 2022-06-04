

interface intf(input logic clk, reset);
   
  //declaring the signals

   
endinterface

class driver;


    int txn_count;
    // virtual interface
    virtual intf vif;

    // mailbox
    mailbox gen_driv;

    function new(virtual intf vif, mailbox gen_driv);
        this.vif = vif;
        this.gen_driv = gen_driv;
    endfunction

    //reset task, initialize all interface values 
    task reset;
        wait(vif.reset);
        $display("DRIVER RESET INITIATE");
        //add intf var
        wait(!vif.reset);
        $display("DRIVER RESET END");
    endtask

    // main driver task
    task main;
        forever begin
            transaction txn;
            gen_driv.get(txn);
            @(posedge vif.clk);
            // var
            @(posedge vif.clk);
            txn.write_mem();
            txn_count++;
        end
    endtask

endclass
