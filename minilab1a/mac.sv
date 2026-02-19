module MAC #
(
parameter DATA_WIDTH = 8
)
(
input clk,
input rst_n,
input En,
input Clr,
input [DATA_WIDTH-1:0] Ain,
input [DATA_WIDTH-1:0] Bin,
output reg[DATA_WIDTH*3-1:0] Cout
);

/*always@(posedge clk, negedge rst_n)begin
	if(!rst_n) begin
		Cout <= 'b0;
	end else if(Clr) begin
		Cout <= 'b0;
	end else if(En) begin
		Cout += Ain * Bin;
	end
end

*/
wire[DATA_WIDTH*3-1:0] cout_next;
wire[DATA_WIDTH*2-1:0] mult_out;

mult_mod mm(
	.dataa(Ain),.datab(Bin),.result(mult_out)
);
addsb as(.dataa({8'b0, mult_out}), .datab(Cout), .result(cout_next));

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		Cout <= 'b0;
	end else if(Clr) begin
		Cout <= 'b0;
	end else if(En) begin
		Cout <= cout_next;
	end
end



endmodule
