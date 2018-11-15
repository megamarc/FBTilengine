static shared as integer sintable(360-1)
static shared as integer costable(360-1)

sub BuildSinTable()	
	for c as integer = 0 to (360-1)
        sintable(c) = int(sin(c*M_PI/180)*256)
		costable(c) = int(cos(c*M_PI/180)*256)
    next c
end sub

function CalcSin (angle as integer, factor as integer) as integer
	dim ival as integer
    
	if (angle > 359) then angle mod= 360		
    
	ival = (sintable(angle)*factor) shr 8
    
	return ival
end function

function CalcCos (angle as integer, factor as integer) as integer
	dim ival as integer
    
	if (angle > 359) then angle = angle mod 360		
    
	ival = (costable(angle)*factor) shr 8
    
	return ival
end function
