%---Example Driver program for fminun--%
%---Author: Ryan Day--%
    clear;

    global nobj ngrad
    nobj = 0; % counter for objective evaluations
    ngrad = 0.; % counter for gradient evaluations
    
    algoflag = 1; % 1=steepest descent; 2=BFGS quasi-Newton
    problem = 1;
    stoptol = 1.e-3; % stopping tolerance, all gradient elements must be < stoptol  
    
    x0_1_starting_points = [[10;10;10] [2;7;9] [100;100;100] [15;9;30]];
    x0_1 = x0_1_starting_points(:,1); % starting points, set to be column vector
    x0_2_starting_points = [[-1.5; 1] [-3; 1.8]];
    x0_2 = x0_2_starting_points(1);
    
    if problem == 1
        % quadratic function
        x0 = x0_1;
        obj = @obj1;
        gradobj = @gradobj1;
    elseif problem == 2
        % rosenbrock function
        x0 = x0_2;
        obj = @obj2;
        gradobj = @gradobj2;
    end      
    % ---------- call fminun----------------
    [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag);
   
    xopt
    fopt
    nobj
    ngrad
   
     % Quadratic function to be minimized
     function [f] = obj1(x)
        global nobj
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
     
     % Rosenbrock function to be minimized
     function [f] = obj2(x)
        global nobj
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
     
     
     
     
    