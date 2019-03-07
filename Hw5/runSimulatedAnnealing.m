clear

xInit = [5;5];

plotIt = false;

Nall = [22,24,26];
iterationsPerCycleAll = [10];
perturbValueAll = [4.5];
PstartAll = [1e-40];
PfinishAll = [1e-50];
upperLimit = [5;5];
lowerLimit = [-5;-5];

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
    for i = 1:1000
        [x,f] = simulatedAnnealing(xInit,input,plotIt,upperLimit,lowerLimit);
        if (abs(x(1)) < 1.0) && (abs(x(2)) < 1.0)
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
