clear

N = 10; % Total number of cycles to run
iterationsPerCycle = 6;
perturbValue = 4.5;
Pstart = 1e-6; % Probability a worse design could be accepted at start
Pfinish = 1e-30; % Probability a worse design could be accepted at finish
plotIt = true;
xInit = [-5;5];
upperLimit = [5;5];
lowerLimit = [-5;-5];
input = [N,iterationsPerCycle,perturbValue,Pstart,Pfinish];
[x,f] = simulatedAnnealing(xInit,[N,iterationsPerCycle,perturbValue,Pstart,Pfinish],plotIt,upperLimit,lowerLimit);
