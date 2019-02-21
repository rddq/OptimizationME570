
    % ------------Starting point and bounds------------
    %design variables
    x0 = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]; %starting point (all areas = 5 in^2)
    lb = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; %lower bound
    ub = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20]; %upper bound
    global nfun;
    nfun = 0;
    
    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];
   
    % ------------Call fmincon------------
  
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on',...
        'SpecifyObjectiveGradient',true,'SpecifyConstraintGradient',true);
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);  
   
    xopt    %design variables at the minimum
    fopt    %objective function value at the minumum
    [f, c, ceq] = objcon(xopt);
    c
    nfun

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        global nfun;
        
        %get data for truss from Data.m file
        Data;
        
        % insert areas (design variables) into correct matrix
        for i=1:nelem
            Elem(i,3) = x(i);
        end

        % call Truss to get weight and stresses
        [weight,stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
        
        %objective function
        f = weight; %minimize weight
        
        %inequality constraints (c<=0)
        c = zeros(10,1);         % create column vector
        for i=1:10
            c(i) = sqrt((stress(i))^2)-25000; % check stress both pos and neg         
        end
        
        %equality constraints (ceq=0)
        ceq = [];
        nfun = nfun + 1;
    end

    % ------------Separate obj/con You may wish to change------------
    function [f, grad] = obj(x) 
        [f, c, ~] = objcon(x);             
        [grad,~] = findGrad(x,f,c);
    end
    function [c, ceq, cgrad, ceqgrad] = con(x) 
        [f, c, ceq] = objcon(x);
        [~, cgrad] = findGrad(x,f,c);
        ceqgrad = ceq;
    end

    function [grad, cgrad] = findGrad(x,fo,co)
        % Define method of numerical differentiation
        type = "a"; % "forward", "central", or "complex"
        % Define step size
        h = 1e-6;
        
        [~,sizex] = size(x);
        grad = zeros(sizex,1);
        [nc,~] = size(co);
        cgrad = zeros(nc,nc);
        for index=1:sizex
            if (type=="forward" || type=="central") 
                xf = x;
                xf(index) = x(index) + h;
                [f_f,c_f,~] = objcon(xf);
                if(type=="forward")
                    grad(index) = (f_f-fo)/h;
                    for j = 1:nc
                        cgrad(index,j) = (c_f(j)-co(j))/h;
                    end
                else
                    xb = x;
                    xb(index) = x(index) - h;
                    [f_b,c_b,~] = objcon(xb);
                    grad(index) = (f_f-f_b)/(2*h);
                    for j = 1:nc
                        cgrad(index,j) = (c_f(j)-c_b(j))/h;
                    end
                end
            else
                xI = x;
                xI(index) = x(index)+1j*h;
                [f_im,c_im,~] = objcon(xI);
                grad(index) = imag(f_im)/h;   
                for  k= 1:nc
                    cgrad(index,k) = imag(c_im(k))/h;
                end
            end
        end          
    end