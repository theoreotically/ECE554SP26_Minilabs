//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
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
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output iorw,
    input rda,
    input tbr,
    output [1:0] ioaddr,
    inout [7:0] databus
    );

    case (br_cfg):
    2'b00: begin
        assign ioaddr = 2'b10; // DIV_LOW
        assign databus = 8'd651; // divisor low byte
    end
    2'b01: begin
        assign ioaddr = 2'b10; // DIV_LOW
        assign databus = 8'd325; // divisor low byte
    end
    2'b10: begin
        assign ioaddr = 2'b10; // DIV_LOW
        assign databus = 8'd162; // divisor low byte
    end
    2'b11: begin
        assign ioaddr = 2'b10; // DIV_LOW
        assign databus = 8'd81; // divisor low byte
    end
    default: begin
        assign ioaddr = 2'b00; // SPART
        assign databus = 8'bz; // high impedance
    end
    endcase


endmodule
