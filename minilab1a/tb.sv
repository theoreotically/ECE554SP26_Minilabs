`timescale 1ns/1ns
`default_nettype none
module tb();

reg clk;
wire[6:0] HEX0; 
wire[6:0] HEX1; 
wire[6:0] HEX2; 
wire[6:0] HEX3; 
wire[6:0] HEX4; 
wire[6:0] HEX5; 

wire [9:0] LEDR;
reg [3:0] KEY;
reg [9:0] SW;

Minilab0 ml(.CLOCK_50(clk), .CLOCK2_50(clk),.CLOCK3_50(clk),.CLOCK4_50(clk),.HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5),.LEDR(LEDR),.KEY(KEY),.SW(SW));

initial begin
	clk <= 'b0;
end
always #5 clk <= ~clk;

initial begin
	$dumpfile("dump.vcd");
    $dumpvars(0,tb);
	SW <= 'b1;
	KEY <= 'b0;
	#100;
	KEY <= 'b1;
	SW <= 'b0;
	
	@(LEDR);

	#1000;
	SW <= 'b1;
	#1000;

	if(HEX5 !==  7'b1000000) begin
		$display("Digit 5 mismatch");
		$finish();
	end
	if(HEX4 !==  7'b1000000) begin
		$display("Digit 4 mismatch");
		$finish();
	end
	if(HEX3 !==  7'h79) begin
		$display("Digit 3 mismatch");
		$finish();
	end
	if(HEX2 !==  7'h3) begin
		$display("Digit 2 mismatch");
		$finish();
	end
	if(HEX1 !==  7'h12) begin
		$display("Digit 1 mismatch");
		$finish();
	end
	if(HEX0 !==  7'h0) begin
		$display("Digit 0 mismatch");
		$finish();
	end

	
	$display("Yahoo! All tests passed!");
	$finish();
end

endmodule
`default_nettype wire
