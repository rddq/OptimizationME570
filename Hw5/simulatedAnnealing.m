function [x_final, f_final] = simulatedAnnealing(xInit,input,plotIt,upperLimit,lowerLimit)
% Initialize parameterized variables
N = input(1);
iterationsPerCycle = input(2);
perturbValue = input(3);
Pstart = input(4);
Pfinish = input(5);

Tstart = -1/(log(Pstart));
Tfinish = -1/(log(Pfinish));

F = (Tfinish/Tstart)^(1/(N-1)); % Reduction factor per cycle
numberVariables = size(xInit,1);

T = Tstart;
x = xInit;
f = fun(x(1),x(2));

% Initialize histories for plotting
allx = zeros(numberVariables,iterationsPerCycle*N+1);
allf = zeros(iterationsPerCycle*N+1,1);
allx(:,1) =  x;
allf(1) = f;

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
        allx(:,totalIndex) = x;
        allf(totalIndex,1) = f;
        cycles = cycles + 1;
    end
        T = F*T;
end
x_final = x;
f_final = f;
if plotIt
    plotCycles(allf,cycles)
    contourPlot(allx,allf)
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
    fnew = fun(xNew(1),xNew(2));
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

function output = fun(x1,x2)
    output = 2.0+0.2.*x1.^2+0.2.*x2.^2 - cos(pi.*x1) - cos(pi.*x2);
end

function plotCycles(allf,cycles)
    clf
    figure(1)
    hold on
    xlabel('function call');
    ylabel('function value');
    title('Function Calls vs. Function Values');
    plot(1:cycles,allf)
end

function contourPlot(allx,allf)
    meshResolution = 0.1;
    [x1,x2] = meshgrid(-5:meshResolution:5,-5:meshResolution:5);
    output = fun(x1,x2);
    figure(2)
    hold on;
    % Plot X0
    x0 = allx(1,1); 
    y0 = allx(2,1); 
    plot(x0,y0,'m*')
    % Plot SA Optimum
    xSA_Opt = allx(1,end);
    ySA_Opt = allx(2,end);
    plot(xSA_Opt,ySA_Opt,'g*')
    % Plot Optimum
    xOpt = 0; 
    yOpt = 0; 
    plot(xOpt,yOpt,'r*')

    % Plot Contour
    [C,h] = contour(x1,x2,output,[1:13],'k-'); % Plot Contour
    clabel(C,h,'Labelspacing',500);
    title('Simulated Annealing Optimization');
    xlabel('x1');
    ylabel('x2');
    hold on;

    % Path Lines
    x_pt = allx(1,:);
    y_pt = allx(2,:);
    line(x_pt', y_pt');
    xlim([-5,5])
    ylim([-5,5])
    legend(['Starting Point f=',num2str(allf(1))],['SA Optimum f=',num2str(allf(end))],'Actual Optimum f=0')
end

end