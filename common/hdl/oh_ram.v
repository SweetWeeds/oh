//#############################################################################
//# Function: Generic Dual Port RAM                                           #
//#############################################################################
//# Author:   Andreas Olofsson                                                #
//# License:  MIT  (see LICENSE file in OH! repository)                       # 
//#############################################################################

module oh_ram_dp  
  # (parameter DW      = 104,          // memory width
     parameter DEPTH   = 32,           // memory depth
     parameter REG     = 1,            // register output
     parameter AW      = $clog2(DEPTH) // address width
     ) 
   (// read-port
    input 	    rd_clk,// rd clock
    input 	    rd_en, // memory access
    input [AW-1:0]  rd_addr, // address 
    output [DW-1:0] rd_dout, // data output   
    // write-port
    input 	    wr_clk,// wr clock
    input 	    wr_en, // memory access
    input [AW-1:0]  wr_addr, // address
    input [DW-1:0]  wr_wem, // write enable vector    
    input [DW-1:0]  wr_din, // data input
    // BIST interface
    input 	    bist_en, // bist enable
    input 	    bist_we, // write enable global signal   
    input [AW-1:0]  bist_addr, // address
    input [DW-1:0]  bist_din, // data input
    input [DW-1:0]  bist_wem, // write enable vector
    output [DW-1:0] bist_dout, // data output
    // Power/repair (hard macro only)
    input 	    shutdown, // shutdown signal
    input 	    vss, // ground signal
    input 	    vdd, // memory array power
    input 	    vddio, // periphery/io power
    input [7:0]     memconfig, // generic memory config      
    input [7:0]     memrepair // repair vector
    );
   
   reg [DW-1:0]        ram    [0:DEPTH-1];  
   wire [DW-1:0]       rdata;
   wire [AW-1:0]       dp_addr;
   integer 	       i;
   
   //#########################################
   // bist mux
   //#########################################

   assign wr_we_mux           = bist_en ? bist_we           : wr_we;
   assign wr_din_mux[DW-1:0]  = bist_en ? bist_din[DW-1:0]  : wr_din[DW-1:0];
   assign wr_addr_mux[AW-1:0] = bist_en ? bist_addr[AW-1:0] : wr_addr[AW-1:0];
   assign wr_wem_mux[DW-1:0]  = bist_en ? bist_wem[DW-1:0]  : wr_wem[DW-1:0];
   
   //#########################################
   // write port
   //#########################################	

   always @(posedge wr_clk)    
     for (i=0;i<DW;i=i+1)
       if (wr_en_mux & wr_wem_mux[i]) 
         ram[wr_addr_mux[AW-1:0]][i] <= wr_din_mux[i];

   //#########################################
   // read port
   //#########################################

   assign rdata[DW-1:0] = ram[rd_addr[AW-1:0]];
   
   //Configurable output register
   reg [DW-1:0]        rd_reg;
   always @ (posedge rd_clk)
     if(rd_en)       
       rd_reg[DW-1:0] <= rdata[DW-1:0];
   
   //Drive output from register or RAM directly
   assign rd_dout[DW-1:0] = (REG==1) ? rd_reg[DW-1:0] :
		                       rdata[DW-1:0];
     
endmodule // oh_ram







  
     

