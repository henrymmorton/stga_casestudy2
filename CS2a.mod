param n;
param m;

set Shifts;
set Students = {1..m};
set Grutors = {1..n};


param studentPrefs{Students, Shifts} integer;  # 1 if student s indicated that they'd attend grutor shift t. 0 otherwise
param grutorPrefs{Grutors, Shifts} integer;  # integer value from 2 - 0 depending on how grutor g indicated their preference for shift t
param studentsPerGrutor >= 0;
param oddsOfStudentComing >= 0;
param maxShiftsPerGrutor >= 0;

var grutorWorking{Grutors, Shifts} binary;  # 1 if grutor g works shift t. 0 otherwise.
var grutorsPerShift{Shifts} >= 0 integer;  # Amount of grutors we assign to a shift t.
var studentDemand{Shifts} integer;  # Amount of students we expect to attend each shift
var enoughGrutors{Shifts} binary;  # 1 if the GPS * grutorsPerStudent >= studentDemand. 0 otherwise
var shiftCovered{Shifts} binary;  # 1 if there is at least one grutor covering the shift. 0 otherwise

var numGrutorsSlack{Shifts} >= 0 integer;
var numGrutorsSurplus{Shifts} >= 0 integer; 

maximize Happiness:  # Want to maximize grutor happiness + student happiness + student&grutor happiness
	sum{t in Shifts} ((-1 * (numGrutorsSlack[t] + numGrutorsSurplus[t])) +
					   sum{g in Grutors} ((1 / 2) * grutorPrefs[g, t] * grutorWorking[g,t]) +  # multiply by 1/2 to normalize
					   sum{s in Students} ((1 / 2) * studentPrefs[s,t] * (2 * shiftCovered[t] - 1))
					  );


# Calculate studentsPerShift for each shift
subject to SPSUpperCalc{t in Shifts}:
	studentDemand[t] >= sum{s in Students} oddsOfStudentComing * studentPrefs[s, t];
	
subject to SPSLowerCalc{t in Shifts}:
	studentDemand[t] <= sum{s in Students} oddsOfStudentComing * studentPrefs[s, t] + 1;
	
# Calculate slack and surplus grutor help for each shift
subject to NumGrutorsSlackSurplus{t in Shifts}:
	grutorsPerShift[t] * studentsPerGrutor - studentDemand[t] + numGrutorsSlack[t] - numGrutorsSurplus[t] = 0;


# Make sure number of grutors working is consistent
subject to GrutorFlow{t in Shifts}:
	sum{g in Grutors} (grutorWorking[g,t]) = grutorsPerShift[t];
	
# Calculating shiftCovered boolean value
subject to ShiftCovered1{t in Shifts}:
	sum{g in Grutors} (grutorWorking[g,t]) <= 99999 * shiftCovered[t];
	
subject to ShiftCovered2{t in Shifts}:
	sum{g in Grutors} (grutorWorking[g,t]) >= shiftCovered[t];

# Maximum number of shifts a grutor g can take
subject to MaxShifts{g in Grutors}:
	sum {t in Shifts} grutorWorking[g,t] <= maxShiftsPerGrutor;

# Can iterate on this model by requiring that the happiness is above a certain level of the maximum
# but we make the objective function a minimization of grutors instead
