set Shifts;
set Grutors;
set Students;

param studentPrefs{Students, Shifts} binary;  # 1 if student s indicated that they'd attend grutor shift t. 0 otherwise
param grutorPrefs{Grutors, Shifts} integer;  # integer value from 3 - 0 depending on how grutor g indicated their preference for shift t
param grutorsPerStudent >= 0;
param oddsOfStudentComing >= 0;

var grutorWorking{Grutors, Shifts} binary;  # 1 if grutor g works shift t. 0 otherwise.
var grutorsPerShift{Shifts} >= 0 integer;
var studentsPerShift{Shifts} integer;
var enoughGrutors{Shifts} binary;  # 1 if the GPS * grutorsPerStudent >= studentsPerShift. 0 otherwise
var shiftCovered{Shifts} binary;  # 1 if there is at least one grutor covering the shift. 0 otherwise

var numGrutorsSlack{Shifts} >= 0 integer;
var numGrutorsSurplus{Shifts} >= 0 integer; 

maximize Happiness:  # Want to maximize grutor happiness + student happiness + student&grutor happiness
	sum{t in Shifts} ((-1 * numGrutorsSlack[t]) +
					   sum{g in Grutors} (grutorPrefs[g, t] * grutorWorking[g,t]) +
					   sum{s in Students} (studentPrefs[s,t] * (2 * shiftCovered[t] - 1)));


# Calculate 
subject to SPSUpperCalc{t in Shifts}:
	studentsPerShift[t] >= sum{s in Students} oddsOfStudentComing * studentPrefs[s, t];
	
subject to SPSLowerCalc{t in Shifts}:
	studentsPerShift[t] <= sum{s in Students} oddsOfStudentComing * studentPrefs[s, t] + 1;
	
# Calculate slack and surplus grutor help for each shift
subject to NumGrutorsSlackSurplus{t in Shifts}:
	grutorsPerShift[t] * grutorsPerStudent - studentsPerShift[t] + numGrutorsSlack[t] - numGrutorsSurplus[t] = 0;

# Calculating shiftCovered boolean value
subject to ShiftCovered1{t in Shifts}:
	sum{g in Grutors} (grutorWorking[g,t]) <= 99999 * shiftCovered[t];
	
subject to ShiftCovered2{t in Shifts}:
	sum{g in Grutors} (grutorWorking[g,t]) >= shiftCovered[t];



