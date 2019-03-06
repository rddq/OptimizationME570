N = 200; % Total number of cycles to run
iterationsPerCycle = 60;
perturbValue = 1.05;

Pstart = 0.8; % Probability a worse design could be accepted at start
Pfinish = 1e-6; % Probability a worse design could be accepted at finish

plotIt = false;
f = simulatedAnnealing(N,iterationsPerCycle,perturbValue,Pstart,Pfinish,plotIt);