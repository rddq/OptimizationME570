
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
  
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on','SpecifyObjectiveGradient',true);
    %,'SpecifyObjectiveGradient',true
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
            c(i) = abs(stress(i))-25000; % check stress both pos and neg         
        end
        
        %equality constraints (ceq=0)
        ceq = [];
        nfun = nfun + 1;
    end

    % ------------Separate obj/con You may wish to change------------
    function [f, grad] = obj(x) 
        [f, c, ~] = objcon(x);             
        h = 0.0001; 
        type = "d";
        [grad,cgrad] = findGrad(x,f,c,h,type);
    end
    function [c, ceq] = con(x) 
        [~, c, ceq] = objcon(x);
    end

    function [grad, cgrad] = findGrad(x,fo,co,h,type)
        n = size(x);
        grad = zeros(n);
        nc = size(co);
        for i=1:n
            if (type=="forward" || type=="central") 
                xf = x;
                xf(i) = x(i) + h;
                [f_f,c_f,~] = objcon(xf);
                if(type=="forward")
                    grad(i) = (f_f-fo)/h;
                    for j = 1:nc
                        cgrad(i,j) = (c_f(j)-co(j))/h;
                    end
                else
                    xb = x;
                    xb(i) = x(i) - h;
                    [f_b,c_b,~] = objcon(xb);
                    grad(i) = (f_f-f_b)/(2*h);
                    for j = 1:nc
                        cgrad(i,j) = (c_f(j)-c_b(j))/h;
                    end
                end
            else
                xI = complex(x);
                xI(i) = x(i)+1i*h;
                [f_im,c_im,~] = objcon(xI);
                grad(i) = imag(f_im)/h;   
                for j = 1:nc
                    cgrad(i,j) = imag(c_im(j))/h;
                end
            end
        end          
    end