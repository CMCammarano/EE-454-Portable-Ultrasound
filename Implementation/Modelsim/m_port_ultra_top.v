`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2015 06:36:58 PM
// Design Name: 
// Module Name: m_port_ultra_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module m_port_ultra_top (
	input CLK100MHZ,
	input [15:0] SW,
	input BTNC, BTNU, BTND, BTNL, BTNR,
	input CPU_RESETN,
	output [15:0] LED,
	output CA, output CB, output CC, output CD, output CE, output CF, output CG, output DP,
	output [7:0] AN
);

	// Wire declarations -- Ouputs for FSM
	wire [4095:0] convexPoints;
	wire [7:0] convexSetSize;
	
	//SSD
	reg [4:0] SSD;
	reg [7:0] SSD_CATHODES;
	reg [3:0] count;
	wire [31:0] outputResult;
	reg scan_ca;
	
	assign AN[0] = scan_ca;

	//DP is always off, thus 1'b1
	assign {CA, CB, CC, CD, CE, CF, CG, DP} = { SSD_CATHODES, 1'b1};
	
	// Clock divider
	reg [26:0] DIV_CLK;

	always @(posedge CLK100MHZ, negedge CPU_RESETN) begin							
		if (!CPU_RESETN) begin
			DIV_CLK <= 0;
		end
		
		else begin
			DIV_CLK <= DIV_CLK + 1'b1;
		end
	end
	
	// Module declaration
	m_port_ultra portableUltrasoundFSM (
		.clk (CLK100MHZ),
		.slowClk (DIV_CLK[25:24]),
		.reset_n (CPU_RESETN),
		.ack (BTNC),
		.shiftRight (BTNR),
		.shiftLeft (BTNL),
		.convexPoints (convexPoints),
		.convexSetSize (convexSetSize)
	);
	
	//BCD calculatios
	wire [3:0] BCD0, BCD1, BCD2, BCD3, BCD4;
	
	assign BCD4 = (convexSetSize / 10000);
	assign BCD3 = (((convexSetSize % 10000) - (convexSetSize % 1000)) / 1000);
	assign BCD2 = (((convexSetSize % 1000) - (convexSetSize % 100)) / 100);
	assign BCD1 = (((convexSetSize % 100) - (convexSetSize % 10)) / 10);
	assign BCD0 = (((convexSetSize % 10) - (convexSetSize % 1)) / 1);

	// SSD Display Cycler
	assign outputResult [31:28] = 4'b0000;
	assign outputResult [27:24] = 4'b0000;
	assign outputResult [23:20] = 4'b0000;
	assign outputResult [19:16] = BCD4;
	assign outputResult [15:12] = BCD3;
	assign outputResult [11:8] = BCD2;
	assign outputResult [7:4] = BCD1;
	assign outputResult [3:0] = BCD0;
	
	//SSD display code
	wire[2:0] ssdscan_clk;
	assign ssdscan_clk = DIV_CLK[19:17];
	assign AN[0] = !( (~(ssdscan_clk[2])) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]) );
	assign AN[1] = !( (~(ssdscan_clk[2])) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]) );
	assign AN[2] = !( (~(ssdscan_clk[2])) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]) );
	assign AN[3] = !( (~(ssdscan_clk[2])) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]) );
	assign AN[4] = !( ( (ssdscan_clk[2])) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]) );
	assign AN[5] = !( ( (ssdscan_clk[2])) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]) );
	assign AN[6] = !( ( (ssdscan_clk[2])) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]) );
	assign AN[7] = !( ( (ssdscan_clk[2])) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]) );

    wire[3:0] SSD7, SSD6, SSD5, SSD4, SSD3, SSD2, SSD1, SSD0;
    
	assign SSD7 = outputResult[31:28];
	assign SSD6 = outputResult[27:24];
	assign SSD5 = outputResult[23:20];
	assign SSD4 = outputResult[19:16];
	assign SSD3 = outputResult[15:12];
	assign SSD2 = outputResult[11:8];
	assign SSD1 = outputResult[7:4];
	assign SSD0 = outputResult[3:0];
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD5, SSD6, SSD7)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
            3'b000: SSD = SSD0;
            3'b001: SSD = SSD1;
            3'b010: SSD = SSD2;
            3'b011: SSD = SSD3;
            3'b100: SSD = SSD4;
            3'b101: SSD = SSD5;
            3'b110: SSD = SSD6;
            3'b111: SSD = SSD7;
		endcase 
	end

	always @ (SSD) begin
		case (SSD)
			4'b1010: SSD_CATHODES = 7'b0001000 ; // A
			4'b1011: SSD_CATHODES = 7'b1100000 ; // B
			4'b1100: SSD_CATHODES = 7'b0110001 ; // C
			4'b1101: SSD_CATHODES = 7'b1000010 ; // D
			4'b1110: SSD_CATHODES = 7'b0110000 ; // E
			4'b1111: SSD_CATHODES = 7'b0111000 ; // F   
			4'b0000: SSD_CATHODES = 7'b0000001 ; // 0  
			4'b0001: SSD_CATHODES = 7'b1001111 ; // 1
			4'b0010: SSD_CATHODES = 7'b0010010 ; // 2   
			4'b0011: SSD_CATHODES = 7'b0000110 ; // 3   
			4'b0100: SSD_CATHODES = 7'b1001100 ; // 4   
			4'b0101: SSD_CATHODES = 7'b0100100 ; // 5  
			4'b0110: SSD_CATHODES = 7'b0100000 ; // 6  
			4'b0111: SSD_CATHODES = 7'b0001111 ; // 7  
			4'b1000: SSD_CATHODES = 7'b0000000 ; // 8  
			4'b1001: SSD_CATHODES = 7'b0001100 ; // 9  
		endcase
	end	
	
endmodule
