module mat_vec_mult_tb ();
  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;

  logic clk;
  logic rst_n;
  logic Clr;
  // logic a_rden[7:0];
  // logic b_rden;
  logic a_wren;
  logic b_wren;
  logic [DATA_WIDTH-1:0] a_fifo_in[7:0];
  logic [DATA_WIDTH-1:0] b_fifo_in;
  logic [DATA_WIDTH*3-1:0] out[7:0];

  //generate unpacked versions of a_fifo_in, b_fifo_in, out
  logic [DATA_WIDTH*3-1:0] out_0;
  assign out_0=out[0];

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      logic [DATA_WIDTH-1:0] a_fifo_in_upacked = a_fifo_in[i];
      logic [DATA_WIDTH-1:0] out_unpacked = out[i];
    end
  endgenerate

mat_vec_mult iDUT (
  .clk(clk),
  .rst_n(rst_n),
  .Clr(Clr),
  .a_wren(a_wren),
  .b_wren(b_wren),
  .a_fifo_in(a_fifo_in),
  .b_fifo_in(b_fifo_in),
  .out(out)
);


  //enable all a and b fifos, and start loading in values into each one
  task load_fifo_a(input [DATA_WIDTH-1:0] a_mat[7:0]);
    a_wren = 1'b1;
    for (integer i = 0; i < 8; i = i + 1) begin
      for (integer j = 0; j < 8; j = j + 1) begin
        a_fifo_in[j] = a_mat[i];
      end
      @(posedge clk) begin
      end
    end
    a_wren = 1'b0;
  endtask

  task load_fifo_b(input [DATA_WIDTH-1:0] b_vec);
    b_wren = 1'b1;
    b_fifo_in = b_vec;
    @(posedge clk) begin
    end
    b_wren = 1'b0;
  endtask


  initial clk = 0;
  always #5 clk = ~clk;
  logic [DATA_WIDTH-1:0] val_a[7:0];
  logic[DATA_WIDTH-1:0] val_b;
  initial begin
    $dumpfile("dump2.vcd");
    $dumpvars(0, mat_vec_mult_tb);
    #5;
    rst_n <= 1'b1;
    Clr   <= 1'b1;
    #5;
    @(posedge clk)begin rst_n <= 1'b0;
    Clr <= 1'b0;
  end
  #20 @(posedge clk)begin rst_n <= 1'b1;
    Clr <= 1'b1;
  end
    //try driving the tasks (god please work)
    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = 8'b1;
    end
    val_b=8'b1;

    load_fifo_a(val_a);
    load_fifo_a(val_a);
    load_fifo_a(val_a);
    load_fifo_a(val_a);
    load_fifo_a(val_a);
    load_fifo_a(val_a);
    load_fifo_a(val_a);
    load_fifo_a(val_a);

    load_fifo_b(val_b);
    load_fifo_b(val_b);
    load_fifo_b(val_b);
    load_fifo_b(val_b);
    load_fifo_b(val_b);
    load_fifo_b(val_b);
    load_fifo_b(val_b);
    load_fifo_b(val_b);

  end
endmodule

