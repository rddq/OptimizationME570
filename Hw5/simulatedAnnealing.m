clear
N = 50; % Total number of cycles to run
Pstart = 0.7; % Probability a worse design could be accepted at start
Pfinish = 1e-3; % Probability a worse design could be accepted at finish
delta = 0.5;

Tstart = -1/(log(Pstart));
Tfinish = -1/(log(Pfinish));
F = (Tfinish/Tstart)^(1/(N-1)); % Reduction factor
allChangeE = [];

T = Tstart;
x = [1;5];
upperLimit = [5;5];
lowerLimit = [-5;-5];
f = fun(x);

[numberVariables,~] = size(x);
xNew = x;

% Randomly perturb the variables
for index = 1:numberVariables
    perturbation = (rand()-0.5)*2; % random number between -1 and 1
    xNew(index) = xNew(index)+perturbation;
end
fnew = fun(xNew);
changeE = fnew-f;
allChangeE = [allChangeE changeE];
if changeE < 0
    x = xNew;
else
    P = boltzmannProb(T,changeE,mean(allChangeE));
    if rand() < P
       x = xNew;
    end
end

function prob = boltzmannProb(T,changeE,changeEavg)
    prob = exp(-changeE/(changeEavg*T));
end

function output = fun(x)
    x1 = x(1);
    x2 = x(2);
    output = 2.0+0.2*x1^2+0.2*x2^2 - cos(pi*x1) - cos(pi*x2);
end