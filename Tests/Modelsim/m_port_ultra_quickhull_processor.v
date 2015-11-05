//`timescale 1 ns / 100 ps

module m_port_ultra_quickhull_processor (input CLK100MHZ,
	input reg [4095:0] points,				//4096 / (8 * 2) = 256 points in each set
	input reg [7:0] SS,
	output reg [4095:0] convexPoints,
	output [7:0] convexSetSizeOutput,
	output [7:0] positiveCrossCountOutput,
	output [15:0] crossValueOutput,
	output QINITIAL, QFIND_MAX, QFIND_MIN, QHULL_START, QCROSS, QHULL_RECURSE, QEND,
	input CPU_RESETN);		//Same as points, 256 points

	// Variables
	localparam PTSIZE = 16;					//Point Size: 16 bits long, two 8 bit dimensions
	localparam LNSIZE = 32;					//Line Size = 2 coordinates:  32 bits long
	// localparam SS = 256;					//Set Size, need to count up to 256 = 8 bits
	reg [LNSIZE * 256 : 0] lineFIFO;	//32 bits * number of points, just to be safe (100 points)
	reg [15:0] lnIndex;					//Line Index: only need 13 bits, but 16 just in case
	reg [15:0] cxIndex;					//Convex Index;only need 12 bits, but 16 just in case
	reg [7:0] ptIndex;
	reg [7:0] ptCount;
	reg [7:0] convexSetSize;

	reg [PTSIZE - 1 : 0] xMinPoint;
	reg [PTSIZE - 1 : 0] xMaxPoint;
	reg [LNSIZE:0] line;
	reg [7:0] positiveCrossCount;
	
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
	reg [15:0] crossValue;
	reg [LNSIZE - 1: 0] nextLineAddr;
	reg [LNSIZE - 1: 0] nextLineAddr2;
	reg [PTSIZE - 1: 0] nextCXAddr;
	reg [PTSIZE - 1: 0] nextCXAddr2;

	reg furthestFlag;
	
	assign convexSetSizeOutput = convexSetSize;
	assign positiveCrossCountOutput = positiveCrossCount;
	assign crossValueOutput = crossValue;

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
	integer i = 0;
	integer j = 0;
	
	/*
	always @(posedge CLK100MHZ) begin
	
		ptIndex = PTSIZE * ptCount;

		for (i = ptIndex; i < ptIndex + PTSIZE; i = i + 1) begin
			currPoint[j] = points[i];
			j = j + 1;
		end
	
		for (i = ptIndex; i < ptIndex + (PTSIZE / 2); i = i + 1) begin
			currPoint_X[j] = points[i];
			j = j + 1;
		end
			
		for (i = ptIndex + (PTSIZE / 2); i < ptIndex + PTSIZE; i = i + 1) begin
			currPoint_Y[j] = points[i];
			j = j + 1;
		end
			

		for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
			currLine[j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = lnIndex; i < lnIndex + (LNSIZE/2); i = i + 1) begin
			currLine_A[j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = lnIndex; i < lnIndex + (PTSIZE/2); i = i + 1) begin
			currLine_AX[j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = lnIndex + (PTSIZE / 2); i < lnIndex + PTSIZE; i = i + 1) begin
			currLine_AY[j] = lineFIFO[i];
			j = j + 1;
		end
			

		for (i = lnIndex + (LNSIZE/2); i < lnIndex + LNSIZE; i = i + 1) begin
			currLine_B [j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = lnIndex + PTSIZE; i < lnIndex + LNSIZE - (PTSIZE/2); i = i + 1) begin
			currLine_BX[j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = lnIndex + LNSIZE - (PTSIZE / 2); i < lnIndex + LNSIZE; i = i + 1) begin
			currLine_BY[j] = lineFIFO[i];
			j = j + 1;
		end

		for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
			nextLineAddr[j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = lnIndex + LNSIZE; i < lnIndex + (LNSIZE * 2); i = i + 1) begin
			nextLineAddr2[j] = lineFIFO[i];
			j = j + 1;
		end
			
		for (i = cxIndex; i < cxIndex + PTSIZE; i = i + 1) begin
			nextCXAddr [j] = points[i];
			j = j + 1;
		end
			
		for (i = cxIndex + PTSIZE; i < cxIndex + (PTSIZE * 2); i = i + 1) begin
			nextCXAddr2[j] = points[i];
			j = j + 1;
		end
			
		crossValue = (((currLine_AX - currPoint_X) * (currLine_BY - currPoint_Y)) - ((currLine_AY - currPoint_Y) * (currLine_BX - currPoint_X)));
	end
	*/
	
	//NSL, register assignents, and State Machine
	always @(posedge CLK100MHZ, negedge CPU_RESETN) begin
		
		ptIndex = PTSIZE * ptCount;

		j = 0;
		for (i = ptIndex; i < ptIndex + PTSIZE; i = i + 1) begin
			currPoint[j] = points[i];
			j = j + 1;
		end
	
		j = 0;
		for (i = ptIndex; i < ptIndex + (PTSIZE / 2); i = i + 1) begin
			currPoint_X[j] = points[i];
			j = j + 1;
		end
			
		j = 0;
		for (i = ptIndex + (PTSIZE / 2); i < ptIndex + PTSIZE; i = i + 1) begin
			currPoint_Y[j] = points[i];
			j = j + 1;
		end
			
		j = 0;
		for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
			currLine[j] = lineFIFO[i];
			j = j + 1;
		end
			
		j = 0;
		for (i = lnIndex; i < lnIndex + (LNSIZE/2); i = i + 1) begin
			currLine_A[j] = lineFIFO[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = lnIndex; i < lnIndex + (PTSIZE/2); i = i + 1) begin
			currLine_AX[j] = lineFIFO[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = lnIndex + (PTSIZE / 2); i < lnIndex + PTSIZE; i = i + 1) begin
			currLine_AY[j] = lineFIFO[i];
			j = j + 1;
		end
			
		j = 0;
		for (i = lnIndex + (LNSIZE/2); i < lnIndex + LNSIZE; i = i + 1) begin
			currLine_B [j] = lineFIFO[i];
			j = j + 1;
		end
			
		j = 0;
		for (i = lnIndex + PTSIZE; i < lnIndex + LNSIZE - (PTSIZE/2); i = i + 1) begin
			currLine_BX[j] = lineFIFO[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = lnIndex + LNSIZE - (PTSIZE / 2); i < lnIndex + LNSIZE; i = i + 1) begin
			currLine_BY[j] = lineFIFO[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = lnIndex; i < lnIndex + LNSIZE; i = i + 1) begin
			nextLineAddr[j] = lineFIFO[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = lnIndex + LNSIZE; i < lnIndex + (LNSIZE * 2); i = i + 1) begin
			nextLineAddr2[j] = lineFIFO[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = cxIndex; i < cxIndex + PTSIZE; i = i + 1) begin
			nextCXAddr [j] = points[i];
			j = j + 1;
		end
		
		j = 0;
		for (i = cxIndex + PTSIZE; i < cxIndex + (PTSIZE * 2); i = i + 1) begin
			nextCXAddr2[j] = points[i];
			j = j + 1;
		end
			
		crossValue = (((currLine_AX - currPoint_X) * (currLine_BY - currPoint_Y)) - ((currLine_AY - currPoint_Y) * (currLine_BX - currPoint_X)));
	
		if (!CPU_RESETN) begin
			//Reset
			state <= INITIAL;
		end
		case (state)
			INITIAL: begin
				// State Logic
				lineFIFO <= 0;
				lnIndex <= 0;
				cxIndex <= 0;
				line <= 0;
				ptIndex <= 0;
				ptCount <= 0;
				positiveCrossCount <= 0;
				xMinPoint <= 0;
				xMaxPoint <= 0;
				crossValue <= 0;
				furthestFlag <= 0;
				convexSetSize <= 0;
				convexPoints <= 0;
				// NSL
				state <= FIND_XMAX;

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
				if (ptCount != (SS - 1)) begin
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
				if (ptCount != (SS - 1)) begin
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
				nextLineAddr  <= {xMinPoint, xMaxPoint};
				nextLineAddr2 <= {xMaxPoint, xMinPoint};
				lnIndex <= lnIndex + LNSIZE;
				
				// NSL
				ptCount <= 0;
				state <= CROSS;
			end

			CROSS: begin
				//State Logic
				if (crossValue > 0) begin
					positiveCrossCount <= positiveCrossCount + 1;
					if (furthestFlag == 0) begin
						furthest <= currPoint;
						furthestFlag <= 1;
					end
					else begin
						if (furthest < currPoint) begin
							furthest <= currPoint;
						end
					end
				end

				//NSL
				if (ptCount != (SS - 1)) begin
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
				if (positiveCrossCount == 1) begin
					nextCXAddr <= currLine_A;
					nextCXAddr2 <= furthest;
					cxIndex <= cxIndex + (2 * PTSIZE);
					convexSetSize <= convexSetSize + 2;

					nextLineAddr <= 0;
					lnIndex <= lnIndex - LNSIZE;
				end
				else if (positiveCrossCount == 0) begin
					nextCXAddr <= currLine_A;
					cxIndex <= cxIndex + PTSIZE;
					convexSetSize <= convexSetSize + 1;

					nextLineAddr <= 0;
					lnIndex <= lnIndex - LNSIZE;
				end
				else begin
					nextLineAddr 	<= {currLine_A, furthest};
					nextLineAddr2	<= {furthest, currLine_B};
					lnIndex <= lnIndex + LNSIZE;
				end
				// NSL
				if ((lnIndex) != 0) begin
					state <= CROSS;
				end
				else begin
					state <= END;
				end
			end

			END: begin
				//Wait
			end

		endcase
	end

endmodule  

