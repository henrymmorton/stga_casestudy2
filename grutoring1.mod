set Shifts;
set Grutors;
set Students;

param sPref{Students, Shifts} binary;
param gPref{Grutors, Shifts} integer;
param studPenalty >= 0;
param grutPenalty >= 0;
param budget >=0;
param costPerShift >= 0;
param maxGrut integer;
param maxShift integer;
param studPerGrut;

# Get number of students who want to be in each shift
param stud{t in Shifts} = sum{s in Students} sPref[s, t];

var x{Grutors, Shifts};
var grut{Shifts};
var numShiftsGrut{Grutors};

minimize objFunc:
	sum{t in Shifts} (stud[t] - grut[t]*studPerGrut); 

subject to grutInEachShift{t in Shifts}:
	sum{g in Grutors} x[g, t] = grut[t];
	
subject to numShiftEachGrut{g in Grutors}:
	sum{t in Shifts} x[g, t] = numShiftsGrut[g];
	
subject to shiftLimUp{g in Grutors}:
	numShiftsGrut[g] <= maxShift;
	
subject to shiftLimLow{g in Grutors}:
	numShiftsGrut[g] >= 1;
	
subject to grutLimUp{t in Shifts}:
	grut[t] <= maxGrut;
	
subject to grutLimLow{t in Shifts}:
	grut[t] >= 1;
	







