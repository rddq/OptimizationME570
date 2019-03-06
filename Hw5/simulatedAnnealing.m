function [x_final, f_final] = simulatedAnnealing(xInit,input,plotIt)
N = input(1);
iterationsPerCycle = input(2);
perturbValue = input(3);
Pstart = input(4);
Pfinish = input(5);

Tstart = -1/(log(Pstart));
Tfinish = -1/(log(Pfinish));

F = (Tfinish/Tstart)^(1/(N-1)); % Reduction factor per cycle
upperLimit = [5;5];
lowerLimit = [-5;-5];
numberVariables = size(xInit,2);

T = Tstart;
x = xInit;
f = fun(x);
allf = zeros(iterationsPerCycle*N,1);
allf = [f];
cycles = 1;
changeFavg = 0;
firstFlag = true;
for index1 = 1:N
    for iteration_index = 1:iterationsPerCycle
        totalIndex = index1*iterationsPerCycle-(iterationsPerCycle-iteration_index)+1;     
        [x, f, changeFavg] = iterate(x,f,changeFavg,T,numberVariables,upperLimit,lowerLimit,perturbValue,firstFlag); 
        if totalIndex == 2
            firstFlag = false;
        end
        allf(totalIndex,1) = f;
        cycles = cycles + 1;
    end
        T = F*T;
end
x_final = x;
f_final = f;
if plotIt
    plotCycles(allf,cycles)
end


function [x,f,avgChangeF] = iterate(x,f,avgChangeFprev,T,numberVariables,upperLimit,lowerLimit,perturbValue,firstFlag)
    xNew = x;
    % Randomly perturb the variables
    for index =  1:numberVariables
        perturbation = perturb(perturbValue);
        xnewAtIndex = xNew(index)+perturbation;
        % If value passes the limits, set it at the limit
        if xnewAtIndex < lowerLimit(index)
            xnewAtIndex = lowerLimit(index);
        elseif xnewAtIndex > upperLimit(index)
            xnewAtIndex = upperLimit(index);
        end
        xNew(index) = xnewAtIndex;
    end
    fnew = fun(xNew);
    changeF = fnew-f;
    % Calculate avg change F
    if firstFlag
        avgChangeF = abs(changeF);
    else
        avgChangeF = (abs(changeF)+avgChangeFprev)/2;
    end
    % If the function is minimized, keep it.
    if changeF < 0
        x = xNew;
        f = fnew;
    % If function is not minimized, check to keep it or not.
    else
        P = boltzmannProb(T,changeF,avgChangeF);
        if rand() < P
           x = xNew;
           f = fnew;
        end
    end
end

function answer = perturb(value)
    answer = rand()*value-(value/2);
end

function prob = boltzmannProb(T,changeE,changeEavg)
    prob = exp(-changeE/(changeEavg*T));
end

function output = fun(x)
    x1 = x(1);
    x2 = x(2);
    output = 2.0+0.2*x1^2+0.2*x2^2 - cos(pi*x1) - cos(pi*x2);
end
function plotCycles(allf,cycles)
    clf
    figure(1)
    plot(1:cycles,allf)
end
end