module minilab1b(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SEG7 //////////
	output	reg	     [6:0]		HEX0,
	output	reg	     [6:0]		HEX1,
	output	reg	     [6:0]		HEX2,
	output	reg	     [6:0]		HEX3,
	output	reg	     [6:0]		HEX4,
	output	reg	     [6:0]		HEX5,
	
	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW
);

localparam DATA_WIDTH = 8;
localparam DEPTH = 8;


// SM States
//TODO: Change when SM logic done
localparam READ_MEM = 1'd0;
localparam DONE     = 1'd1;

wire rst_n;
wire Clr;
wire [DATA_WIDTH-1:0] a_fifo_in[DATA_WIDTH-1:0];
wire [DATA_WIDTH-1:0] b_fifo_in;
wire [DATA_WIDTH*3-1:0] out[DATA_WIDTH-1:0];
wire [31:0] address;
wire mem_rd_en;
wire done_wire;
wire [2:0] display;

reg a_wren, b_wren;
reg done;
reg inc;
reg state, nxt_state;
reg [3:0] mem_rd_count;
wire [63:0] data_line;

wire readdatavalid, waitrequest;
reg [DATA_WIDTH*3-1:0] macout;

parameter HEX_0 = 7'b1000000;		// zero
parameter HEX_1 = 7'b1111001;		// one
parameter HEX_2 = 7'b0100100;		// two
parameter HEX_3 = 7'b0110000;		// three
parameter HEX_4 = 7'b0011001;		// four
parameter HEX_5 = 7'b0010010;		// five
parameter HEX_6 = 7'b0000010;		// six
parameter HEX_7 = 7'b1111000;		// seven
parameter HEX_8 = 7'b0000000;		// eight
parameter HEX_9 = 7'b0011000;		// nine
parameter HEX_10 = 7'b0001000;	// ten
parameter HEX_11 = 7'b0000011;	// eleven
parameter HEX_12 = 7'b1000110;	// twelve
parameter HEX_13 = 7'b0100001;	// thirteen
parameter HEX_14 = 7'b0000110;	// fourteen
parameter HEX_15 = 7'b0001110;	// fifteen
parameter OFF   = 7'b1111111;		// all off


 

//=======================================================
//  Module instantiation
//=======================================================
mem_wrapper iRemember(
	.clk(CLOCK_50),
	.reset_n(rst_n),
	.address(address),
	.read(mem_rd_en),
	.readdata(data_line),
	.readdatavalid(readdatavalid),
	.waitrequest(waitrequest)
);	

mat_vec_mult #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH)) iMAC(
	.clk(CLOCK_50),
	.rst_n(rst_n),
	.Clr(Clr),
	.a_wren(a_wren),
	.b_wren(b_wren),
	.a_fifo_in(a_fifo_in),
	.b_fifo_in(data_line),
	.out(out),
	.done(done_wire)
);

