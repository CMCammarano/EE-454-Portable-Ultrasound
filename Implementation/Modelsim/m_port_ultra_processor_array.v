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
	input divideEnable,
	input divideFinished,
	input [32767:0] convexCloud,
	output [4095:0] convexHull1,
	output [4095:0] convexHull2,
	output [4095:0] convexHull3,
	output [4095:0] convexHull4,
	output [4095:0] convexHull5,
	output [4095:0] convexHull6,
	output [4095:0] convexHull7,
	output [4095:0] convexHull8,
	output [8:0] convexHullSize1,
	output [8:0] convexHullSize2,
	output [8:0] convexHullSize3,
	output [8:0] convexHullSize4,
	output [8:0] convexHullSize5,
	output [8:0] convexHullSize6,
	output [8:0] convexHullSize7,
	output [8:0] convexHullSize8,
	output processorDone1,
	output processorDone2,
	output processorDone3,
	output processorDone4,
	output processorDone5,
	output processorDone6,
	output processorDone7,
	output processorDone8
);

	// Wires -- processor inputs
	wire [4095:0] processorConvexCloud1;
	wire [4095:0] processorConvexCloud2;
	wire [4095:0] processorConvexCloud3;
	wire [4095:0] processorConvexCloud4;
	wire [4095:0] processorConvexCloud5;
	wire [4095:0] processorConvexCloud6;
	wire [4095:0] processorConvexCloud7;
	wire [4095:0] processorConvexCloud8;
	wire [8:0] processorConvexCloudSize1;
	wire [8:0] processorConvexCloudSize2;
	wire [8:0] processorConvexCloudSize3;
	wire [8:0] processorConvexCloudSize4;
	wire [8:0] processorConvexCloudSize5;
	wire [8:0] processorConvexCloudSize6;
	wire [8:0] processorConvexCloudSize7;
	wire [8:0] processorConvexCloudSize8;
	
	// Assign wires
	assign processorConvexCloud1 = convexCloud[4095:0];
	assign processorConvexCloud2 = convexCloud[8191:4096];
	assign processorConvexCloud3 = convexCloud[12287:8192];
	assign processorConvexCloud4 = convexCloud[16383:12288];
	assign processorConvexCloud5 = convexCloud[20479:16384];
	assign processorConvexCloud6 = convexCloud[24575:20480];
	assign processorConvexCloud7 = convexCloud[28671:24576];
	assign processorConvexCloud8 = convexCloud[32767:28672];
	assign processorConvexCloudSize1 = 9'b100000000;
	assign processorConvexCloudSize2 = 9'b100000000;
	assign processorConvexCloudSize3 = 9'b100000000;
	assign processorConvexCloudSize4 = 9'b100000000;
	assign processorConvexCloudSize5 = 9'b100000000;
	assign processorConvexCloudSize6 = 9'b100000000;
	assign processorConvexCloudSize7 = 9'b100000000;
	assign processorConvexCloudSize8 = 9'b100000000;
	
	// Declare processor unit 1
	m_port_ultra_quickhull quickhullProcessor1 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud1),
		.convexCloudSize (processorConvexCloudSize1),
		.convexPointsOutput (convexHull1),
		.convexSetSizeOutput (convexHullSize1),
		.processorDone (processorDone1)
	);
	
	// Declare processor unit 2
	m_port_ultra_quickhull quickhullProcessor2 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud2),
		.convexCloudSize (processorConvexCloudSize2),
		.convexPointsOutput (convexHull2),
		.convexSetSizeOutput (convexHullSize2),
		.processorDone (processorDone2)
	);
	
	// Declare processor unit 3
	m_port_ultra_quickhull quickhullProcessor3 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud3),
		.convexCloudSize (processorConvexCloudSize3),
		.convexPointsOutput (convexHull3),
		.convexSetSizeOutput (convexHullSize3),
		.processorDone (processorDone3)
	);
	
	// Declare processor unit 4
	m_port_ultra_quickhull quickhullProcessor4 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud4),
		.convexCloudSize (processorConvexCloudSize4),
		.convexPointsOutput (convexHull4),
		.convexSetSizeOutput (convexHullSize4),
		.processorDone (processorDone4)
	);
	
	// Declare processor unit 5
	m_port_ultra_quickhull quickhullProcessor5 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud5),
		.convexCloudSize (processorConvexCloudSize5),
		.convexPointsOutput (convexHull5),
		.convexSetSizeOutput (convexHullSize5),
		.processorDone (processorDone5)
	);
	
	// Declare processor unit 6
	m_port_ultra_quickhull quickhullProcessor6 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud6),
		.convexCloudSize (processorConvexCloudSize6),
		.convexPointsOutput (convexHull6),
		.convexSetSizeOutput (convexHullSize6),
		.processorDone (processorDone6)
	);
	
	// Declare processor unit 7
	m_port_ultra_quickhull quickhullProcessor7 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud7),
		.convexCloudSize (processorConvexCloudSize7),
		.convexPointsOutput (convexHull7),
		.convexSetSizeOutput (convexHullSize7),
		.processorDone (processorDone7)
	);
	
	// Declare processor unit 8
	m_port_ultra_quickhull quickhullProcessor8 (
		.clk (clk),
		.reset_n (reset_n),
		.processorEnable (processorEnable),
		.convexCloud (processorConvexCloud8),
		.convexCloudSize (processorConvexCloudSize8),
		.convexPointsOutput (convexHull8),
		.convexSetSizeOutput (convexHullSize8),
		.processorDone (processorDone8)
	);

endmodule
