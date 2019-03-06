clear

xInit = [-5;-5];

plotIt = false;

Nall = [300];
iterationsPerCycleAll = [100];
perturbValueAll = [1.05,1.15,1.25,1.5];
PstartAll = [0.99];
PfinishAll = [1e-10];
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
    for i = 1:10
        [x,f] = simulatedAnnealing(xInit,input,plotIt);
        if (abs(x(1)) < 0.1) && (abs(x(2)) <0.1)
            xhist = xhist+1;
        end
    end
    if xhist>xwin
        inputwin = input;
        xwin = xhist;
    end
    input
    xhist
    index
end
inputwin
xwin
