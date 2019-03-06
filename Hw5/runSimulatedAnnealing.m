clear

xInit = [-5;-5];

plotIt = false;

Nall = [10,50,70];
iterationsPerCycleAll = [30,50,70];
perturbValueAll = [0.95,1.15,1.50,1.75];
PstartAll = [0.2,0.3,0.4,0.5,0.6,0.7,0.8];
PfinishAll = [1e-8];
dFF = fullfact([size(Nall,2),size(iterationsPerCycleAll,2),size(perturbValueAll,2),size(PstartAll,2),size(PfinishAll,2)]);

numberOfExperiments = size(dFF,1);
inputwin = 0;
xwin = 0;

for index = 1:numberOfExperiments
    xhist = 0;
    N = Nall(dFF(index,1));
    iterationsPerCycle = iterationsPerCycleAll(dFF(index,2));
    perturbValue = perturbValueAll(dFF(index,3));
    Pstart = PstartAll(dFF(index,4));
    Pfinish = PfinishAll(dFF(index,5));
    input = [N,iterationsPerCycle,perturbValue,Pstart,Pfinish];
    for i = 1:20
        [x,f] = simulatedAnnealing(xInit,input,plotIt);
        if (abs(x(1)) < 0.1) && (abs(x(2)) <0.1)
            xhist = xhist+1;
        end
    end
    if xhist>xwin
        inputwin = input;
        xwin = xhist;
    end
    index
end

input
xwin
