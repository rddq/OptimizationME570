clear
N = 10; % Total number of cycles to run
iterationsPerCycle = 30;
perturbValue = 1.75;
Pstart = 0.8; % Probability a worse design could be accepted at start
Pfinish = 1e-6; % Probability a worse design could be accepted at finish
plotIt = true;

[x,f] = simulatedAnnealing(xInit,[N,iterationsPerCycle,perturbValue,Pstart,Pfinish],plotIt)
