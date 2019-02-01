
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
        
        line_iteration = 0;
        line_search = 0;
        allf = [f];
        
        while true
            [fnew,xnew]= takeStep(x,alpha,s,obj);
            append(allf, fnew)
            if fnew < f
                alpha = alpha*2;
                f = fnew;
                x = xnew;
                line_search = line_search + 1  
            else
            % Calculate Alpha Star 
            a1 = alpha/2;
            a3 = alpha;
            a2 = (a1+a3)/2;
            [fmiddle,~] = takeStep(x,a2,s,obj);
            p = polyfit([a1,a2,a3],[f,fmiddle,fnew],2);
            quadfita1 = polyval(p,a1);
            quadfita2 = polyval(p,a2);
            quadfita3 = polyval(p,a3);
%             d1p = polyder(p);                           % First Derivative
%             d2p = polyder(d1p);                         % Second Derivative
%             ips = roots(d1p);                           % Inflection Points
%             afinal = polyval(d2p, ips);                    % Evaluate ‘d2p’ at ‘ips’            

            num = quadfita1*(a2^2-a3^3)+quadfita2*(a3^2-a1^2)+quadfita3*(a1^2-a2^2);
            den = 2*(quadfita1*(a2-a3)+quadfita2*(a3-a1)+quadfita3*(a1-a2));
            astar = num/den;
            % set new variables for new search direction
            [f,x] = takeStep(x,astar,s,obj);
            alpha = alphaInitial;
            grad = gradobj(x);
            s = getSdDirection(grad);
            if s < stoptol
                break
            else
                line_iteration = line_iteration+1
            end
%             
%             
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
     