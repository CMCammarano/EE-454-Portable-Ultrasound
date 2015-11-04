//`timescale 1 ns / 100 ps

module ALU (input CLK100MHZ,
	input [4095:0] points,				//4096 / (8 * 2) = 256 points in each set
	input [7:0] SS,						//Set Size, need to count up to 256 = 8 bits
	output [4095:0] convexPoints,
	output [7:0] convexSetSize,
	input RESET_NEG)		//Same as points, 256 points

	// Variables
	assign PTSIZE = 16;					//Point Size: 16 bits long, two 8 bit dimensions
	assign LNSIZE = 32;					//Line Size = 2 coordinates:  32 bits long
	reg lineFIFO [LNSIZE * SS : 0];	//32 bits * number of points, just to be safe (100 points)
	reg lnIndex [15:0];					//Line Index: only need 13 bits, but 16 just in case
	reg cxIndex [15:0];					//Convex Index;only need 12 bits, but 16 just in case
	wire ptIndex [7:0];
	reg ptCount [7:0];

	reg xMinPoint [PTSIZE - 1 : 0];
	reg xMaxPoint [PTSIZE - 1 : 0];
	reg line [LNSIZE:0];
	reg positiveCrossCount [7:0];
	
	wire currPoint		[PTSIZE - 1 : 0];
	wire currPoint_X	[(PTSIZE / 2) - 1 : 0];
	wire currPoint_Y	[(PTSIZE / 2) - 1 : 0];
	wire currLine		[LNSIZE - 1 : 0];
	wire currLine_A		[PTSIZE - 1 : 0];
	wire currLine_AX	[(PTSIZE / 2) - 1 : 0];
	wire currLine_AY	[(PTSIZE / 2) - 1 : 0];
	wire currLine_B		[PTSIZE - 1 : 0];
	wire currLine_BX	[(PTSIZE / 2) - 1 : 0];
	wire currLine_BY	[(PTSIZE / 2) - 1 : 0];
	wire crossValue 	[15:0];
	wire nextLineAddr	[LNSIZE - 1: 0];
	wire nextLineAddr2	[LNSIZE - 1: 0];
	wire nextCXAddr		[PTSIZE - 1: 0];
	wire nextCXAddr2	[PTSIZE - 1: 0];

	reg furthestFlag;

	assign ptIndex 		= PTSIZE * ptCount;

	assign currPoint   	= lineFIFO[ptIndex + PTSIZE - 1 				: ptIndex];
	assign currPoint_X 	= lineFIFO[ptIndex + (PTSIZE / 2) - 1  			: ptIndex];
	assign currPoint_Y 	= lineFIFO[ptIndex + PTSIZE - 1 				: ptIndex + (PTSIZE / 2)];

	assign currLine 	= lineFIFO[lnIndex + LNSIZE - 1 				: lnIndex];
	assign currLine_A 	= lineFIFO[lnIndex + (LNSIZE/2) - 1 			: lnIndex];
	assign currLine_AX 	= lineFIFO[lnIndex + (PTSIZE/2) - 1 			: lnIndex];
	assign currLine_AY 	= lineFIFO[lnIndex + PTSIZE - 1 				: lnIndex + (PTSIZE / 2)];

	assign currLine_B 	= lineFIFO[lnIndex + LNSIZE - 1 				: lnIndex + (LNSIZE/2)];
	assign currLine_BX 	= lineFIFO[lnIndex + LNSIZE - (PTSIZE/2) - 1 	: lnIndex + PTSIZE];
	assign currLine_BY 	= lineFIFO[lnIndex + LNSIZE - 1 				: lnIndex + LNSIZE - (PTSIZE / 2)];

	assign nextLineAddr = lineFIFO[lnIndex + LNSIZE - 1 : lnIndex];
	assign nextLineAddr2= lineFIFO[lnIndex + (LNSIZE * 2) - 1 : lnIndex + LNSIZE];
	assign nextCXAddr 	= convexPoints[cxIndex + PTSIZE - 1: cxIndex];
	assign nextCXAddr2 	= convexPoints[cxIndex + (PTSIZE * 2) - 1: cxIndex + PTSIZE];

	assign crossValue 	= (((currLine_AX - currPoint_X) * (currLine_BY - currPoint_Y)) - ((currLine_AY - currPoint_Y) * (currLine_BX - currLine_X)));

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
		if (!RESET_NEG) begin
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
					state <= FIND_MIN;
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
					state <= FIND_XMAX					
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
				if (cross > 0) begin
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
					nextCXAddr2 <= furthestPoint;
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
					nextLineAddr 	<= {currLine_A, furthestPoint};
					nextLineAddr2	<= {furthestPoint, point_B};
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

