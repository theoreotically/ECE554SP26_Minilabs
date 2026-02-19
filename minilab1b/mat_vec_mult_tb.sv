module mat_vec_mult_tb ();

  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;

  logic clk;
  logic rst_n;
  logic Clr;

  // logic a_rden[7:0];
  // logic b_rden;

  logic [7:0] a_wren;
  logic b_wren;
  logic [DATA_WIDTH-1:0] a_fifo_in;
  logic [DATA_WIDTH-1:0] b_fifo_in;
  logic [DATA_WIDTH*3-1:0] out[7:0];

  // generate unpacked versions of a_fifo_in, b_fifo_in, out
  logic [DATA_WIDTH*3-1:0] out_0;
  assign out_0 = out[0];

  logic done;

  mat_vec_mult_t iDUT (
    .done(done),
    .clk(clk),
    .rst_n(rst_n),
    .Clr(Clr),
    .a_wren(a_wren),
    .b_wren(b_wren),
    .a_fifo_in(a_fifo_in),
    .b_fifo_in(b_fifo_in),
    .out(out)
  );

  // enable all a and b fifos, and start loading in values into each one
  task load_fifo_a(
    input logic [DATA_WIDTH-1:0] a_mat [7:0],
    input int unsigned index
  );
    a_wren = 8'b1 << index;

    for (int j = 0; j < 8; j++) begin
      a_fifo_in = a_mat[j];
      @(posedge clk);
    end

    a_wren = 8'b0;
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

  logic [DATA_WIDTH-1:0] mat_a[7:0][7:0];
  logic [DATA_WIDTH-1:0] val_a[7:0];
  logic [DATA_WIDTH-1:0] vec_b[7:0];
  logic [DATA_WIDTH-1:0] val_b;
  logic [DATA_WIDTH-1:0] exp_val[7:0];
  logic [DATA_WIDTH-1:0] flat[7:0];

  initial begin
    $dumpfile("dump2.vcd");
    $dumpvars(0, mat_vec_mult_tb);
  end

  initial begin
    #5;
    rst_n <= 1'b1;
    Clr   <= 1'b1;

    #5;
    @(posedge clk) begin
      rst_n <= 1'b0;
      Clr   <= 1'b0;
    end

    #20;
    @(posedge clk) begin
      rst_n <= 1'b1;
      Clr   <= 1'b0;
    end

    // try driving the tasks (god please work)
    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd1;
    load_fifo_a(val_a, 0);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd2;
    load_fifo_a(val_a, 1);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd3;
    load_fifo_a(val_a, 2);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd4;
    load_fifo_a(val_a, 3);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd5;
    load_fifo_a(val_a, 4);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd6;
    load_fifo_a(val_a, 5);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd7;
    load_fifo_a(val_a, 6);
    load_fifo_b(val_b);

    for (integer i = 0; i < 8; i = i + 1) begin
      val_a[i] = i;
    end
    val_b = 8'd8;
    load_fifo_a(val_a, 7);
    load_fifo_b(val_b);

    #1000;
    $display("EXPECTED");
    for(integer i=0;i<8;i=i+1)begin
      $display("%d",24'd168);
    end
    $display("ACTUAl");
    for(integer i=0;i<8;i=i+1)begin
      $display("%d",out[i]);
    end
    Clr <= 1'b1;
    @(posedge clk) Clr <= 1'b0;
    @(posedge clk) Clr <= 1'b1;

    #1000;
    $finish;
  end

endmodule
