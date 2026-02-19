module FIFO
#(
  parameter DEPTH=8,
  parameter DATA_WIDTH=8
)
(
  input  clk,
  input  rst_n,
  input  rden,
  input  wren,
  input  [DATA_WIDTH-1:0] i_data,
  output reg[DATA_WIDTH-1:0] o_data,
  output full,
  output empty
);

reg[DATA_WIDTH-1:0] array[0:DEPTH-1];
reg[$clog2(DEPTH)-1:0] fptr_raw;
reg dir;
reg[$clog2(DEPTH)-1:0] bptr_raw;
//wire[$clog2(DEPTH)-1:0] fptr_gray;
//wire[$clog2(DEPTH)-1:0] bptr_gray;

//assign ftpr_gray = fptr_raw ^ (fptr_raw>>1);
//assign btpr_gray = bptr_raw ^ (bptr_raw>>1);

/*always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		for(integer i = 0; i < DEPTH; ++i) begin
			array[i] <= 'b0;
			fptr_raw <= 'b0;
			bptr_raw <= 'b0;
			o_data <= 'b0;
		end
	end else begin
		if(wren & !full) begin
			array[fptr_raw] <= i_data;
			fptr_raw <= (fptr_raw + 'b1)%DEPTH;
		end
		if(rden & !empty) begin
			o_data <= array[bptr_raw];
			bptr_raw <= (bptr_raw + 'b1)%DEPTH;
		end
	end
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		dir <= 1'b0;
	end else begin
		if(wren & !rden) begin
			dir <= 1'b1;
		end
		if(rden & !wren) begin
			dir <= 1'b0;
		end
	end
end

assign full = (fptr_raw==bptr_raw) & (dir==1);
assign empty = (fptr_raw==bptr_raw) & (dir==0);*/

fifo2 ff2(
	.data(i_data),
	.rdclk(clk),
	.rdreq(rden),
	.wrclk(clk),
	.wrreq(wren),
	.q(o_data),
	.rdempty(empty),
	.wrfull(full));

endmodule
