function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)                  
    %--- Set constants ---%
    [n,~] = size(x0); 
    stoptol_vector = stoptol*ones(1,n);
    alphaInitial = 0.7;
    firstflag = 1;
    %--- Set globals ---%
    global f_a_nobj_history
    global x_history
    global s_history
    %--- Set initial variables ---%
    allx = [];
    allf = [];
    alla = [];
    alls = [];
    nobjlocal = [];
    N = eye(n);
    %--- Update Direction ---%
    [xopt, fopt, exitflag] = updateDirection(obj, gradobj, x0,... 
    stoptol_vector, algoflag, alphaInitial,...
    N, x0, 0, firstflag, allx, allf, alla, alls, nobjlocal);
    f_a_nobj_history;
    x_history;
    s_history;
end
    
function [xopt,fopt,exitflag] = updateDirection(obj, gradobj, x0,...
    stoptol_vector, algoflag, alphaInitial, N, xprev, gradprev, firstflag,... 
    allx, allf, alla, alls, nobjlocal)
    %--- Initialize variables ---%      
    global nobj
    nobj_at_start = nobj;
    f = obj(x0);
    alpha = alphaInitial;
    grad = gradobj(x0);
    %--- Check if gradient meets stoptolerance ---%
    if abs(grad) < stoptol_vector
        xopt = x0;
        fopt = f;
        exitflag = 0;
        global f_a_nobj_history
        global x_history
        global s_history
        f_a_nobj_history = [allf;alla;nobjlocal];
        x_history = allx;
        s_history = alls;
        return
    else
    %--- Check if nobj has been called too many times ---%    
%     if nobj > 1000
%         exitflag = 1;
%         xopt = 'algorithm called obj more than 1000 times';
%         fopt = 'algorithm called obj more than 1000 times';
%         return
%     end
    %--- Update search direction --- %
    if algoflag == 1
        s = getSdDirection(grad);
    elseif algoflag == 2
        % First iteration of quasi-newton method runs as steepest descent
        if firstflag == 1
        s = getSdDirection(grad);
        firstflag = 0;
        else
        [s,N] = getQNdirection(grad,N,grad-gradprev,x0-xprev);
        end
    else
        error('algorithm not defined')
    end    
    %--- Do a line search in new direction ---%
    [a4,fn4] = searchLine(x0,f,s,obj,alpha);
    [a3,fn3] = takeBestThreePoints(a4,fn4);
    alpha = quadraticFit(a3,fn3);
    %--- Record variable history ---%
    allx = [allx x0];
    allf = [allf f];
    alls = [alls s];
    alla = [alla alpha];
    nobjlocal = [nobjlocal (nobj-nobj_at_start)];
    %--- Set new variables for new search direction ---%
    xnew = x0 + alpha*s;
    [xopt, fopt, exitflag] = updateDirection(obj, gradobj, xnew, stoptol_vector, algoflag, alphaInitial, N,x0,grad,firstflag,allx,allf,alla,alls,nobjlocal);
    end     
end
       
function [a,fn] = searchLine(x0,f,s,obj,alpha)
    xnew = x0 + alpha*s;
    fnew = obj(xnew);
    if fnew < f
       [a,fn] = searchLineHelper(x0,fnew,s,obj,alpha*2,[0, alpha],[f,fnew]);
    else
        % If the step was too far, try again with a smaller alpha
        [a,fn] = searchLine(x0,f,s,obj,alpha/100);
        return
    end
    % Go one step back and return those four points
    amiddle = a(end)*0.75;
    fmiddle = obj(x0+amiddle*s);
    a = [a((end-2):end-1),amiddle,a(end)];
    fn = [fn((end-2):end-1),fmiddle,fn(end)];
end
    
function [a,fn] = searchLineHelper(x0,f,s,obj,alpha,ahistory,fhistory)
    xnew = x0 + alpha*s;
    fnew = obj(xnew);
    if fnew < f
       [a,fn] = searchLineHelper(x0,fnew,s,obj,alpha*2,[ahistory alpha],[fhistory,fnew]);
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

function [s,N] = getQNdirection(grad,N,gamma,delta_x)
    % BFGS update is used
    tgamma = transpose(gamma);
    tdelta_x = transpose(delta_x);
    first = 1 + (tgamma*N*gamma)/(tdelta_x*gamma);
    second = (delta_x*tdelta_x)/(tdelta_x*gamma);
    third = (delta_x*tgamma*N+N*gamma*tdelta_x)/(tdelta_x*gamma);
    N = N + first*second - third;
    
    mag = sqrt(grad'*grad);
    s = -N*(grad/mag);
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

    
     