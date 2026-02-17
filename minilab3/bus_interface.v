module bus_interface(
  input        iocs,
  input        iorw,
  input        rda,
  input        tbr,
  input  [1:0] ioaddr,
  input  [7:0] rxd,
  inout  [7:0] databus,
  output [7:0] txd
);

localparam SPART = 2'b00,
           STATUS = 2'b01,
           DIV_LOW = 2'b10,
           DIV_HIGH = 2'b11;

reg [7:0] status_reg;

assign status_reg[0] = rda;
assign status_reg[1] = tbr;
assign status_reg[7:2] = 6'b0;

case (ioaddr)
  SPART: begin
    // read from RX register when iorw is high
    if (iorw & iocs) assign databus = rxd;
    // write to TX register when iorw is low
    else if (~iorw & iocs) assign txd = databus;
  end
  STATUS:
    // read from status register when iorw is high
    if (iorw & iocs) assign databus = status_reg;
  DIV_LOW: 
    // write to divisor low register when iorw is low
    if (~iorw & iocs) assign txd = databus;
  DIV_HIGH: 
    // write to divisor high register when iorw is low
    if (~iorw & iocs) assign txd = databus;
  default: begin
    assign databus = 8'bz;
    assign txd = 8'bz;
  end
endcase

endmodule