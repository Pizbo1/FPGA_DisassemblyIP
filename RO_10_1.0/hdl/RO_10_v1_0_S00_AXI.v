
`timescale 1 ns / 1 ps

	module RO_10_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
        input wire gated_clock,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 2;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 6
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

    wire [32:0] out0;
    wire [32:0] out1;
    wire [32:0] out2;
    wire [32:0] out3;
    wire [32:0] out4;
    wire [32:0] out5;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	      slv_reg4 <= 0;
	      slv_reg5 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          3'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h4:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h5:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 5
	                slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                      slv_reg4 <= slv_reg4;
	                      slv_reg5 <= slv_reg5;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        3'h0   : reg_data_out <= out0;
	        3'h1   : reg_data_out <= out1;
	        3'h2   : reg_data_out <= out2;
	        3'h3   : reg_data_out <= out3;
	        3'h4   : reg_data_out <= out4;
	        3'h5   : reg_data_out <= out5;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
    (* dont_touch = "true" *) wire w1;
    (* dont_touch = "true" *) wire w2;
    (* dont_touch = "true" *) wire s1;
    (* dont_touch = "true" *) wire s2;
    //(* dont_touch = "true" *) wire s3;
    (* dont_touch = "true" *) wire[15:0] q1;
    (* dont_touch = "true" *) wire[15:0] q2;
    (* dont_touch = "true" *) wire[15:0] q3;
    //(* dont_touch = "true" *) wire[15:0] counter;
       
    // Ring Oscillator
    (* dont_touch = "true" *) and U2(w1, w2, slv_reg0[0]);
    (* dont_touch = "true" *) not U3(w2, w1);
       
    // Counter Selector
    (* dont_touch = "true" *) FD FF1(.D(s2), .C(gated_clock), .Q(s1));
    (* dont_touch = "true" *) not U4(s2, s1);
    //(* dont_touch = "true" *) not U5(s3, s1);
        
    // Counters
    (* dont_touch = "true" *) CB16CE C1(.CLR(s2), .CE(s1), .C(w2), .Q(q1), .CEO(), .TC());
    (* dont_touch = "true" *) CB16CE C2(.CLR(s1), .CE(s2), .C(w2), .Q(q2), .CEO(), .TC());
        
    // Output
    (* dont_touch = "true" *) or O0(q3[0], q1[0], q2[0]);
    (* dont_touch = "true" *) or O1(q3[1], q1[1], q2[1]);
    (* dont_touch = "true" *) or O2(q3[1], q1[2], q2[2]);
    (* dont_touch = "true" *) or O3(q3[3], q1[3], q2[3]);
    (* dont_touch = "true" *) or O4(q3[4], q1[4], q2[4]);
    (* dont_touch = "true" *) or O5(q3[5], q1[5], q2[5]);
    (* dont_touch = "true" *) or O6(q3[6], q1[6], q2[6]);
    (* dont_touch = "true" *) or O7(q3[7], q1[7], q2[7]);
    (* dont_touch = "true" *) or O8(q3[8], q1[8], q2[8]);
    (* dont_touch = "true" *) or O9(q3[9], q1[9], q2[9]);
    (* dont_touch = "true" *) or O10(q3[10], q1[10], q2[10]);
    (* dont_touch = "true" *) or O11(q3[11], q1[11], q2[11]);
    (* dont_touch = "true" *) or O12(q3[12], q1[12], q2[12]);
    (* dont_touch = "true" *) or O13(q3[13], q1[13], q2[13]);
    (* dont_touch = "true" *) or O14(q3[14], q1[14], q2[14]);
    (* dont_touch = "true" *) or O15(q3[15], q1[15], q2[15]);
    //(* dont_touch *) or U6(q3, q1, q2);
        
        // RO 10
    (* dont_touch = "true" *) FD AA1(.D(q3[0]), .C(gated_clock), .Q(out0[1]));
    (* dont_touch = "true" *) FD AA2(.D(q3[1]), .C(gated_clock), .Q(out0[2]));
    (* dont_touch = "true" *) FD AA3(.D(q3[2]), .C(gated_clock), .Q(out0[3]));
    (* dont_touch = "true" *) FD AA4(.D(q3[3]), .C(gated_clock), .Q(out0[4]));
    (* dont_touch = "true" *) FD AA5(.D(q3[4]), .C(gated_clock), .Q(out0[5]));
    (* dont_touch = "true" *) FD AA6(.D(q3[5]), .C(gated_clock), .Q(out0[6]));
    (* dont_touch = "true" *) FD AA7(.D(q3[6]), .C(gated_clock), .Q(out0[7]));
    (* dont_touch = "true" *) FD AA8(.D(q3[7]), .C(gated_clock), .Q(out0[8]));
    (* dont_touch = "true" *) FD AA9(.D(q3[8]), .C(gated_clock), .Q(out0[9]));
    (* dont_touch = "true" *) FD AA10(.D(q3[9]), .C(gated_clock), .Q(out0[10]));
    (* dont_touch = "true" *) FD AA11(.D(q3[10]), .C(gated_clock), .Q(out0[11]));
    (* dont_touch = "true" *) FD AA12(.D(q3[11]), .C(gated_clock), .Q(out0[12]));
    (* dont_touch = "true" *) FD AA13(.D(q3[12]), .C(gated_clock), .Q(out0[13]));
    (* dont_touch = "true" *) FD AA14(.D(q3[13]), .C(gated_clock), .Q(out0[14]));
    (* dont_touch = "true" *) FD AA15(.D(q3[14]), .C(gated_clock), .Q(out0[15]));
    (* dont_touch = "true" *) FD AA16(.D(q3[15]), .C(gated_clock), .Q(out0[16]));
          
    // RO 9
    (* dont_touch = "true" *) FD AB1(.D(out0[1]), .C(gated_clock), .Q(out0[17]));
    (* dont_touch = "true" *) FD AB2(.D(out0[2]), .C(gated_clock), .Q(out0[18]));
    (* dont_touch = "true" *) FD AB3(.D(out0[3]), .C(gated_clock), .Q(out0[19]));
    (* dont_touch = "true" *) FD AB4(.D(out0[4]), .C(gated_clock), .Q(out0[20]));
    (* dont_touch = "true" *) FD AB5(.D(out0[5]), .C(gated_clock), .Q(out0[21]));
    (* dont_touch = "true" *) FD AB6(.D(out0[6]), .C(gated_clock), .Q(out0[22]));
    (* dont_touch = "true" *) FD AB7(.D(out0[7]), .C(gated_clock), .Q(out0[23]));
    (* dont_touch = "true" *) FD AB8(.D(out0[8]), .C(gated_clock), .Q(out0[24]));
    (* dont_touch = "true" *) FD AB9(.D(out0[9]), .C(gated_clock), .Q(out0[25]));
    (* dont_touch = "true" *) FD AB10(.D(out0[10]), .C(gated_clock), .Q(out0[26]));
    (* dont_touch = "true" *) FD AB11(.D(out0[11]), .C(gated_clock), .Q(out0[27]));
    (* dont_touch = "true" *) FD AB12(.D(out0[12]), .C(gated_clock), .Q(out0[28]));
    (* dont_touch = "true" *) FD AB13(.D(out0[13]), .C(gated_clock), .Q(out0[29]));
    (* dont_touch = "true" *) FD AB14(.D(out0[14]), .C(gated_clock), .Q(out0[30]));
    (* dont_touch = "true" *) FD AB15(.D(out0[15]), .C(gated_clock), .Q(out0[31]));
    (* dont_touch = "true" *) FD AB16(.D(out0[16]), .C(gated_clock), .Q(out1[0]));
          
    // RO 8
    (* dont_touch = "true" *) FD AC1(.D(out0[17]), .C(gated_clock), .Q(out1[1]));
    (* dont_touch = "true" *) FD AC2(.D(out0[18]), .C(gated_clock), .Q(out1[2]));
    (* dont_touch = "true" *) FD AC3(.D(out0[19]), .C(gated_clock), .Q(out1[3]));
    (* dont_touch = "true" *) FD AC4(.D(out0[20]), .C(gated_clock), .Q(out1[4]));
    (* dont_touch = "true" *) FD AC5(.D(out0[21]), .C(gated_clock), .Q(out1[5]));
    (* dont_touch = "true" *) FD AC6(.D(out0[22]), .C(gated_clock), .Q(out1[6]));
    (* dont_touch = "true" *) FD AC7(.D(out0[23]), .C(gated_clock), .Q(out1[7]));
    (* dont_touch = "true" *) FD AC8(.D(out0[24]), .C(gated_clock), .Q(out1[8]));
    (* dont_touch = "true" *) FD AC9(.D(out0[25]), .C(gated_clock), .Q(out1[9]));
    (* dont_touch = "true" *) FD AC10(.D(out0[26]), .C(gated_clock), .Q(out1[10]));
    (* dont_touch = "true" *) FD AC11(.D(out0[27]), .C(gated_clock), .Q(out1[11]));
    (* dont_touch = "true" *) FD AC12(.D(out0[28]), .C(gated_clock), .Q(out1[12]));
    (* dont_touch = "true" *) FD AC13(.D(out0[29]), .C(gated_clock), .Q(out1[13]));
    (* dont_touch = "true" *) FD AC14(.D(out0[30]), .C(gated_clock), .Q(out1[14]));
    (* dont_touch = "true" *) FD AC15(.D(out0[31]), .C(gated_clock), .Q(out1[15]));
    (* dont_touch = "true" *) FD AC16(.D(out1[0]), .C(gated_clock), .Q(out1[16]));
          
    // RO 7
    (* dont_touch = "true" *) FD AD1(.D(out1[1]), .C(gated_clock), .Q(out1[17]));
    (* dont_touch = "true" *) FD AD2(.D(out1[2]), .C(gated_clock), .Q(out1[18]));
    (* dont_touch = "true" *) FD AD3(.D(out1[3]), .C(gated_clock), .Q(out1[19]));
    (* dont_touch = "true" *) FD AD4(.D(out1[4]), .C(gated_clock), .Q(out1[20]));
    (* dont_touch = "true" *) FD AD5(.D(out1[5]), .C(gated_clock), .Q(out1[21]));
    (* dont_touch = "true" *) FD AD6(.D(out1[6]), .C(gated_clock), .Q(out1[22]));
    (* dont_touch = "true" *) FD AD7(.D(out1[7]), .C(gated_clock), .Q(out1[23]));
    (* dont_touch = "true" *) FD AD8(.D(out1[8]), .C(gated_clock), .Q(out1[24]));
    (* dont_touch = "true" *) FD AD9(.D(out1[9]), .C(gated_clock), .Q(out1[25]));
    (* dont_touch = "true" *) FD AD10(.D(out1[10]), .C(gated_clock), .Q(out1[26]));
    (* dont_touch = "true" *) FD AD11(.D(out1[11]), .C(gated_clock), .Q(out1[27]));
    (* dont_touch = "true" *) FD AD12(.D(out1[12]), .C(gated_clock), .Q(out1[28]));
    (* dont_touch = "true" *) FD AD13(.D(out1[13]), .C(gated_clock), .Q(out1[29]));
    (* dont_touch = "true" *) FD AD14(.D(out1[14]), .C(gated_clock), .Q(out1[30]));
    (* dont_touch = "true" *) FD AD15(.D(out1[15]), .C(gated_clock), .Q(out1[32]));
    (* dont_touch = "true" *) FD AD16(.D(out1[16]), .C(gated_clock), .Q(out2[0]));
          
     // RO 6
    (* dont_touch = "true" *) FD AE1(.D(out1[17]), .C(gated_clock), .Q(out2[1]));
    (* dont_touch = "true" *) FD AE2(.D(out1[18]), .C(gated_clock), .Q(out2[2]));
    (* dont_touch = "true" *) FD AE3(.D(out1[19]), .C(gated_clock), .Q(out2[3]));
    (* dont_touch = "true" *) FD AE4(.D(out1[20]), .C(gated_clock), .Q(out2[4]));
    (* dont_touch = "true" *) FD AE5(.D(out1[21]), .C(gated_clock), .Q(out2[5]));
    (* dont_touch = "true" *) FD AE6(.D(out1[22]), .C(gated_clock), .Q(out2[6]));
    (* dont_touch = "true" *) FD AE7(.D(out1[23]), .C(gated_clock), .Q(out2[7]));
    (* dont_touch = "true" *) FD AE8(.D(out1[24]), .C(gated_clock), .Q(out2[8]));
    (* dont_touch = "true" *) FD AE9(.D(out1[25]), .C(gated_clock), .Q(out2[9]));
    (* dont_touch = "true" *) FD AE10(.D(out1[26]), .C(gated_clock), .Q(out2[10]));
    (* dont_touch = "true" *) FD AE11(.D(out1[27]), .C(gated_clock), .Q(out2[11]));
    (* dont_touch = "true" *) FD AE12(.D(out1[28]), .C(gated_clock), .Q(out2[12]));
    (* dont_touch = "true" *) FD AE13(.D(out1[29]), .C(gated_clock), .Q(out2[13]));
    (* dont_touch = "true" *) FD AE14(.D(out1[30]), .C(gated_clock), .Q(out2[14]));
    (* dont_touch = "true" *) FD AE15(.D(out1[31]), .C(gated_clock), .Q(out2[15]));
    (* dont_touch = "true" *) FD AE16(.D(out2[0]), .C(gated_clock), .Q(out2[16]));
         
     // RO 5
    (* dont_touch = "true" *) FD AF1(.D(out2[1]), .C(gated_clock), .Q(out2[17]));
    (* dont_touch = "true" *) FD AF2(.D(out2[2]), .C(gated_clock), .Q(out2[18]));
    (* dont_touch = "true" *) FD AF3(.D(out2[3]), .C(gated_clock), .Q(out2[19]));
    (* dont_touch = "true" *) FD AF4(.D(out2[4]), .C(gated_clock), .Q(out2[20]));
    (* dont_touch = "true" *) FD AF5(.D(out2[5]), .C(gated_clock), .Q(out2[21]));
    (* dont_touch = "true" *) FD AF6(.D(out2[6]), .C(gated_clock), .Q(out2[22]));
    (* dont_touch = "true" *) FD AF7(.D(out2[7]), .C(gated_clock), .Q(out2[23]));
    (* dont_touch = "true" *) FD AF8(.D(out2[8]), .C(gated_clock), .Q(out2[24]));
    (* dont_touch = "true" *) FD AF9(.D(out2[9]), .C(gated_clock), .Q(out2[25]));
    (* dont_touch = "true" *) FD AF10(.D(out2[10]), .C(gated_clock), .Q(out2[26]));
    (* dont_touch = "true" *) FD AF11(.D(out2[11]), .C(gated_clock), .Q(out2[27]));
    (* dont_touch = "true" *) FD AF12(.D(out2[12]), .C(gated_clock), .Q(out2[28]));
    (* dont_touch = "true" *) FD AF13(.D(out2[13]), .C(gated_clock), .Q(out2[29]));
    (* dont_touch = "true" *) FD AF14(.D(out2[14]), .C(gated_clock), .Q(out2[30]));
    (* dont_touch = "true" *) FD AF15(.D(out2[15]), .C(gated_clock), .Q(out2[31]));
    (* dont_touch = "true" *) FD AF16(.D(out2[16]), .C(gated_clock), .Q(out3[0]));
        
    // RO 4
    (* dont_touch = "true" *) FD AG1(.D(out2[1]), .C(gated_clock), .Q(out3[1]));
    (* dont_touch = "true" *) FD AG2(.D(out2[18]), .C(gated_clock), .Q(out3[2]));
    (* dont_touch = "true" *) FD AG3(.D(out2[19]), .C(gated_clock), .Q(out3[3]));
    (* dont_touch = "true" *) FD AG4(.D(out2[20]), .C(gated_clock), .Q(out3[4]));
    (* dont_touch = "true" *) FD AG5(.D(out2[21]), .C(gated_clock), .Q(out3[5]));
    (* dont_touch = "true" *) FD AG6(.D(out2[22]), .C(gated_clock), .Q(out3[6]));
    (* dont_touch = "true" *) FD AG7(.D(out2[23]), .C(gated_clock), .Q(out3[7]));
    (* dont_touch = "true" *) FD AG8(.D(out2[24]), .C(gated_clock), .Q(out3[8]));
    (* dont_touch = "true" *) FD AG9(.D(out2[25]), .C(gated_clock), .Q(out3[9]));
    (* dont_touch = "true" *) FD AG10(.D(out2[26]), .C(gated_clock), .Q(out3[10]));
    (* dont_touch = "true" *) FD AG11(.D(out2[27]), .C(gated_clock), .Q(out3[11]));
    (* dont_touch = "true" *) FD AG12(.D(out2[28]), .C(gated_clock), .Q(out3[12]));
    (* dont_touch = "true" *) FD AG13(.D(out2[29]), .C(gated_clock), .Q(out3[13]));
    (* dont_touch = "true" *) FD AG14(.D(out2[30]), .C(gated_clock), .Q(out3[14]));
    (* dont_touch = "true" *) FD AG15(.D(out2[31]), .C(gated_clock), .Q(out3[15]));
    (* dont_touch = "true" *) FD AG16(.D(out3[0]), .C(gated_clock), .Q(out3[16]));
       
    // RO 3
    (* dont_touch = "true" *) FD AH1(.D(out3[1]), .C(gated_clock), .Q(out3[17]));
    (* dont_touch = "true" *) FD AH2(.D(out3[2]), .C(gated_clock), .Q(out3[18]));
    (* dont_touch = "true" *) FD AH3(.D(out3[3]), .C(gated_clock), .Q(out3[19]));
    (* dont_touch = "true" *) FD AH4(.D(out3[4]), .C(gated_clock), .Q(out3[20]));
    (* dont_touch = "true" *) FD AH5(.D(out3[5]), .C(gated_clock), .Q(out3[21]));
    (* dont_touch = "true" *) FD AH6(.D(out3[6]), .C(gated_clock), .Q(out3[22]));
    (* dont_touch = "true" *) FD AH7(.D(out3[7]), .C(gated_clock), .Q(out3[23]));
    (* dont_touch = "true" *) FD AH8(.D(out3[8]), .C(gated_clock), .Q(out3[24]));
    (* dont_touch = "true" *) FD AH9(.D(out3[9]), .C(gated_clock), .Q(out3[25]));
    (* dont_touch = "true" *) FD AH10(.D(out3[10]), .C(gated_clock), .Q(out3[26]));
    (* dont_touch = "true" *) FD AH11(.D(out3[11]), .C(gated_clock), .Q(out3[27]));
    (* dont_touch = "true" *) FD AH12(.D(out3[12]), .C(gated_clock), .Q(out3[28]));
    (* dont_touch = "true" *) FD AH13(.D(out3[13]), .C(gated_clock), .Q(out3[29]));
    (* dont_touch = "true" *) FD AH14(.D(out3[14]), .C(gated_clock), .Q(out3[30]));
    (* dont_touch = "true" *) FD AH15(.D(out3[15]), .C(gated_clock), .Q(out3[31]));
    (* dont_touch = "true" *) FD AH16(.D(out3[16]), .C(gated_clock), .Q(out4[0]));
      
     // RO 2 
    (* dont_touch = "true" *) FD AI1(.D(out3[1]), .C(gated_clock), .Q(out4[1]));
    (* dont_touch = "true" *) FD AI2(.D(out3[18]), .C(gated_clock), .Q(out4[2]));
    (* dont_touch = "true" *) FD AI3(.D(out3[19]), .C(gated_clock), .Q(out4[3]));
    (* dont_touch = "true" *) FD AI4(.D(out3[20]), .C(gated_clock), .Q(out4[4]));
    (* dont_touch = "true" *) FD AI5(.D(out3[21]), .C(gated_clock), .Q(out4[5]));
    (* dont_touch = "true" *) FD AI6(.D(out3[22]), .C(gated_clock), .Q(out4[6]));
    (* dont_touch = "true" *) FD AI7(.D(out3[23]), .C(gated_clock), .Q(out4[7]));
    (* dont_touch = "true" *) FD AI8(.D(out3[24]), .C(gated_clock), .Q(out4[8]));
    (* dont_touch = "true" *) FD AI9(.D(out3[25]), .C(gated_clock), .Q(out4[9]));
    (* dont_touch = "true" *) FD AI10(.D(out3[26]), .C(gated_clock), .Q(out4[10]));
    (* dont_touch = "true" *) FD AI11(.D(out3[27]), .C(gated_clock), .Q(out4[11]));
    (* dont_touch = "true" *) FD AI12(.D(out3[28]), .C(gated_clock), .Q(out4[12]));
    (* dont_touch = "true" *) FD AI13(.D(out3[29]), .C(gated_clock), .Q(out4[13]));
    (* dont_touch = "true" *) FD AI14(.D(out3[30]), .C(gated_clock), .Q(out4[14]));
    (* dont_touch = "true" *) FD AI15(.D(out3[31]), .C(gated_clock), .Q(out4[15]));
    (* dont_touch = "true" *) FD AI16(.D(out4[0]), .C(gated_clock), .Q(out4[16]));
     
     // RO 1
    (* dont_touch = "true" *) FD AJ1(.D(out4[1]), .C(gated_clock), .Q(out4[17]));
    (* dont_touch = "true" *) FD AJ2(.D(out4[2]), .C(gated_clock), .Q(out4[18]));
    (* dont_touch = "true" *) FD AJ3(.D(out4[3]), .C(gated_clock), .Q(out4[19]));
    (* dont_touch = "true" *) FD AJ4(.D(out4[4]), .C(gated_clock), .Q(out4[20]));
    (* dont_touch = "true" *) FD AJ5(.D(out4[5]), .C(gated_clock), .Q(out4[21]));
    (* dont_touch = "true" *) FD AJ6(.D(out4[6]), .C(gated_clock), .Q(out4[22]));
    (* dont_touch = "true" *) FD AJ7(.D(out4[7]), .C(gated_clock), .Q(out4[23]));
    (* dont_touch = "true" *) FD AJ8(.D(out4[8]), .C(gated_clock), .Q(out4[24]));
    (* dont_touch = "true" *) FD AJ9(.D(out4[9]), .C(gated_clock), .Q(out4[25]));
    (* dont_touch = "true" *) FD AJ10(.D(out4[10]), .C(gated_clock), .Q(out4[26]));
    (* dont_touch = "true" *) FD AJ11(.D(out4[11]), .C(gated_clock), .Q(out4[27]));
    (* dont_touch = "true" *) FD AJ12(.D(out4[12]), .C(gated_clock), .Q(out4[28]));
    (* dont_touch = "true" *) FD AJ13(.D(out4[13]), .C(gated_clock), .Q(out4[29]));
    (* dont_touch = "true" *) FD AJ14(.D(out4[14]), .C(gated_clock), .Q(out4[30]));
    (* dont_touch = "true" *) FD AJ15(.D(out4[15]), .C(gated_clock), .Q(out4[31]));
    (* dont_touch = "true" *) FD AJ16(.D(out4[16]), .C(gated_clock), .Q(out5[0]));
	// User logic ends

	endmodule
