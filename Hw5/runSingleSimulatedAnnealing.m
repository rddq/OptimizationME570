clear
N = 300; % Total number of cycles to run
iterationsPerCycle = 100;
perturbValue = 1.05;
Pstart = 0.99; % Probability a worse design could be accepted at start
Pfinish = 1e-10; % Probability a worse design could be accepted at finish
plotIt = false;
xInit = [-0,-0];
input = [N,iterationsPerCycle,perturbValue,Pstart,Pfinish];
[x,f] = simulatedAnnealing(xInit,[N,iterationsPerCycle,perturbValue,Pstart,Pfinish],plotIt)
