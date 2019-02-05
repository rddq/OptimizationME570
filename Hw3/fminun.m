
     function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)
     
        % get function and gradient at starting point
        [n,~] = size(x0); % get number of variables
        f = obj(x0);
        grad = gradobj(x0);
        x = x0;
        
        alphaInitial = 0.5;
        
        % set starting step length
        alpha = alphaInitial;
        % steepest descent
        s = getSdDirection(grad);          
        
        line_step = 0;
        line_iteration = 0;
        
        % Initialize history
        allf = [f];
        allx = [x];
        alla = [0, alpha];
        while true            
            % Take step in alpha direction
            [fnew,xnew]= takeStep(x,alpha,s,obj);
            allf = [allf, fnew];
            allx = [allx, xnew];
            line_iteration = line_iteration + 1;
            if fnew < f
                alpha = alpha*2;
                alla = [alla alpha];
                f = fnew;
                x = xnew;
            else
            % Perform quadratic approximation and find minimum
            if size(allf) == 2
               [fnew,xnew]= takeStep(x,alpha,s,obj);
               allf = [allf, fnew];
               allx = [allx, xnew];
            end            
            % Take alphas around minimum for quadratic approximation
            amiddle = (alpha+alpha/2)/2;
            [fmiddle,~] = takeStep(x,amiddle,s,obj);
            alphas = [alla(end-2), alla(end-1), amiddle, alla(end)];
            candidates = [allf(end-2), allf(end-1), fmiddle, allf(end)];
            [~,min_index] = min(candidates);
            
            a = alphas([min_index-1 min_index min_index+1]);
            f = candidates([min_index-1 min_index min_index+1]);
            
            % Calculate Alpha of minimum of the quadratic approximation
            [f,x] = takeStep(x,astar,s,obj);
            num = f(1)*(a(2)^2-a(3)^3)+f(2)*(a(3)^2-a(1)^2)+f(3)*(a(1)^2-a(2)^2);
            den = 2*(f(1)*(a(2)-a(3))+f(2)*(a(3)-a(1))+f(3)*(a(1)-a(2)));
            astar = num/den;
            % set new variables for new search direction
            [f,x] = takeStep(x,astar,s,obj);
            alpha = alphaInitial;
            grad = gradobj(x);
            s = getSdDirection(grad);
            line_iteration
            if s < stoptol
                line_step+1
                break
            else
                line_step = line_step+1;
            end
            end
        end        
        xopt = x;
        fopt = f;
        exitflag = 0;
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
     