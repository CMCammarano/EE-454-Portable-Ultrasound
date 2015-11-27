`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2015 06:38:17 PM
// Design Name: 
// Module Name: m_port_ultra
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


module m_port_ultra (	
	input clk,
	input reset_n,
	input ack,
	input [16383:0] convexCloud,
	output [4095:0] convexHull1,
	output [4095:0] convexHull2,
	output [4095:0] convexHull3,
	output [4095:0] convexHull4,
	output [8:0] convexHullSize1,
	output [8:0] convexHullSize2,
	output [8:0] convexHullSize3,
	output [8:0] convexHullSize4,
	output processorDone1,
	output processorDone2,
	output processorDone3,
	output processorDone4,
	output QINIT,
	output QPULSE,
	output QDIVIDE,
	output QCONVEX_HULL,
	output QDISPLAY
);

	// Registers -- State machine intermediate values
	reg [3:0] timer;
	reg processorEnable;
	reg divideEnable;
	reg divideFinished;
	
	// Module declaration
	m_port_ultra_processor_array processorArray (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.divideEnable (divideEnable),
		.divideFinished (divideFinished),
		.convexCloud (convexCloud),
		.convexHull1 (convexHull1),
		.convexHull2 (convexHull2),
		.convexHull3 (convexHull3),
		.convexHull4 (convexHull4),
		.convexHullSize1 (convexHullSize1),
		.convexHullSize2 (convexHullSize2),
		.convexHullSize3 (convexHullSize3),
		.convexHullSize4 (convexHullSize4),
		.processorDone1 (processorDone1),
		.processorDone2 (processorDone2),
		.processorDone3 (processorDone3),
		.processorDone4 (processorDone4)
	);
	
	// State Machine
	reg[4:0] state;

	localparam 
		INIT			=	5'b00001,
		PULSE			= 	5'b00010,
		DIVIDE			= 	5'b00100,
		CONVEX_HULL		= 	5'b01000,
		DISPLAY			= 	5'b10000;
		
	// Processor output
	assign { QDISPLAY, QCONVEX_HULL, QDIVIDE, QPULSE, QINIT } = state;
	
	//NSL and State Machine
	always @(posedge clk, negedge reset_n) begin
		
		if (!reset_n) begin
			
			timer <= 0;
			processorEnable <= 0;
			divideEnable <= 0;
			divideFinished <= 0;
			
			state <= INIT;
		end
		
		else begin
			case (state)
				INIT: begin
					
					timer <= 0;
					
					if (ack) begin
						state <= PULSE;
					end
				end
			
				PULSE: begin
					
					timer <= timer + 1;
				
					if (timer >= 9) begin
						divideEnable <= 1'b1;
						state <= DIVIDE;
					end
				end
				
				DIVIDE: begin
					
					processorEnable <= 1;
					state <= CONVEX_HULL;
				end
				
				CONVEX_HULL: begin 
					
					if (processorDone1 && processorDone2 && processorDone3 && processorDone4) begin
						state <= DISPLAY;
					end
				end
				
				DISPLAY: begin
				
					if (ack) begin
						state <= INIT;
					end
				end	
			endcase
		end 
	end

endmodule
