//`timescale 1 ns / 100 ps

module ALU (input CLK100MHZ,
	input [4095:0] points,				//4096 / (8 * 2) = 256 points in each set
	output [4095:0] convexPoints,
	output [7:0] convexSetSize,
	input CPU_RESETN);		//Same as points, 256 points

	// Variables
	localparam PTSIZE = 16;					//Point Size: 16 bits long, two 8 bit dimensions
	localparam LNSIZE = 32;					//Line Size = 2 coordinates:  32 bits long
	localparam SS = 256;					//Set Size, need to count up to 256 = 8 bits
	reg [LNSIZE * SS : 0] lineFIFO;	//32 bits * number of points, just to be safe (100 points)
	reg [15:0] lnIndex;					//Line Index: only need 13 bits, but 16 just in case
	reg [15:0] cxIndex;					//Convex Index;only need 12 bits, but 16 just in case
	reg [7:0] ptIndex;
	reg [7:0] ptCount;

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

	integer i = 0;
	integer j = 0;
	always @ (posedge CLK100MHZ) begin
		ptIndex = PTSIZE * ptCount;

		for (i = ptIndex; i < ptIndex + PTSIZE; i = i + 1) begin
			currPoint[j] = lineFIFO[i];
			j = j + 1;
		end
	
		currPoint_X = lineFIFO[ptIndex + (PTSIZE / 2) - 1 : ptIndex];
		currPoint_Y = lineFIFO[ptIndex + PTSIZE - 1 : ptIndex + (PTSIZE / 2)];

		currLine = lineFIFO[lnIndex + LNSIZE - 1 : lnIndex];
		currLine_A = lineFIFO[lnIndex + (LNSIZE/2) - 1 : lnIndex];
		currLine_AX = lineFIFO[lnIndex + (PTSIZE/2) - 1 : lnIndex];
		currLine_AY = lineFIFO[lnIndex + PTSIZE - 1 : lnIndex + (PTSIZE / 2)];

		currLine_B 	= lineFIFO[lnIndex + LNSIZE - 1 : lnIndex + (LNSIZE/2)];
		currLine_BX = lineFIFO[lnIndex + LNSIZE - (PTSIZE/2) - 1 : lnIndex + PTSIZE];
		currLine_BY = lineFIFO[lnIndex + LNSIZE - 1 : lnIndex + LNSIZE - (PTSIZE / 2)];

		nextLineAddr = lineFIFO[lnIndex + LNSIZE - 1 : lnIndex];
		nextLineAddr2 = lineFIFO[lnIndex + (LNSIZE * 2) - 1 : lnIndex + LNSIZE];
		nextCXAddr 	= convexPoints[cxIndex + PTSIZE - 1: cxIndex];
		nextCXAddr2 = convexPoints[cxIndex + (PTSIZE * 2) - 1: cxIndex + PTSIZE];
		
		crossValue = (((currLine_AX - currPoint_X) * (currLine_BY - currPoint_Y)) - ((currLine_AY - currPoint_Y) * (currLine_BX - currPoint_X)));
	end
	// Clock Slow
	reg [26:0] DIV_CLK;
	

	// State Machine Implementation
	reg[6:0] state;

	localparam 
		INITIAL			=	7'b0000001,
		FIND_XMAX		=	7'b0000010,
		FIND_XMIN		=	7'b0000100,
		HULL_START		=	7'b0001000,
		CROSS 			= 	7'b0010000, 
		HULL_RECURSE	=	7'b0100000,
		END 			=	7'b1000000;

	// Clock Divider
	always @(posedge CLK100MHZ, negedge CPU_RESETN) begin							
		if (!CPU_RESETN) begin
			DIV_CLK <= 0;
		end
		
		else begin
			DIV_CLK <= DIV_CLK + 1'b1;
		end
	end

	//NSL and State Machine
	always @(posedge DIV_CLK[1:0]) begin
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
					state <= FIND_XMAX;					
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
				state <= HULL_RECURSE;
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
				if ((lnIndex - LNSIZE) != 0) begin
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

