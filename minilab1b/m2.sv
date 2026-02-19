`default_nettype none

module mat_vec_mult #(
    parameter DEPTH       = 8,
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 24   // 8×8-bit × 8-bit → up to 24-bit accumulator
) (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        clr,          // synchronous clear accumulators

    // Write ports — usually driven by testbench / upper module
    input  wire                        a_wren,
    input  wire [DATA_WIDTH-1:0]       a_fifo_in [7:0],   // 8 elements per row
    input  wire                        b_wren,
    input  wire [DATA_WIDTH-1:0]       b_fifo_in,         // single column vector element

    output wire [ACC_WIDTH-1:0]        out [7:0]          // 8 result elements
);

    // ───────────────────────────────────────────────
    //  Control / state machine
    // ───────────────────────────────────────────────
    localparam IDLE    = 1'b0,
               WORKING = 1'b1;

    logic curr_state, next_state;
    logic all_a_full, all_a_empty;
    logic b_full, b_empty;

    // AND-reduce full/empty flags (cleaner style)
    assign all_a_full  = &a_full;
    assign all_a_empty = &a_empty;

    always_comb begin
        next_state = curr_state;
        case (curr_state)
            IDLE:    if (all_a_full && b_full)   next_state = WORKING;
            WORKING: if (all_a_empty && b_empty) next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) curr_state <= IDLE;
        else        curr_state <= next_state;
    end

    // ───────────────────────────────────────────────
    //  A-row FIFOs (8 rows, depth at least 8)
    // ───────────────────────────────────────────────
    wire [DATA_WIDTH-1:0] a_out     [7:0];
    wire                  a_full    [7:0];
    wire                  a_empty   [7:0];
    wire                  a_rden    [7:0];

    genvar gi;
    generate
        for (gi = 0; gi < 8; gi = gi + 1) begin : gen_a_fifos
            FIFO #(
                .DATA_WIDTH(DATA_WIDTH),
                .DEPTH     (DEPTH)      // should be ≥8
            ) fifo_a (
                .clk     (clk),
                .rst_n   (rst_n),
                .wren    (a_wren),
                .rden    (a_rden[gi]),
                .i_data  (a_fifo_in[gi]),
                .o_data  (a_out[gi]),
                .full    (a_full[gi]),
                .empty   (a_empty[gi])
            );
        end
    endgenerate

    // ───────────────────────────────────────────────
    //  B FIFO (single column vector)
    // ───────────────────────────────────────────────
    wire [DATA_WIDTH-1:0] b_out;
    FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (DEPTH)
    ) fifo_b (
        .clk     (clk),
        .rst_n   (rst_n),
        .wren    (b_wren),
        .rden    (b_rden),
        .i_data  (b_fifo_in),
        .o_data  (b_out),
        .full    (b_full),
        .empty   (b_empty)
    );

    // ───────────────────────────────────────────────
    //  Systolic control signals
    // ───────────────────────────────────────────────
    wire start_pulse = (curr_state == IDLE) && (next_state == WORKING);

    reg  en_pipe [8:0];   // 0 = input, 1..8 = delayed versions
    reg  b_pipe  [7:0];   // b values propagating right → left

    wire b_rden = en_pipe[0];   // start reading B when first En is asserted

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_pipe[0] <= 1'b0;
            for (int i = 1; i <= 8; i++) en_pipe[i] <= 1'b0;
        end
        else begin
            // Inject new start pulse only once when entering WORKING
            en_pipe[0] <= start_pulse;

            // Propagate enable rightward (left-to-right in diagram)
            for (int i = 1; i <= 8; i++) begin
                en_pipe[i] <= en_pipe[i-1];
            end
        end
    end

    // B propagates leftward (right-to-left in diagram)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 8; i++) b_pipe[i] <= '0;
        end
        else if (en_pipe[0]) begin               // shift only while computing
            b_pipe[0] <= b_out;                  // newest b enters from right
            for (int i = 1; i < 8; i++) begin
                b_pipe[i] <= b_pipe[i-1];        // shift leftward
            end
        end
    end

    // ───────────────────────────────────────────────
    //  MAC array — 8 rows
    // ───────────────────────────────────────────────
    generate
        for (gi = 0; gi < 8; gi = gi + 1) begin : gen_mac_row

            // Staggered read enable — row 0 starts first, row 7 starts last
            assign a_rden[gi] = en_pipe[gi];

            MAC #(
                .A_WIDTH   (DATA_WIDTH),
                .B_WIDTH   (DATA_WIDTH),
                .C_WIDTH   (ACC_WIDTH)
            ) mac (
                .clk   (clk),
                .rst_n (rst_n),
                .clr   (clr),               // synchronous accumulator clear
                .en    (en_pipe[gi]),       // only accumulate when enabled
                .a     (a_out[gi]),
                .b     (b_pipe[7-gi]),      // reverse indexing → b07 at top row
                .c     (out[gi])
            );
        end
    endgenerate

endmodule

`default_nettype wire
