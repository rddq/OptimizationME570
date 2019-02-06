%---Example Driver program for fminun--%
%---Author: Ryan Day--%
    clear;

    global nobj ngrad
    nobj = 0; % counter for objective evaluations
    ngrad = 0.; % counter for gradient evaluations
    
    
    x0_1 = [10; 10; 10]; % starting point, set to be column vector
    x0_2 = [-1.5; 1];
    algoflag = 1; % 1=steepest descent; 2=BFGS quasi-Newton
    stoptol = 1.e-3; % stopping tolerance, all gradient elements must be < stoptol  
    
    
    % ---------- call fminun----------------
    [xopt, fopt, exitflag] = fminun(@obj2, @gradobj2, x0_2, stoptol, algoflag);
   
    xopt
    fopt
    nobj
    ngrad
   
     % function to be minimized
     function [f] = obj1(x)
        global nobj
        %example function
        f = 20+3*x(1)-6*x(2)+8*x(3)+6*x(1)^2-(2*x(1)*x(2))-(x(1)*x(3))+x(2)^2+0.5*x(3)^2;
        nobj = nobj +1;
     end
     
    % get gradient as a column vector
     function [grad] = gradobj1(x)
        global ngrad
        %gradient for function 1
        grad(1,1) = 12*x(1) - 2*x(2) - x(3) + 3;
        grad(2,1) = 2*x(2) - 2*x(1) - 6;
        grad(3,1) = x(3) - x(1) + 8;
        ngrad = ngrad + 1;
     end
     
     % function to be minimized
     function [f] = obj2(x)
        global nobj
        %example function
        f = 100*(x(2)-x(1)^2)^2+(1-x(1))^2;
        nobj = nobj +1;
     end
     
     % get gradient as a column vector
     function [grad] = gradobj2(x)
        global ngrad
        %gradient for function 1
        grad(1,1) = 2*x(1) - 400*x(1)*(- x(1)^2 + x(2)) - 2;
        grad(2,1) = - 200*x(1)^2 + 200*x(2);
        ngrad = ngrad + 1;
     end
     
     
     
     
    