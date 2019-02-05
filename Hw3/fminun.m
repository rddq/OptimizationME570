function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)     
        %--- Initialize variables ---%
        
        [n,~] = size(x0); 
        stoptol = stoptol*ones(1,n);
        
        max_iterations = 2500;
        max_line_search = 2500;
        alphaInitial = 0.5;
        
        x = x0;
        f = obj(x);
        alpha = alphaInitial;
        grad = gradobj(x);
        
    for line_search_index = 1:max_line_search
        if grad < stoptol
            xopt = x;
            fopt = f;
            exitflag = 1;
            break
        end
        if algoflag == 1
            s = getSdDirection(grad);
        else
            s = getQNdirection(grad);
        end       
        % Initialize history
        allf = [f];
        allx = [x];
        alla = [0];
        %--- Search Line ---%
        for iter_index = 1 : max_iterations
            % Take step in alpha direction
            alla = [alla alpha];
            [fnew,xnew]= takeStep(allx(1),alla(end),s,obj);
            allf = [allf fnew];
            allx = [allx xnew];
            if fnew < allf(end-1)
                alpha = alpha*2; 
            else
                break
            end               
        end 
        alpha = quadraticFit(alla,allf,allx,s,obj);
        %--- Set new variables for new search direction ---%
        [f,x] = takeStep(x,alpha,s,obj);
        grad = gradobj(x);        
    end
end
        
function [astar] = quadraticFit(alla,allf,allx,s,obj)
    % Perform quadratic approximation and find minimum
    [~,cols] = size(allf);
    if cols == 2
       % Find a value that is less than the original point
       while true
           alphaExtra = (alla(end)+alla(end-1))/2
           [fnew,xnew]= takeStep(allx(1),alphaExtra,s,obj);
           if fnew <
       end
    else
       amiddle = (alla(end)+alla(end-1))/2;
    end            
    % Take alphas around minimum for quadratic approximation    
    [fmiddle,~] = takeStep(allx(end),amiddle,s,obj);
    alphas = [alla(end-2), alla(end-1), amiddle, alla(end)];
    candidates = [allf(end-2), allf(end-1), fmiddle, allf(end)];
    [~,min_index] = min(candidates);

    a = alphas([min_index-1 min_index min_index+1]);
    fn = candidates([min_index-1 min_index min_index+1]);

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


    
     