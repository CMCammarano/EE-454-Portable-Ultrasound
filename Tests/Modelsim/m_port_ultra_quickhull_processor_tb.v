`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:12:24 10/05/2015
// Design Name:   quickhull.v
// 
////////////////////////////////////////////////////////////////////////////////

module m_quickhull_tb;

	// Inputs
	reg CLK100MHZ;
	reg CPU_RESETN;
	reg [4095:0] points;
	reg [7:0] SS;

	// Outputs
	wire [4095:0] convexPoints;
	wire [7:0] convexSetSize;
	wire [7:0] positiveCrossCount;
	wire [31:0] crossValue;
	wire [15:0] lnIndex;
	wire [7:0] ptCount;
	wire [31:0] currLine;
	wire [15:0] currPoint;
	wire [15:0] furthest;
	wire [15:0] xMinPoint;
	wire [15:0] xMaxPoint;
	wire signed [31:0] furthestCrossValue;

	wire QINITIAL, QFIND_MAX, QFIND_MIN, QHULL_START, QCROSS, QHULL_RECURSE, QEND;
	// File
	integer file_results;

	// Parameters
	parameter CLK_PERIOD = 20;

	// Instantiate the Unit Under Test (UUT)
	m_port_ultra_quickhull_processor UUT(
		//Inputs
		.CLK100MHZ(CLK100MHZ),
		.CPU_RESETN(CPU_RESETN),
		.SS(SS),
		.points(points),
		//Outputs
		.convexPoints(convexPoints),
		.convexSetSizeOutput(convexSetSize),
		.positiveCrossCountOutput(positiveCrossCount),
		.crossValueOutput(crossValue),
		.lnIndexOutput(lnIndex),
		.ptCountOutput(ptCount),
		.currentLineOutput(currLine),
		.currentPointOutput(currPoint),
		.furthestOutput(furthest),
		.furthestCrossValueOutput(furthestCrossValue),
		.xMinPointOutput(xMinPoint),
		.xMaxPointOutput(xMaxPoint),
		.QINITIAL(QINITIAL),
		.QFIND_MAX(QFIND_MAX),
		.QFIND_MIN(QFIND_MIN),
		.QHULL_START(QHULL_START),
		.QCROSS(QCROSS),
		.QHULL_RECURSE(QHULL_RECURSE),
		.QEND(QEND)
	);


	initial begin : CLOCK_GENERATOR
		CLK100MHZ = 0;
		
		forever begin
			# (CLK_PERIOD / 2) CLK100MHZ = ~CLK100MHZ;
		end
	end	
		
	integer counter;
	
	initial begin : STIMULUS
		
		//file_results = $fopen("output_results.txt", "w");

		// Initialize Inputs
		// === Small input: 15 points ===
	
		//SS = 16;
		//SS = 32;
		//SS = 64;
		//SS = 256;
		
		points = 4096'b;
		points = 4096'b;
		points = 4096'b;
		points = 4096'b;
		
		// Wait for global reset to finish
		#100;
				
		// Generate a reset
		CPU_RESETN = 0;	#20;
		CPU_RESETN = 1;	#20;
		
		// Give a long time for machine to finish
		//#8000;
		//32000;
		#500000;
		
		// Wait for global reset to finish
		#100;

	end
		  
endmodule

