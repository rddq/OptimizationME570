function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)     
               
        %--- Set constants ---%
        [n,~] = size(x0); 
        stoptol_vector = stoptol*ones(1,n);
        alphaInitial = 0.00005;
        
        %--- Initialize variables ---%      
        f = obj(x0);
        alpha = alphaInitial;
        grad = gradobj(x0);
        if abs(grad) < stoptol_vector
            xopt = x0;
            fopt = f;
            exitflag = 0;
            return
        else
        if algoflag == 1
            s = getSdDirection(grad);
        else
            s = getQNdirection(grad);
        end 
        
        %--- Do a line search ---%
        [a,fn] = lineSearch(x0,f,s,obj,alpha);
        [a,fn] = takeBestThreePoints(a,fn);
        alpha = quadraticFit(a,fn);   
        
        %--- Set new variables for new search direction ---%
        xnew = x0 + alpha*s;
        [xopt, fopt, exitflag] = fminun(obj, gradobj, xnew, stoptol, algoflag);
        end     
    end
        
    function [a,fn] = lineSearch(x0,f,s,obj,alpha)
        xnew = x0 + alpha*s;
        fnew = obj(xnew);
        if fnew < f
           [a,fn] = lineSearchHelper(x0,fnew,s,obj,alpha*2,[0, alpha],[f,fnew]);
        else
            error('second point started higher')
        end
        amiddle = a(end)*0.75;
        fmiddle = obj(x0+amiddle*s);
        a = [a((end-2):end-1),amiddle,a(end)];
        fn = [fn((end-2):end-1),fmiddle,fn(end)];
    end
    
    function [a,fn] = lineSearchHelper(x0,f,s,obj,alpha,ahistory,fhistory)
        xnew = x0 + alpha*s;
        fnew = obj(xnew);
        if fnew < f
           [a,fn] = lineSearchHelper(x0,fnew,s,obj,alpha*2,[ahistory alpha],[fhistory,fnew]);
        else
            a = [ahistory alpha];
            fn = [fhistory fnew];
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
   
   function [a,fn] = takeBestThreePoints(a,fn)
        [~,min_index] = min(fn);
        a = a([min_index-1 min_index min_index+1]);
        fn = fn([min_index-1 min_index min_index+1]);
   end
   
     % get steepest descent search direction as a column vector
     function [s] = getSdDirection(grad) 
        mag = sqrt(grad'*grad);
        s = -grad/mag;
     end

    
     