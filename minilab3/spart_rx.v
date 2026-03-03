module spart_rx(
  input clk,
  input rst,
  input enable,
  input shift_enable,
  input rxd,
  output start,
  output reg rda,
  output reg [7:0] rx_bus
);

  /////////////////////////////////
  //     Inputs and Outputs     //
  ///////////////////////////////
  input  wire clr_rdy;       // clr ready


  //////////////////////////////////////////
  //          INTERNAL SIGNALS           //
  ////////////////////////////////////////
  reg [8:0]  rx_shft_reg;
  reg [3:0]  bit_cnt;
  reg data_negedge, receiving, start, set_rdy;
  reg RX_ff0, RX_ff1, RX_ff2, rdy_ff;

  ////////////////////////////////////////
  //       States for Control SM       //
  //////////////////////////////////////
  typedef enum reg 
  { 
    IDLE,
    RECEIVE
  } state_t;

  state_t state, nxt_state;

  // assign FF data to outputs
  assign rx_bus = rx_shft_reg[7:0];
  assign rda = rdy_ff;

  // negedge detection
  and and1 (data_negedge, RX_ff2, ~RX_ff1);

  ///////////////////////////////////////////////
  //         Control SM's output logic        //
  /////////////////////////////////////////////
  always_comb 
  begin
    // Defaults
    start = 0;
    receiving = 0;
    set_rdy = 0;
    nxt_state = state;
    case (state)
      IDLE:
        // Edge detected, initialize machine
        if (data_negedge)
        begin
          start = 1;
          nxt_state = RECEIVE;
        end
      RECEIVE:
        // Byte received, complete transaction
        if (bit_cnt == 8)
        begin
          receiving = 0;
          set_rdy = 1;
          nxt_state = IDLE;
        end
        // Still receiving byte
        else
        begin
          receiving = 1;
          nxt_state = RECEIVE;
        end
      // spinning some sweet threads
      default:
        nxt_state = IDLE;
    endcase
  end

  //////////////////////////////////////////
  //           Control SM's FF           //
  ////////////////////////////////////////
  always_ff @(posedge clk, posedge rst)
    if (rst)
      state <= IDLE;
    else 
      state <= nxt_state;

  //////////////////////////////////////////
  //             RDY RS FLOP             //
  ////////////////////////////////////////
  always_ff @(posedge clk, posedge rst)
    if (rst)
      rdy_ff <= 1'b0;
    else if (start)
      rdy_ff <= 1'b0;
    // else if (clr_rdy)
    //   rdy_ff <= 1'b0;
    else if (set_rdy)
      rdy_ff <= 1'b1;

  //////////////////////////////////////////
  // rxd metastability & edge detect ff   //
  ////////////////////////////////////////
  always_ff @(posedge clk, posedge rst)
    if (rst) // RST
      {RX_ff0, RX_ff1, RX_ff2} <= 1'b1;
    else        // pipeeee
    begin
      RX_ff0 <= rxd;
      RX_ff1 <= RX_ff0;
      RX_ff2 <= RX_ff1;
    end

  //////////////////////////////////////
  //        Bit_count register       //
  ////////////////////////////////////
  always_ff @(posedge clk)
    if (start)      // RST
      bit_cnt <= '0;
    else if (shift_enable) // INC
      bit_cnt <= bit_cnt + 1;

  //////////////////////////////////
  //         Shift register      //
  ////////////////////////////////
  always_ff @(posedge clk)
   if (rst)
    rx_shft_reg <= 0;
   else if (shift_enable) // just keep shifting & shifting...
    rx_shft_reg <= {RX_ff1, {rx_shft_reg[8:1]}};

endmodule