`default_nettype none
//matrix multiplier MAC unit
//takes an 8x8 matrix and multiplies it by a 8x1 vector
//resulting in a 8x1 vector
//
module mat_vec_mult #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 8
) (
    input wire clk,
    input wire rst_n,
    input wire Clr,
    //input wire a_rden[7:0],
    //input wire b_rden,
    input wire a_wren,
    input wire b_wren,
    input wire [DATA_WIDTH-1:0] a_fifo_in[7:0],
    input wire [DATA_WIDTH-1:0] b_fifo_in,
    output wire [DATA_WIDTH*3-1:0] out[7:0]
);

  //generate 8 FIFOS for the a matrix
  wire [DATA_WIDTH-1:0] a_mat_out[7:0];
  wire a_full[7:0];
  wire a_empty[7:0];
  //wire a_rden[7:0];
  reg [7:0] a_rden;
  wire b_full;
  wire b_empty;

  localparam IDLE = 1'b0, WORKING = 1'b1;
  logic next_state;
  logic curr_state;

  logic a_full_and;
  logic a_empty_and;
  always_comb begin
    for (integer i = 1; i < 8; i = i + 1) a_full_and = a_full[i] & a_full[i-1];
  end
  always_comb begin
    for (integer i = 1; i < 8; i = i + 1) a_empty_and = a_empty[i] & a_empty[i-1];
  end
  //state transition logic for state machine
  always_comb begin
    next_state = curr_state;
    /**
    if (curr_state == IDLE && a_full.and()) begin
      next_state = WORKING;
    end else next_state = IDLE;

    if (curr_state == WORKING && a_empty.and()) next_state = IDLE;
    else next_state = WORKING;
    */
    case (curr_state)
      IDLE: begin
        if (a_full_and && b_full) next_state = WORKING;
      end
      WORKING: begin
        if (a_empty_and && b_empty) next_state = IDLE;
      end
    endcase
  end

  //state transition logic
  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) curr_state <= IDLE;
    else curr_state <= next_state;
  end

  //TODO: check this if it should staart at 8'b0 or 8'b1
  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) a_rden <= 8'b00000000;
    else begin
      if (curr_state == WORKING) begin
        a_rden <= {a_rden[7:1], 1'b1};
      end else if (curr_state == IDLE) begin
        a_rden <= 8'b0;
      end
    end
  end

  wire [7:0] b_fifo_out;
  wire b_rden;
  assign b_rden = (curr_state == WORKING);
  FIFO b_vec (
      .clk(clk),
      .rst_n(rst_n),
      .rden(b_rden),
      .wren(b_wren),
      .i_data(b_fifo_in),
      .o_data(b_fifo_out),
      .empty(b_empty),
      .full(b_full)
  );

  reg [DATA_WIDTH-1:0] shift_reg[7:0];
  always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
      for (integer i = 0; i < 8; i = i + 1) begin
        shift_reg[i] <= 8'b0;
      end
    end  //once it starts, start shifting in the values from the b_vec fifo
    else if (curr_state==WORKING)begin
      shift_reg[0] <= b_fifo_out;
      for (int i = 1; i < 8; i = i + 1) shift_reg[i] <= shift_reg[i-1];
    end
  end

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      FIFO a_mat (
          .clk(clk),
          .rst_n(rst_n),
          .rden(a_rden[i]),
          .wren(a_wren),
          .i_data(a_fifo_in[i]),
          .o_data(a_mat_out[i]),
          .full(a_full[i]),
          .empty(a_empty[i])
      );
    end
  endgenerate
  wire En;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      MAC mat_arr (
          .clk(clk),
          .rst_n(rst_n),
          .En(a_rden[i]),
          .Clr(Clr),
          .Ain(a_mat_out[i]),
          .Bin(shift_reg[i]),
          .Cout(out[i])
      );
    end
  endgenerate

endmodule
`default_nettype wire


