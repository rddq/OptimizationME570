clear
N = 22; % Total number of cycles to run
iterationsPerCycle = 10;
perturbValue = 4;
Pstart = 1e-40; % Probability a worse design could be accepted at start
Pfinish = 1e-50; % Probability a worse design could be accepted at finish
plotIt = false;
xInit = [-5,5];
input = [N,iterationsPerCycle,perturbValue,Pstart,Pfinish];
[x,f] = simulatedAnnealing(xInit,[N,iterationsPerCycle,perturbValue,Pstart,Pfinish],plotIt)
