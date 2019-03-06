clear

xInit = [-5;-5];

plotIt = false;

Nall = [100,150,200,250,300];
iterationsPerCycleAll = [10,30,50,70,90,100];
perturbValueAll = [0.5,0.75,0.85,0.90,0.95,1.15,1.50];
PstartAll = [0.2,0.3,0.4,0.5,0.6,0.7,0.8];
PfinishAll = [1e-3,1e-5,1e-8];
dFF = fullfact([size(Nall,2),size(iterationsPerCycleAll,2),size(perturbValueAll,2),size(PstartAll,2),size(PfinishAll,2)]);

numberOfExperiments = size(dFF,1);
inputwin = 0;
fwin = 20;
for index = 1:numberOfExperiments
    fhist = zeros(10,1);
    N = Nall(dFF(index,1));
    iterationsPerCycle = iterationsPerCycleAll(dFF(index,2));
    perturbValue = perturbValueAll(dFF(index,3));
    Pstart = PstartAll(dFF(index,4));
    Pfinish = PfinishAll(dFF(index,5));
    input = [N,iterationsPerCycle,perturbValue,Pstart,Pfinish];
    for i = 1:10
        [x,f] = simulatedAnnealing(xInit,input,plotIt);
        fhist(i) = f;
    end
    ffinal = mean(fhist,1);
    if ffinal<fwin
        inputwin = input;
        fwin = ffinal;
    end
end
%[x,f] = simulatedAnnealing(xInit,[N,iterationsPerCycle,perturbValue,Pstart,Pfinish],plotIt);
% N = 300; % Total number of cycles to run
% iterationsPerCycle = 60;
% perturbValue = 0.95;
% 
% Pstart = 0.5; % Probability a worse design could be accepted at start
% Pfinish = 1e-6; % Probability a worse design could be accepted at finish