function [xopt, fopt, exitflag, output] = optimize_spring()


    % ------------Starting point and bounds------------
    %var= d D n hf   %design variables
    x0 = [0.01, 0.01, 1, 1]; %starting point
    ub = [0.2, 1, 50, 10]; %upper bound
    lb = [0.01,0.01,1,1.0]; %lower bound

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        
        %design variables
        d = x(1);  % height (in)
        D = x(2);  % diameter (in)
        n = x(3); % number of coils (treating as continuous for this example)
        hf = x(4); % free height (in)
        
        % Constants
        G = 12e6;  % psi
        Se = 45000; % psi
        w = 0.18;
        Sf = 1.5;
        Q= 150000; % psi

        % Analysis variables
        h0 = 1.0; % preload height
        delta0 = 0.4;
    
        % Output variables
        hdef = h0-delta0;
        k = (G*d^4)/(8*D^3*n);
        K = (4*D-d)/(4*(D-d))+0.62*d/D;
        F_h0 = k*(hf-h0); %Fmin
        F_hdef = k*(hf-hdef); %Fmax
        tauh0 = (8*F_h0*D)/(pi*d^3)*K; %taumin
        tauhdef = (8*F_hdef*D)/(pi*d^3)*K; %taumax

        taumean = (tauhdef+tauh0)/2;
        tauavg = (tauhdef-tauh0)/2;

        hs = n*d;
        Fhs = k*(hf-hs);
        tauhs = (8*Fhs*D)/(pi*d^3)*K;

        Sy = 0.44*Q/(d^w);

        %objective function
        f = -F_h0; %maximize F_h0
        
        %inequality constraints (c<=0)
        c = zeros(7,1);         % create column vector
        c(1) = (tauhs - Sy);   %scaled                
        c(2) = (tauavg - (Se/Sf)); %scaled
        c(3) = (tauavg+taumean)-(Sy/Sf);   
        c(4) = (D/d)-16;  
        c(5) = 4-(D/d);  
        c(6) = (D+d) - 0.75;
        c(7) = hs - (hdef-0.05);
        %equality constraints (ceq=0)
        ceq = [];

    end


    % ------------Call fmincon------------
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    xopt %design variables at the minimum
    fopt %objective function value at the minumum  fopt = f(xopt)
    [f,c,ceq] = objcon(xopt);
    c
    contour_plot(xopt(3),xopt(4));
    
    
    
    
    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x) 
        [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x) 
        [~, c, ceq] = objcon(x);
    end
end