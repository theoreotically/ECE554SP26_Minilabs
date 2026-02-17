//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
  input clk,
  input rst,
  input iocs,
  input iorw,
  output rda,
  output tbr,
  input [1:0] ioaddr,
  inout [7:0] databus,
  output txd,
  input rxd
);

wire spart_enable;

wire [7:0] tx_bus;
wire [7:0] rx_bus;


// module instantiations
bus_interface bus(
  .iocs(iocs),
  .iorw(iorw),
  .rda(),
  .tbr(),
  .ioaddr(ioaddr),
  .rxd(rx_bus),
  .databus(databus),
  .txd(tx_bus)
  );


baud_generator BGR(
  .clk(clk),
  .rst(rst),
  .divisor(tx_bus),
  .ioaddr(ioaddr),
  .spart_enable(spart_enable)
);

spart_tx tx(
  .clk(clk),
  .rst(rst),
  .enable(spart_enable),
  .ioaddr(ioaddr),
  .txd(tx_bus),
  .tbr(tbr)
);

spart_rx rx(
  .clk(clk),
  .rst(rst),
  .enable(spart_enable),
  .ioaddr(ioaddr),
  .rxd(rx_bus),
  .rda(rda)
);

endmodule