//=======================================================
//  SM Time xD
//=======================================================
assign rst_n = KEY[0];
assign mem_rd_en = nxt_state == READ_MEM;
assign address = {28'b0, mem_rd_count};
assign display = {SW[3], SW[2], SW[1]};

// i need to learn generates
assign a_fifo_in[0] = data_line[ 7: 0];
assign a_fifo_in[1] = data_line[15: 8];
assign a_fifo_in[2] = data_line[23:16];
assign a_fifo_in[3] = data_line[31:24];
assign a_fifo_in[4] = data_line[39:32];
assign a_fifo_in[5] = data_line[47:40];
assign a_fifo_in[6] = data_line[55:48];
assign a_fifo_in[7] = data_line[63:56];

always @(*) begin
	case(state)
		READ_MEM:
		begin
			macout <= {(DATA_WIDTH*3){1'b0}};
			a_wren <= 1'b0;
			b_wren <= 1'b0;
			inc <= 1'b0;
			Clr <= 1'b0;

			done <= 1'b0;
			nxt_state <= READ_MEM;
			if (readdatavalid && mem_rd_count == 4'd8) begin
				b_wren <= 1'b1;
				inc <= 1'b1;
			end
			else if(readdatavalid) begin
				a_wren <= 1'b1;
				inc <= 1'b1;
			end
			else if (mem_rd_count == 4'd9)
				nxt_state <= DONE;
			else if (waitrequest && mem_rd_count == 4'd0)
				Clr <= 1'b1;
		end

		DONE:
		begin
			macout <= out[display];
			a_wren <= 1'b0;
			b_wren <= 1'b0;
			inc <= 1'b0;
			Clr <= 1'b0;

			done <= done_wire;
			nxt_state <= DONE;
		end
	endcase;
end


always_ff @(posedge CLOCK_50, negedge rst_n) begin
	if (!rst_n) 
		state <= READ_MEM;
	else 
		state <= nxt_state;
end

always_ff @(posedge CLOCK_50, negedge rst_n) begin
	if (!rst_n) 
		mem_rd_count <= 4'b0;
	else if(inc)
		mem_rd_count <= mem_rd_count + 1'b1;
end



// Courtesy Micheal
always @(*) begin
  if (state == DONE & SW[0]) begin
    case(macout[3:0])
      4'd0: HEX0 = HEX_0;
	   4'd1: HEX0 = HEX_1;
	   4'd2: HEX0 = HEX_2;
	   4'd3: HEX0 = HEX_3;
	   4'd4: HEX0 = HEX_4;
	   4'd5: HEX0 = HEX_5;
	   4'd6: HEX0 = HEX_6;
	   4'd7: HEX0 = HEX_7;
	   4'd8: HEX0 = HEX_8;
	   4'd9: HEX0 = HEX_9;
	   4'd10: HEX0 = HEX_10;
	   4'd11: HEX0 = HEX_11;
	   4'd12: HEX0 = HEX_12;
	   4'd13: HEX0 = HEX_13;
	   4'd14: HEX0 = HEX_14;
	   4'd15: HEX0 = HEX_15;
    endcase
  end
  else begin
    HEX0 = OFF;
  end
end

always @(*) begin
  if (state == DONE & SW[0]) begin
    case(macout[7:4])
      4'd0: HEX1 = HEX_0;
	   4'd1: HEX1 = HEX_1;
	   4'd2: HEX1 = HEX_2;
	   4'd3: HEX1 = HEX_3;
	   4'd4: HEX1 = HEX_4;
	   4'd5: HEX1 = HEX_5;
	   4'd6: HEX1 = HEX_6;
	   4'd7: HEX1 = HEX_7;
	   4'd8: HEX1 = HEX_8;
	   4'd9: HEX1 = HEX_9;
	   4'd10: HEX1 = HEX_10;
	   4'd11: HEX1 = HEX_11;
	   4'd12: HEX1 = HEX_12;
	   4'd13: HEX1 = HEX_13;
	   4'd14: HEX1 = HEX_14;
	   4'd15: HEX1 = HEX_15;
    endcase
  end
  else begin
    HEX1 = OFF;
  end
end

always @(*) begin
  if (state == DONE & SW[0]) begin
    case(macout[11:8])
      4'd0: HEX2 = HEX_0;
	   4'd1: HEX2 = HEX_1;
	   4'd2: HEX2 = HEX_2;
	   4'd3: HEX2 = HEX_3;
	   4'd4: HEX2 = HEX_4;
	   4'd5: HEX2 = HEX_5;
	   4'd6: HEX2 = HEX_6;
	   4'd7: HEX2 = HEX_7;
	   4'd8: HEX2 = HEX_8;
	   4'd9: HEX2 = HEX_9;
	   4'd10: HEX2 = HEX_10;
	   4'd11: HEX2 = HEX_11;
	   4'd12: HEX2 = HEX_12;
	   4'd13: HEX2 = HEX_13;
	   4'd14: HEX2 = HEX_14;
	   4'd15: HEX2 = HEX_15;
    endcase
  end
  else begin
    HEX2 = OFF;
  end
end

always @(*) begin
  if (state == DONE & SW[0]) begin
    case(macout[15:12])
      4'd0: HEX3 = HEX_0;
	   4'd1: HEX3 = HEX_1;
	   4'd2: HEX3 = HEX_2;
	   4'd3: HEX3 = HEX_3;
	   4'd4: HEX3 = HEX_4;
	   4'd5: HEX3 = HEX_5;
	   4'd6: HEX3 = HEX_6;
	   4'd7: HEX3 = HEX_7;
	   4'd8: HEX3 = HEX_8;
	   4'd9: HEX3 = HEX_9;
	   4'd10: HEX3 = HEX_10;
	   4'd11: HEX3 = HEX_11;
	   4'd12: HEX3 = HEX_12;
	   4'd13: HEX3 = HEX_13;
	   4'd14: HEX3 = HEX_14;
	   4'd15: HEX3 = HEX_15;
    endcase
  end
  else begin
    HEX3 = OFF;
  end
end

always @(*) begin
  if (state == DONE & SW[0]) begin
    case(macout[19:16])
      4'd0: HEX4 = HEX_0;
	   4'd1: HEX4 = HEX_1;
	   4'd2: HEX4 = HEX_2;
	   4'd3: HEX4 = HEX_3;
	   4'd4: HEX4 = HEX_4;
	   4'd5: HEX4 = HEX_5;
	   4'd6: HEX4 = HEX_6;
	   4'd7: HEX4 = HEX_7;
	   4'd8: HEX4 = HEX_8;
	   4'd9: HEX4 = HEX_9;
	   4'd10: HEX4 = HEX_10;
	   4'd11: HEX4 = HEX_11;
	   4'd12: HEX4 = HEX_12;
	   4'd13: HEX4 = HEX_13;
	   4'd14: HEX4 = HEX_14;
	   4'd15: HEX4 = HEX_15;
    endcase
  end
  else begin
    HEX4 = OFF;
  end
end

always @(*) begin
  if (state == DONE & SW[0]) begin
    case(macout[23:20])
      4'd0: HEX5 = HEX_0;
	   4'd1: HEX5 = HEX_1;
	   4'd2: HEX5 = HEX_2;
	   4'd3: HEX5 = HEX_3;
	   4'd4: HEX5 = HEX_4;
	   4'd5: HEX5 = HEX_5;
	   4'd6: HEX5 = HEX_6;
	   4'd7: HEX5 = HEX_7;
	   4'd8: HEX5 = HEX_8;
	   4'd9: HEX5 = HEX_9;
	   4'd10: HEX5 = HEX_10;
	   4'd11: HEX5 = HEX_11;
	   4'd12: HEX5 = HEX_12;
	   4'd13: HEX5 = HEX_13;
	   4'd14: HEX5 = HEX_14;
	   4'd15: HEX5 = HEX_15;
    endcase
  end
  else begin
    HEX5 = OFF;
  end
end

assign LEDR = {{8{1'b0}}, done};

endmodule
