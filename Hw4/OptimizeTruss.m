
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
    [f, g, c, ceq] = objcon(xopt);
    c
    nfun

    % ------------Objective and Non-linear Constraints------------
    function [f, grad, c, ceq] = objcon(x)
        global nfun;
        
        %get data for truss from Data.m file
        Data;
        
        % insert areas (design variables) into correct matrix
        for i=1:nelem
            Elem(i,3) = x(i);
        end

        % call Truss to get weight and stresses
        [weight,stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
        
        grad = gradImag(Elem(:,3), @Truss, 0.0001, Elem, ndof, nbc, nelem, E, dens, Node, force, bc);
        
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
    function [f,grad] = obj(x) 
        [f, grad, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x) 
        [~, ~, c, ceq] = objcon(x);
    end
    
function [grad] = gradCentral(x,Truss,h, Elem, ndof, nbc, nelem, E, dens, Node, force, bc)
    n = size(x);
    grad = zeros(n);
    for i=1:n
        ElemF = Elem;
        ElemB = Elem;
        ElemF(i,3) = x(i) + h;
        f_forward = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, ElemF);
        ElemB(i,3) = x(i) - h;
        f_backward = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, ElemB);
        grad(i) = (f_forward-f_backward)/(2*h);
    end
end
function [grad] = gradForward(x,Truss,h, Elem, ndof, nbc, nelem, E, dens, Node, force, bc)
    n = size(x);
    grad = zeros(n);
    fb = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    for i=1:n
        ElemF = Elem;
        ElemF(i,3) = x(i) + h;
        f_forward = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, ElemF);
        grad(i) = (f_forward-fb)/h;
    end
end
function [grad] = gradImag(x,Truss,h, Elem, ndof, nbc, nelem, E, dens, Node, force, bc)
    n = size(x);
    grad = zeros(n);
    for index=1:n
        ElemI = complex(Elem);
        ElemI(index,3) = x(index) + 1i*h;
        f_im = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, ElemI);
        grad(index) = imag(f_im)/h;
    end
end