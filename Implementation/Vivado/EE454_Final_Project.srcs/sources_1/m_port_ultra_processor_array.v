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


module m_port_ultra_processor_array (
	input clk,
	input reset_n,
	input processorEnable,
	input [8191:0] convexCloud,
	output [4095:0] convexHull1,
	output [4095:0] convexHull2,
	output [7:0] convexHullSize1,
	output [7:0] convexHullSize2
);

	// Wires -- processor inputs
	wire [4095:0] processorConvexCloud1;
	wire [4095:0] processorConvexCloud2;
	wire [8:0] processorConvexCloudSize1;
	wire [8:0] processorConvexCloudSize2;
	
	// Declare processor unit 1
	m_port_ultra_quickhull quickhullProcessor1 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.points (processorConvexCloud1),
		.size (processorConvexCloudSize1),
		.convexPointsOutput (convexHull1),
		.convexSetSizeOutput (convexHullSize1)
	);
	
	// Declare processor unit 2
	m_port_ultra_quickhull quickhullProcessor2 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.points (processorConvexCloud2),
		.size (processorConvexCloudSize2),
		.convexPointsOutput (convexHull2),
		.convexSetSizeOutput (convexHullSize2)
	);


endmodule
