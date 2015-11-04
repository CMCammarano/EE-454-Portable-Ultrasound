Initial
	Initialize all variables
	lineArray = [lineSize * setSize : 0];
	lineIndex = 0 

	convexPoints = [pointSize * setSize : 0]
	convexIndex = 0;

HullStart
	lineArray [lineIndex + lineSize - 1 : lineIndex] <= {FindXMin, FindXMax}
	lineArray [lineIndex + (2 * lineSize) - 1 : (2 * lineIndex)] <= {FindXMax, FindXMin}
	lineIndex += 2 * lineSize

HullRecurse (lineIndex != 0)
	line <= lineArray[lineIndex - 1 : lineIndex - lineSize]

	if (PositiveCross == 1)
		convexPoints[convexIndex + pointSize - 1: convexIndex] <= line[3:0]
		convexPoints[convexIndex + (2 * pointSize) - 1 : (2 * pointIndex)] <= FindFurthestPoint
		convexIndex += 2 * pointSize
		lineIndex -= lineSize
	else if (PositiveCross == 0)
		convexPoints[convexIndex + pointSize - 1: convexIndex] <= line[3:0]
		convexIndex += pointIndex
		lineIndex -= lineSize
	else
		furthestPoint <= FindFurthestPoint
		lineArray [lineIndex - 1 : lineIndex - lineSize] <= {line[3:0], furthestPoint}
		lineArray [lineIndex + lineSize - 1 : lineIndex] <= {furthestPoint, line[7:4]}
		lineIndex += lineSize


Global Variables
	pointSize
	lineSize <= pointSize * 2

Modules
	FindXMin
	FindXMax
	PositiveCross
	FindFurthestPoint
	CrossProduct