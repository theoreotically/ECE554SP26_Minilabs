// synopsys translate_off
`timescale 1 ps / 1 ps
module minilab1b_tb();

logic clk, rst_n;

logic done, display_en;
logic [3:0] display_C0X;

logic [6:0] display_out [0:5];

logic [23:0] expected [0:7];

minilab1b iDUT(
  // inputs
  .CLOCK_50(clk),
  .CLOCK2_50(clk),
  .CLOCK3_50(clk),
  .CLOCK4_50(clk),
  .KEY({3'b0, rst_n}),
  .SW({6'b0, display_C0X[2:0], display_en}),

  // outputs
  .HEX0(display_out[0]),
  .HEX1(display_out[1]),
  .HEX2(display_out[2]),
  .HEX3(display_out[3]),
  .HEX4(display_out[4]),
  .HEX5(display_out[5]),
  .LEDR(done)
);

initial begin
  clk = 1'b0;
  rst_n = 1'b0;
  display_en = 1'b0;
  display_C0X = 4'b0;

  expected[0] = 24'd4812;
  expected[1] = 24'd21772;
  expected[2] = 24'd38732;
  expected[3] = 24'd55692;
  expected[4] = 24'd72652;
  expected[5] = 24'd89612;
  expected[6] = 24'd106572;
  expected[7] = 24'd123532;

  @(posedge clk)
  rst_n = 1'b1;
  display_en = 1'b1;

  @(posedge done) 
  for(display_C0X = 0; display_C0X < 8; display_C0X++) begin
    // May be incorrect wait period for macout switch
    @(posedge clk)

    if (iDUT.macout !== expected[display_C0X]) begin
      $display("Display error! Expected: %d . Actual %d", expected[display_C0X],  iDUT.macout);
      $stop;
    end
  end

  $display("YAHOO!!! ALL TESTS PASSED.");
  $stop;

end



always #5 clk = ~clk;


endmodule