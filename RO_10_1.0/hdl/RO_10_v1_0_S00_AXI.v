
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
	        3'h0   : reg_data_out <= slv_reg0;
	        3'h1   : reg_data_out <= slv_reg1;
	        3'h2   : reg_data_out <= slv_reg2;
	        3'h3   : reg_data_out <= slv_reg3;
	        3'h4   : reg_data_out <= slv_reg4;
	        3'h5   : reg_data_out <= slv_reg5;
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
        (* dont_touch = "true" *) FD FF1(.D(s2), .C(S_AXI_ACLK), .Q(s1));
        (* dont_touch = "true" *) not U4(s2, s1);
        //(* dont_touch = "true" *) not U5(s3, s1);
        
        // Counters
        (* dont_touch = "true" *) CB16CE C1(.CLR(s2), .CE(s1), .C(w2), .Q(q1), .CEO(), .TC());
        (* dont_touch = "true" *) CB16CE C2(.CLR(s1), .CE(s2), .C(w2), .Q(q2), .CEO(), .TC());
        
        // Output
        assign q3 = q1 | q2;
        //(* dont_touch *) or U6(q3, q1, q2);
        
        // RO 10
        (* dont_touch = "true" *) FD AA1(.D(q3[0]), .C(S_AXI_ACLK), .Q(slv_reg0[1]));
        (* dont_touch = "true" *) FD AA2(.D(q3[1]), .C(S_AXI_ACLK), .Q(slv_reg0[2]));
        (* dont_touch = "true" *) FD AA3(.D(q3[2]), .C(S_AXI_ACLK), .Q(slv_reg0[3]));
        (* dont_touch = "true" *) FD AA4(.D(q3[3]), .C(S_AXI_ACLK), .Q(slv_reg0[4]));
        (* dont_touch = "true" *) FD AA5(.D(q3[4]), .C(S_AXI_ACLK), .Q(slv_reg0[5]));
        (* dont_touch = "true" *) FD AA6(.D(q3[5]), .C(S_AXI_ACLK), .Q(slv_reg0[6]));
        (* dont_touch = "true" *) FD AA7(.D(q3[6]), .C(S_AXI_ACLK), .Q(slv_reg0[7]));
        (* dont_touch = "true" *) FD AA8(.D(q3[7]), .C(S_AXI_ACLK), .Q(slv_reg0[8]));
        (* dont_touch = "true" *) FD AA9(.D(q3[8]), .C(S_AXI_ACLK), .Q(slv_reg0[9]));
        (* dont_touch = "true" *) FD AA10(.D(q3[9]), .C(S_AXI_ACLK), .Q(slv_reg0[10]));
        (* dont_touch = "true" *) FD AA11(.D(q3[10]), .C(S_AXI_ACLK), .Q(slv_reg0[11]));
        (* dont_touch = "true" *) FD AA12(.D(q3[11]), .C(S_AXI_ACLK), .Q(slv_reg0[12]));
        (* dont_touch = "true" *) FD AA13(.D(q3[12]), .C(S_AXI_ACLK), .Q(slv_reg0[13]));
        (* dont_touch = "true" *) FD AA14(.D(q3[13]), .C(S_AXI_ACLK), .Q(slv_reg0[14]));
        (* dont_touch = "true" *) FD AA15(.D(q3[14]), .C(S_AXI_ACLK), .Q(slv_reg0[15]));
        (* dont_touch = "true" *) FD AA16(.D(q3[15]), .C(S_AXI_ACLK), .Q(slv_reg0[16]));
        
        // RO 9
        (* dont_touch = "true" *) FD AB1(.D(slv_reg0[1]), .C(S_AXI_ACLK), .Q(slv_reg0[17]));
        (* dont_touch = "true" *) FD AB2(.D(slv_reg0[2]), .C(S_AXI_ACLK), .Q(slv_reg0[18]));
        (* dont_touch = "true" *) FD AB3(.D(slv_reg0[3]), .C(S_AXI_ACLK), .Q(slv_reg0[19]));
        (* dont_touch = "true" *) FD AB4(.D(slv_reg0[4]), .C(S_AXI_ACLK), .Q(slv_reg0[20]));
        (* dont_touch = "true" *) FD AB5(.D(slv_reg0[5]), .C(S_AXI_ACLK), .Q(slv_reg0[21]));
        (* dont_touch = "true" *) FD AB6(.D(slv_reg0[6]), .C(S_AXI_ACLK), .Q(slv_reg0[22]));
        (* dont_touch = "true" *) FD AB7(.D(slv_reg0[7]), .C(S_AXI_ACLK), .Q(slv_reg0[23]));
        (* dont_touch = "true" *) FD AB8(.D(slv_reg0[8]), .C(S_AXI_ACLK), .Q(slv_reg0[24]));
        (* dont_touch = "true" *) FD AB9(.D(slv_reg0[9]), .C(S_AXI_ACLK), .Q(slv_reg0[25]));
        (* dont_touch = "true" *) FD AB10(.D(slv_reg0[10]), .C(S_AXI_ACLK), .Q(slv_reg0[26]));
        (* dont_touch = "true" *) FD AB11(.D(slv_reg0[11]), .C(S_AXI_ACLK), .Q(slv_reg0[27]));
        (* dont_touch = "true" *) FD AB12(.D(slv_reg0[12]), .C(S_AXI_ACLK), .Q(slv_reg0[28]));
        (* dont_touch = "true" *) FD AB13(.D(slv_reg0[13]), .C(S_AXI_ACLK), .Q(slv_reg0[29]));
        (* dont_touch = "true" *) FD AB14(.D(slv_reg0[14]), .C(S_AXI_ACLK), .Q(slv_reg0[30]));
        (* dont_touch = "true" *) FD AB15(.D(slv_reg0[15]), .C(S_AXI_ACLK), .Q(slv_reg0[31]));
        (* dont_touch = "true" *) FD AB16(.D(slv_reg0[16]), .C(S_AXI_ACLK), .Q(slv_reg1[0]));
        
        // RO 8
        (* dont_touch = "true" *) FD AC1(.D(slv_reg0[17]), .C(S_AXI_ACLK), .Q(slv_reg1[1]));
        (* dont_touch = "true" *) FD AC2(.D(slv_reg0[18]), .C(S_AXI_ACLK), .Q(slv_reg1[2]));
        (* dont_touch = "true" *) FD AC3(.D(slv_reg0[19]), .C(S_AXI_ACLK), .Q(slv_reg1[3]));
        (* dont_touch = "true" *) FD AC4(.D(slv_reg0[20]), .C(S_AXI_ACLK), .Q(slv_reg1[4]));
        (* dont_touch = "true" *) FD AC5(.D(slv_reg0[21]), .C(S_AXI_ACLK), .Q(slv_reg1[5]));
        (* dont_touch = "true" *) FD AC6(.D(slv_reg0[22]), .C(S_AXI_ACLK), .Q(slv_reg1[6]));
        (* dont_touch = "true" *) FD AC7(.D(slv_reg0[23]), .C(S_AXI_ACLK), .Q(slv_reg1[7]));
        (* dont_touch = "true" *) FD AC8(.D(slv_reg0[24]), .C(S_AXI_ACLK), .Q(slv_reg1[8]));
        (* dont_touch = "true" *) FD AC9(.D(slv_reg0[25]), .C(S_AXI_ACLK), .Q(slv_reg1[9]));
        (* dont_touch = "true" *) FD AC10(.D(slv_reg0[26]), .C(S_AXI_ACLK), .Q(slv_reg1[10]));
        (* dont_touch = "true" *) FD AC11(.D(slv_reg0[27]), .C(S_AXI_ACLK), .Q(slv_reg1[11]));
        (* dont_touch = "true" *) FD AC12(.D(slv_reg0[28]), .C(S_AXI_ACLK), .Q(slv_reg1[12]));
        (* dont_touch = "true" *) FD AC13(.D(slv_reg0[29]), .C(S_AXI_ACLK), .Q(slv_reg1[13]));
        (* dont_touch = "true" *) FD AC14(.D(slv_reg0[30]), .C(S_AXI_ACLK), .Q(slv_reg1[14]));
        (* dont_touch = "true" *) FD AC15(.D(slv_reg0[31]), .C(S_AXI_ACLK), .Q(slv_reg1[15]));
        (* dont_touch = "true" *) FD AC16(.D(slv_reg1[0]), .C(S_AXI_ACLK), .Q(slv_reg1[16]));
        
         // RO 7
        (* dont_touch = "true" *) FD AD1(.D(slv_reg1[1]), .C(S_AXI_ACLK), .Q(slv_reg1[17]));
        (* dont_touch = "true" *) FD AD2(.D(slv_reg1[2]), .C(S_AXI_ACLK), .Q(slv_reg1[18]));
        (* dont_touch = "true" *) FD AD3(.D(slv_reg1[3]), .C(S_AXI_ACLK), .Q(slv_reg1[19]));
        (* dont_touch = "true" *) FD AD4(.D(slv_reg1[4]), .C(S_AXI_ACLK), .Q(slv_reg1[20]));
        (* dont_touch = "true" *) FD AD5(.D(slv_reg1[5]), .C(S_AXI_ACLK), .Q(slv_reg1[21]));
        (* dont_touch = "true" *) FD AD6(.D(slv_reg1[6]), .C(S_AXI_ACLK), .Q(slv_reg1[22]));
        (* dont_touch = "true" *) FD AD7(.D(slv_reg1[7]), .C(S_AXI_ACLK), .Q(slv_reg1[23]));
        (* dont_touch = "true" *) FD AD8(.D(slv_reg1[8]), .C(S_AXI_ACLK), .Q(slv_reg1[24]));
        (* dont_touch = "true" *) FD AD9(.D(slv_reg1[9]), .C(S_AXI_ACLK), .Q(slv_reg1[25]));
        (* dont_touch = "true" *) FD AD10(.D(slv_reg1[10]), .C(S_AXI_ACLK), .Q(slv_reg1[26]));
        (* dont_touch = "true" *) FD AD11(.D(slv_reg1[11]), .C(S_AXI_ACLK), .Q(slv_reg1[27]));
        (* dont_touch = "true" *) FD AD12(.D(slv_reg1[12]), .C(S_AXI_ACLK), .Q(slv_reg1[28]));
        (* dont_touch = "true" *) FD AD13(.D(slv_reg1[13]), .C(S_AXI_ACLK), .Q(slv_reg1[29]));
        (* dont_touch = "true" *) FD AD14(.D(slv_reg1[14]), .C(S_AXI_ACLK), .Q(slv_reg1[30]));
        (* dont_touch = "true" *) FD AD15(.D(slv_reg1[15]), .C(S_AXI_ACLK), .Q(slv_reg1[32]));
        (* dont_touch = "true" *) FD AD16(.D(slv_reg1[16]), .C(S_AXI_ACLK), .Q(slv_reg2[0]));
        
       // RO 6
       (* dont_touch = "true" *) FD AE1(.D(slv_reg1[17]), .C(S_AXI_ACLK), .Q(slv_reg2[1]));
       (* dont_touch = "true" *) FD AE2(.D(slv_reg1[18]), .C(S_AXI_ACLK), .Q(slv_reg2[2]));
       (* dont_touch = "true" *) FD AE3(.D(slv_reg1[19]), .C(S_AXI_ACLK), .Q(slv_reg2[3]));
       (* dont_touch = "true" *) FD AE4(.D(slv_reg1[20]), .C(S_AXI_ACLK), .Q(slv_reg2[4]));
       (* dont_touch = "true" *) FD AE5(.D(slv_reg1[21]), .C(S_AXI_ACLK), .Q(slv_reg2[5]));
       (* dont_touch = "true" *) FD AE6(.D(slv_reg1[22]), .C(S_AXI_ACLK), .Q(slv_reg2[6]));
       (* dont_touch = "true" *) FD AE7(.D(slv_reg1[23]), .C(S_AXI_ACLK), .Q(slv_reg2[7]));
       (* dont_touch = "true" *) FD AE8(.D(slv_reg1[24]), .C(S_AXI_ACLK), .Q(slv_reg2[8]));
       (* dont_touch = "true" *) FD AE9(.D(slv_reg1[25]), .C(S_AXI_ACLK), .Q(slv_reg2[9]));
       (* dont_touch = "true" *) FD AE10(.D(slv_reg1[26]), .C(S_AXI_ACLK), .Q(slv_reg2[10]));
       (* dont_touch = "true" *) FD AE11(.D(slv_reg1[27]), .C(S_AXI_ACLK), .Q(slv_reg2[11]));
       (* dont_touch = "true" *) FD AE12(.D(slv_reg1[28]), .C(S_AXI_ACLK), .Q(slv_reg2[12]));
       (* dont_touch = "true" *) FD AE13(.D(slv_reg1[29]), .C(S_AXI_ACLK), .Q(slv_reg2[13]));
       (* dont_touch = "true" *) FD AE14(.D(slv_reg1[30]), .C(S_AXI_ACLK), .Q(slv_reg2[14]));
       (* dont_touch = "true" *) FD AE15(.D(slv_reg1[31]), .C(S_AXI_ACLK), .Q(slv_reg2[15]));
       (* dont_touch = "true" *) FD AE16(.D(slv_reg2[0]), .C(S_AXI_ACLK), .Q(slv_reg2[16]));
       
       // RO 5
      (* dont_touch = "true" *) FD AF1(.D(slv_reg2[1]), .C(S_AXI_ACLK), .Q(slv_reg2[17]));
      (* dont_touch = "true" *) FD AF2(.D(slv_reg2[2]), .C(S_AXI_ACLK), .Q(slv_reg2[18]));
      (* dont_touch = "true" *) FD AF3(.D(slv_reg2[3]), .C(S_AXI_ACLK), .Q(slv_reg2[19]));
      (* dont_touch = "true" *) FD AF4(.D(slv_reg2[4]), .C(S_AXI_ACLK), .Q(slv_reg2[20]));
      (* dont_touch = "true" *) FD AF5(.D(slv_reg2[5]), .C(S_AXI_ACLK), .Q(slv_reg2[21]));
      (* dont_touch = "true" *) FD AF6(.D(slv_reg2[6]), .C(S_AXI_ACLK), .Q(slv_reg2[22]));
      (* dont_touch = "true" *) FD AF7(.D(slv_reg2[7]), .C(S_AXI_ACLK), .Q(slv_reg2[23]));
      (* dont_touch = "true" *) FD AF8(.D(slv_reg2[8]), .C(S_AXI_ACLK), .Q(slv_reg2[24]));
      (* dont_touch = "true" *) FD AF9(.D(slv_reg2[9]), .C(S_AXI_ACLK), .Q(slv_reg2[25]));
      (* dont_touch = "true" *) FD AF10(.D(slv_reg2[10]), .C(S_AXI_ACLK), .Q(slv_reg2[26]));
      (* dont_touch = "true" *) FD AF11(.D(slv_reg2[11]), .C(S_AXI_ACLK), .Q(slv_reg2[27]));
      (* dont_touch = "true" *) FD AF12(.D(slv_reg2[12]), .C(S_AXI_ACLK), .Q(slv_reg2[28]));
      (* dont_touch = "true" *) FD AF13(.D(slv_reg2[13]), .C(S_AXI_ACLK), .Q(slv_reg2[29]));
      (* dont_touch = "true" *) FD AF14(.D(slv_reg2[14]), .C(S_AXI_ACLK), .Q(slv_reg2[30]));
      (* dont_touch = "true" *) FD AF15(.D(slv_reg2[15]), .C(S_AXI_ACLK), .Q(slv_reg2[31]));
      (* dont_touch = "true" *) FD AF16(.D(slv_reg2[16]), .C(S_AXI_ACLK), .Q(slv_reg3[0]));
      
     // RO 4
     (* dont_touch = "true" *) FD AG1(.D(slv_reg2[1]), .C(S_AXI_ACLK), .Q(slv_reg3[1]));
     (* dont_touch = "true" *) FD AG2(.D(slv_reg2[18]), .C(S_AXI_ACLK), .Q(slv_reg3[2]));
     (* dont_touch = "true" *) FD AG3(.D(slv_reg2[19]), .C(S_AXI_ACLK), .Q(slv_reg3[3]));
     (* dont_touch = "true" *) FD AG4(.D(slv_reg2[20]), .C(S_AXI_ACLK), .Q(slv_reg3[4]));
     (* dont_touch = "true" *) FD AG5(.D(slv_reg2[21]), .C(S_AXI_ACLK), .Q(slv_reg3[5]));
     (* dont_touch = "true" *) FD AG6(.D(slv_reg2[22]), .C(S_AXI_ACLK), .Q(slv_reg3[6]));
     (* dont_touch = "true" *) FD AG7(.D(slv_reg2[23]), .C(S_AXI_ACLK), .Q(slv_reg3[7]));
     (* dont_touch = "true" *) FD AG8(.D(slv_reg2[24]), .C(S_AXI_ACLK), .Q(slv_reg3[8]));
     (* dont_touch = "true" *) FD AG9(.D(slv_reg2[25]), .C(S_AXI_ACLK), .Q(slv_reg3[9]));
     (* dont_touch = "true" *) FD AG10(.D(slv_reg2[26]), .C(S_AXI_ACLK), .Q(slv_reg3[10]));
     (* dont_touch = "true" *) FD AG11(.D(slv_reg2[27]), .C(S_AXI_ACLK), .Q(slv_reg3[11]));
     (* dont_touch = "true" *) FD AG12(.D(slv_reg2[28]), .C(S_AXI_ACLK), .Q(slv_reg3[12]));
     (* dont_touch = "true" *) FD AG13(.D(slv_reg2[29]), .C(S_AXI_ACLK), .Q(slv_reg3[13]));
     (* dont_touch = "true" *) FD AG14(.D(slv_reg2[30]), .C(S_AXI_ACLK), .Q(slv_reg3[14]));
     (* dont_touch = "true" *) FD AG15(.D(slv_reg2[31]), .C(S_AXI_ACLK), .Q(slv_reg3[15]));
     (* dont_touch = "true" *) FD AG16(.D(slv_reg3[0]), .C(S_AXI_ACLK), .Q(slv_reg3[16]));
     
    // RO 3
    (* dont_touch = "true" *) FD AH1(.D(slv_reg3[1]), .C(S_AXI_ACLK), .Q(slv_reg3[17]));
    (* dont_touch = "true" *) FD AH2(.D(slv_reg3[2]), .C(S_AXI_ACLK), .Q(slv_reg3[18]));
    (* dont_touch = "true" *) FD AH3(.D(slv_reg3[3]), .C(S_AXI_ACLK), .Q(slv_reg3[19]));
    (* dont_touch = "true" *) FD AH4(.D(slv_reg3[4]), .C(S_AXI_ACLK), .Q(slv_reg3[20]));
    (* dont_touch = "true" *) FD AH5(.D(slv_reg3[5]), .C(S_AXI_ACLK), .Q(slv_reg3[21]));
    (* dont_touch = "true" *) FD AH6(.D(slv_reg3[6]), .C(S_AXI_ACLK), .Q(slv_reg3[22]));
    (* dont_touch = "true" *) FD AH7(.D(slv_reg3[7]), .C(S_AXI_ACLK), .Q(slv_reg3[23]));
    (* dont_touch = "true" *) FD AH8(.D(slv_reg3[8]), .C(S_AXI_ACLK), .Q(slv_reg3[24]));
    (* dont_touch = "true" *) FD AH9(.D(slv_reg3[9]), .C(S_AXI_ACLK), .Q(slv_reg3[25]));
    (* dont_touch = "true" *) FD AH10(.D(slv_reg3[10]), .C(S_AXI_ACLK), .Q(slv_reg3[26]));
    (* dont_touch = "true" *) FD AH11(.D(slv_reg3[11]), .C(S_AXI_ACLK), .Q(slv_reg3[27]));
    (* dont_touch = "true" *) FD AH12(.D(slv_reg3[12]), .C(S_AXI_ACLK), .Q(slv_reg3[28]));
    (* dont_touch = "true" *) FD AH13(.D(slv_reg3[13]), .C(S_AXI_ACLK), .Q(slv_reg3[29]));
    (* dont_touch = "true" *) FD AH14(.D(slv_reg3[14]), .C(S_AXI_ACLK), .Q(slv_reg3[30]));
    (* dont_touch = "true" *) FD AH15(.D(slv_reg3[15]), .C(S_AXI_ACLK), .Q(slv_reg3[31]));
    (* dont_touch = "true" *) FD AH16(.D(slv_reg3[16]), .C(S_AXI_ACLK), .Q(slv_reg4[0]));
    
    // RO 2 
   (* dont_touch = "true" *) FD AI1(.D(slv_reg3[1]), .C(S_AXI_ACLK), .Q(slv_reg4[1]));
   (* dont_touch = "true" *) FD AI2(.D(slv_reg3[18]), .C(S_AXI_ACLK), .Q(slv_reg4[2]));
   (* dont_touch = "true" *) FD AI3(.D(slv_reg3[19]), .C(S_AXI_ACLK), .Q(slv_reg4[3]));
   (* dont_touch = "true" *) FD AI4(.D(slv_reg3[20]), .C(S_AXI_ACLK), .Q(slv_reg4[4]));
   (* dont_touch = "true" *) FD AI5(.D(slv_reg3[21]), .C(S_AXI_ACLK), .Q(slv_reg4[5]));
   (* dont_touch = "true" *) FD AI6(.D(slv_reg3[22]), .C(S_AXI_ACLK), .Q(slv_reg4[6]));
   (* dont_touch = "true" *) FD AI7(.D(slv_reg3[23]), .C(S_AXI_ACLK), .Q(slv_reg4[7]));
   (* dont_touch = "true" *) FD AI8(.D(slv_reg3[24]), .C(S_AXI_ACLK), .Q(slv_reg4[8]));
   (* dont_touch = "true" *) FD AI9(.D(slv_reg3[25]), .C(S_AXI_ACLK), .Q(slv_reg4[9]));
   (* dont_touch = "true" *) FD AI10(.D(slv_reg3[26]), .C(S_AXI_ACLK), .Q(slv_reg4[10]));
   (* dont_touch = "true" *) FD AI11(.D(slv_reg3[27]), .C(S_AXI_ACLK), .Q(slv_reg4[11]));
   (* dont_touch = "true" *) FD AI12(.D(slv_reg3[28]), .C(S_AXI_ACLK), .Q(slv_reg4[12]));
   (* dont_touch = "true" *) FD AI13(.D(slv_reg3[29]), .C(S_AXI_ACLK), .Q(slv_reg4[13]));
   (* dont_touch = "true" *) FD AI14(.D(slv_reg3[30]), .C(S_AXI_ACLK), .Q(slv_reg4[14]));
   (* dont_touch = "true" *) FD AI15(.D(slv_reg3[31]), .C(S_AXI_ACLK), .Q(slv_reg4[15]));
   (* dont_touch = "true" *) FD AI16(.D(slv_reg4[0]), .C(S_AXI_ACLK), .Q(slv_reg4[16]));
   
   // RO 1
  (* dont_touch = "true" *) FD AJ1(.D(slv_reg4[1]), .C(S_AXI_ACLK), .Q(slv_reg4[17]));
  (* dont_touch = "true" *) FD AJ2(.D(slv_reg4[2]), .C(S_AXI_ACLK), .Q(slv_reg4[18]));
  (* dont_touch = "true" *) FD AJ3(.D(slv_reg4[3]), .C(S_AXI_ACLK), .Q(slv_reg4[19]));
  (* dont_touch = "true" *) FD AJ4(.D(slv_reg4[4]), .C(S_AXI_ACLK), .Q(slv_reg4[20]));
  (* dont_touch = "true" *) FD AJ5(.D(slv_reg4[5]), .C(S_AXI_ACLK), .Q(slv_reg4[21]));
  (* dont_touch = "true" *) FD AJ6(.D(slv_reg4[6]), .C(S_AXI_ACLK), .Q(slv_reg4[22]));
  (* dont_touch = "true" *) FD AJ7(.D(slv_reg4[7]), .C(S_AXI_ACLK), .Q(slv_reg4[23]));
  (* dont_touch = "true" *) FD AJ8(.D(slv_reg4[8]), .C(S_AXI_ACLK), .Q(slv_reg4[24]));
  (* dont_touch = "true" *) FD AJ9(.D(slv_reg4[9]), .C(S_AXI_ACLK), .Q(slv_reg4[25]));
  (* dont_touch = "true" *) FD AJ10(.D(slv_reg4[10]), .C(S_AXI_ACLK), .Q(slv_reg4[26]));
  (* dont_touch = "true" *) FD AJ11(.D(slv_reg4[11]), .C(S_AXI_ACLK), .Q(slv_reg4[27]));
  (* dont_touch = "true" *) FD AJ12(.D(slv_reg4[12]), .C(S_AXI_ACLK), .Q(slv_reg4[28]));
  (* dont_touch = "true" *) FD AJ13(.D(slv_reg4[13]), .C(S_AXI_ACLK), .Q(slv_reg4[29]));
  (* dont_touch = "true" *) FD AJ14(.D(slv_reg4[14]), .C(S_AXI_ACLK), .Q(slv_reg4[30]));
  (* dont_touch = "true" *) FD AJ15(.D(slv_reg4[15]), .C(S_AXI_ACLK), .Q(slv_reg4[31]));
  (* dont_touch = "true" *) FD AJ16(.D(slv_reg4[16]), .C(S_AXI_ACLK), .Q(slv_reg5[0]));
   
	// User logic ends

	endmodule
