//`timescale 1 ns / 100 ps

module m_port_ultra_quickhull
(
	input clk,
	input reset_n,
	input processorEnable,
	input [4095:0] convexCloud,				//4096 / (8 * 2) = 256 convexCloud in each set
	input [8:0] convexCloudSize,
	output [4095:0] convexPointsOutput,
	output [8:0] convexSetSizeOutput,
	output processorDone
);		//Same as convexCloud, 256 convexCloud

	// Variables
	localparam PTSIZE = 16;					//Point Size: 16 bits long, two 8 bit dimensions
	localparam LNSIZE = 32;					//Line Size = 2 coordinates:  32 bits long
	// localparam convexCloudSize = 256;					//Set Size, need to count up to 256 = 8 bits
	reg [LNSIZE * 256 - 1 : 0] lineFIFO;	//32 bits * number of convexCloud, just to be safe (100 convexCloud)
	reg [15:0] lnIndex;					//Line Index: only need 13 bits, but 16 just in case
	reg [15:0] cxIndex;					//Convex Index;only need 12 bits, but 16 just in case
	reg [15:0] ptIndex;
	reg [8:0] ptCount;
	reg [4096:0] convexPoints;
	reg [8:0] convexSetSize;

	reg [PTSIZE - 1 : 0] xMinPoint;
	reg [PTSIZE - 1 : 0] xMaxPoint;
	reg [LNSIZE:0] line;
	reg [8:0] positiveCrossCount;
	
	reg [PTSIZE - 1 : 0] furthest;
	reg [PTSIZE - 1 : 0] currPoint;
	reg [(PTSIZE / 2) - 1 : 0] currPoint_X;
	reg [(PTSIZE / 2) - 1 : 0] currPoint_Y;
	reg [LNSIZE - 1 : 0] currLine;
	reg [PTSIZE - 1 : 0] currLine_A;
	reg [(PTSIZE / 2) - 1 : 0] currLine_AX;
	reg [(PTSIZE / 2) - 1 : 0] currLine_AY;
	reg [PTSIZE - 1 : 0] currLine_B;
	reg [(PTSIZE / 2) - 1 : 0] currLine_BX;
	reg [(PTSIZE / 2) - 1 : 0] currLine_BY;
	reg signed [31:0] crossValue;
	reg signed [31:0] furthestCrossValue;
	reg [LNSIZE - 1: 0] nextLineAddr;
	reg [LNSIZE - 1: 0] nextLineAddr2;
	reg [PTSIZE - 1: 0] nextCXAddr;
	reg [PTSIZE - 1: 0] nextCXAddr2;

	reg furthestFlag;
	reg done;
	
	// Output assignment
	assign convexSetSizeOutput = convexSetSize;
	assign convexPointsOutput = convexPoints;
	assign processorDone = done;

	// State Machine Implementation
	reg[6:0] state;

	assign { QEND, QHULL_RECURSE, QCROSS, QHULL_START, QFIND_MIN, QFIND_MAX, QINITIAL } = state;
	
	localparam 
		INITIAL			=	7'b0000001,
		FIND_XMAX		=	7'b0000010,
		FIND_XMIN		=	7'b0000100,
		HULL_START		=	7'b0001000,
		CROSS 			= 	7'b0010000, 
		HULL_RECURSE	=	7'b0100000,
		END 			=	7'b1000000;

	// For loop integers
	integer i;
	integer j;

	generate
		always @(clk) begin
			j = 0;
			for (i = ptIndex; i < ptIndex + PTSIZE; i = i + 1) begin
				currPoint[j] = convexCloud[i];
				j = j + 1;
			end
		end
	endgenerate
	
	generate
		always @(clk) begin
			j = 0;
			for (i = ptIndex; i < ptIndex + (PTSIZE / 2); i = i + 1) begin
				currPoint_X[j] = convexCloud[i];
				j = j + 1;
			end
		end
	endgenerate
			
	generate
		always @(clk) begin
			j = 0;
			for (i = ptIndex + (PTSIZE / 2); i < ptIndex + PTSIZE; i = i + 1) begin
				currPoint_Y[j] = convexCloud[i];
				j = j + 1;
			end
		end
	endgenerate
			
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
				currLine[j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
	
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex; i < lnIndex + (LNSIZE/2); i = i + 1) begin
				currLine_A[j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
		
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex; i < lnIndex + (PTSIZE/2); i = i + 1) begin
				currLine_AX[j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
		
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex + (PTSIZE / 2); i < lnIndex + PTSIZE; i = i + 1) begin
				currLine_AY[j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
			
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex + (LNSIZE/2); i < lnIndex + LNSIZE; i = i + 1) begin
				currLine_B [j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
		
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex + PTSIZE; i < lnIndex + LNSIZE - (PTSIZE/2); i = i + 1) begin
				currLine_BX[j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
	
	generate
		always @(clk) begin
			j = 0;
			for (i = lnIndex + LNSIZE - (PTSIZE / 2); i < lnIndex + LNSIZE; i = i + 1) begin
				currLine_BY[j] = lineFIFO[i];
				j = j + 1;
			end
		end
	endgenerate
	
	//NSL, register assignents, and State Machine
	always @(posedge clk, negedge reset_n) begin
		
		ptIndex = PTSIZE * ptCount;
		crossValue = (((currLine_AX - currPoint_X) * (currLine_BY - currPoint_Y)) - ((currLine_AY - currPoint_Y) * (currLine_BX - currPoint_X)));
	
		if (!reset_n) begin
			//Reset
			state <= INITIAL;
		end
		case (state)
			INITIAL: begin
				// State Logic
				lineFIFO <= 0;
				lnIndex <= 32;
				cxIndex <= 0;
				line <= 0;
				ptIndex <= 0;
				ptCount <= 0;
				positiveCrossCount <= 0;
				xMinPoint <= 0;
				xMaxPoint <= 0;
				crossValue <= 0;
				furthest <= 0;
				furthestCrossValue <= 0;
				furthestFlag <= 0;
				convexSetSize <= 0;
				convexPoints <= 0;
				done <= 0;
				
				// NSL
				if (processorEnable) begin
					state <= FIND_XMAX;
				end

			end

			FIND_XMAX: begin
				//State Logic
				if (ptCount == 0) begin
					xMaxPoint <= currPoint;
				end
				else begin
					if (xMaxPoint < currPoint) begin
						xMaxPoint <= currPoint;
					end
					else begin
						//Do nothing
					end
				end

				//NSL
				if (ptCount != (convexCloudSize - 1)) begin
					ptCount <= ptCount + 1;
					state <= FIND_XMAX;			
				end
				else begin
					ptCount <= 0;
					state <= FIND_XMIN;
				end
			end

			FIND_XMIN: begin
				//State Logic
				if (ptCount == 0) begin
					xMinPoint <= currPoint;
				end
				else begin
					if (xMinPoint > currPoint) begin
						xMinPoint <= currPoint;
					end
					else begin
						//Do nothing
					end
				end

				//NSL
				if (ptCount != (convexCloudSize - 1)) begin
					ptCount <= ptCount + 1;
					state <= FIND_XMIN;					
				end
				else begin
					ptCount <= 0;
					state <= HULL_START;
				end
			end

			HULL_START: begin
				// State Logic
				nextLineAddr = {xMinPoint, xMaxPoint};
				j = 0;
				for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
					lineFIFO[i] = nextLineAddr[j];
					j = j + 1;
				end
				
				nextLineAddr2 = {xMaxPoint, xMinPoint};
				j = 0;
				for (i = lnIndex + LNSIZE; i < lnIndex + (LNSIZE * 2); i = i + 1) begin
					lineFIFO[i] = nextLineAddr2[j];
					j = j + 1;
				end				
				lnIndex <= lnIndex + LNSIZE;
				
				// NSL
				ptCount <= 0;
				state <= CROSS;
			end

			CROSS: begin
				//State Logic
				//if (crossValue > 0) begin
				if (crossValue > 0 && ptCount != (convexCloudSize)) begin
					positiveCrossCount <= positiveCrossCount + 1;
					if (furthestFlag == 0) begin
						furthestCrossValue <= crossValue;
						furthest <= currPoint;
						furthestFlag <= 1;
					end
					else begin
						if (furthestCrossValue < crossValue) begin
							furthestCrossValue <= crossValue;
							furthest <= currPoint;
						end
					end
				end

				//NSL
				if (ptCount != (convexCloudSize)) begin
					ptCount <= ptCount + 1;
					state <= CROSS;
				end
				else begin
					ptCount <= 0;
					furthestFlag <= 0;
					state <= HULL_RECURSE;
				end

			end
			
			HULL_RECURSE: begin 
				// State Logic

				//TODO: get number of positive cross and furthest point
				if (positiveCrossCount == 1 && lnIndex != 0) begin
					nextCXAddr = currLine_A;
					j = 0;
					for (i = cxIndex; i < cxIndex + PTSIZE; i = i + 1) begin
						convexPoints[i] = nextCXAddr[j];
						j = j + 1;
					end
					nextCXAddr2 = furthest;
					j = 0;
					for (i = cxIndex + PTSIZE; i < cxIndex + (PTSIZE * 2); i = i + 1) begin
						convexPoints[i] = nextCXAddr2[j];
						j = j + 1;
					end
					cxIndex <= cxIndex + (2 * PTSIZE);
					convexSetSize <= convexSetSize + 2;
					
					lnIndex <= lnIndex - LNSIZE;
				end
				else if (positiveCrossCount == 0 && lnIndex != 0) begin
					nextCXAddr = currLine_A;
					j = 0;
					for (i = cxIndex; i < cxIndex + PTSIZE; i = i + 1) begin
						convexPoints[i] = nextCXAddr[j];
						j = j + 1;
					end
					cxIndex <= cxIndex + PTSIZE;
					convexSetSize <= convexSetSize + 1;

					lnIndex <= lnIndex - LNSIZE;
				end
				else begin
					nextLineAddr 	= {furthest, currLine_A};
					nextLineAddr2	= {currLine_B, furthest};
					
					j = 0;
					for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
						lineFIFO[i] = nextLineAddr[j];
						j = j + 1;
					end
					
					j = 0;
					for (i = lnIndex + LNSIZE; i < lnIndex + (LNSIZE * 2); i = i + 1) begin
						lineFIFO[i] = nextLineAddr2[j];
						j = j + 1;
					end						
					lnIndex <= lnIndex + LNSIZE;
				end
				// NSL
				if ((lnIndex) != 0) begin
					positiveCrossCount <= 0;
					furthest <= 0;
					furthestCrossValue <= 0;
					ptCount <= 0;
					state <= CROSS;
				end
				else begin
					done <= 1;
					state <= END;
				end
			end

			END: begin
				//Wait
			end

		endcase
	end

endmodule  

