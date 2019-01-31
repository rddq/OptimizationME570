
     function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)
     
        % get function and gradient at starting point
        [n,~] = size(x0); % get number of variables
        f = obj(x0)
        grad = gradobj(x0);
        x = x0;
        
        %set starting step length
        alpha = 0.5;
     
        if (algoflag == 1)     % steepest descent
           s = srchsd(grad)          
        end
        
        % take a step
        xnew = x + alpha*s;
        fnew = obj(xnew);
        
        xopt = xnew;
        fopt = fnew;
        exitflag = 0;
     end
     
     % get steepest descent search direction as a column vector
     function [s] = srchsd(grad)
        mag = sqrt(grad'*grad);
        s = -grad/mag;
     end