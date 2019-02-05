function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)     
        %--- Set constants ---%
        [n,~] = size(x0); 
        stoptol_vector = stoptol*ones(1,n);
        alphaInitial = 0.000005;
        
        %--- Initialize variables ---%      
        f = obj(x0);
        alpha = alphaInitial;
        grad = gradobj(x);
        if algoflag == 1
            s = getSdDirection(grad);
        else
            s = getQNdirection(grad);
        end             
        [a,fn] = checkAlpha(x0,f,obj,alpha,0,0);       
        alpha = quadraticFit(a,fn);
        
        %--- Set new variables for new search direction ---%
        xnew = x + alpha*s;
        %fnew = obj(xnew);
        grad = gradobj(x);
        if abs(grad) < stoptol_vector
            xopt = x;
            fopt = f;
            exitflag = 1;
        else
            fminun(obj, gradobj, xnew, stoptol, algoflag)
        end     
    end
        
    function [a,fn] = checkAlpha(x0,f,s,obj,alpha,ahistory,fhistory)
        xnew = x0 + alpha*s;
        fnew = obj(xnew);
        if fnew < f
           checkAlpha(x0,fnew,s,obj,alpha*2,[alpha,alpha*2],[f,fnew])
        else
           [a1]
           return 
        end
    end
    
    function [astar] = quadraticFit(a,fn)
        % Calculate Alpha of minimum of the quadratic approximation
        num = fn(1)*(a(2)^2-a(3)^2)+fn(2)*(a(3)^2-a(1)^2)+fn(3)*(a(1)^2-a(2)^2);
        den = 2*(fn(1)*(a(2)-a(3))+fn(2)*(a(3)-a(1))+fn(3)*(a(1)-a(2)));
        astar = num/den; 
    end        
    
   function [s] = getQNdirection(grad)
        s=0;
   end
     % get steepest descent search direction as a column vector
     function [s] = getSdDirection(grad) 
        mag = sqrt(grad'*grad);
        s = -grad/mag;
     end
     
     function [fnew, xnew] = takeStep(x, alpha, s ,obj)
        xnew = x + alpha*s;
        fnew = obj(xnew);
     end


    
     