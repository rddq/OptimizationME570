function [xopt, fopt, exitflag, output] = OptimizeTruss()

    % ------------Starting point and bounds------------
    %var= L1,3,4,5,6 theta1,2,3,4,5,6,7,8,9   %design variables
    x0 = [30,30,30,1,1,0.5,0.5,0.01]; %starting point
    ub = [90,90,90,3,3,3,3,0.001]; %upper bound
    lb = [5,5,5,0.1,0.1,0.1,0.1,0.5]; %lower bound

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        %---Constants---%
        % Yield strength - MPa
        Sy = 220;
        % Ultimate Tensile Strength - MPa
        Sut = 341;       
                
        F1 = 1000; %N
        F2 = 1500; %N
        phiF1 = 90; %degrees
        phiF2 = 90; %degrees

        % Design Variables                
        % Angle in degrees
        theta1 = x(1);
        theta4 = x(2);       
        theta8 = x(3); 
        
        % Length in meters
        L1 = x(4);
        L2 = x(5);
        L6 = x(6);
        L7 = x(7);
        
        % base and height length
        bh = x(8);
        
        %---Design Functions---%

        % Calculate other truss dimensions
        L3 = lawCosinesLength(L1,L6,theta1);
        L4 = lawCosinesLength(L2,L3,theta4);
        L5 = lawCosinesLength(L4,L7,theta8); 
        theta2 = lawCosinesAngle(L6,L1,L3);
        theta3 = 180-theta1-theta2;
        theta5 = lawCosinesAngle(L2,L3,L4);
        theta6 = 180-theta4-theta5;
        theta7 = lawCosinesAngle(L7,L4,L5);
        theta9 = 180-theta8-theta7;
        
        function a = lawCosinesLength(b,c,A)
            a = sqrt(b^2+c^2-2*b.*c*cos(A));
        end
        function angle = lawCosinesAngle(A,b,c)
            angle = acos((-A^2+b^2+c^2)/(2*b*c));
        end
        
        % Reaction Forces
        Rx = -(F1*cos(phiF1)+F2*cos(phiF2));
        Qy = F1*sin(phiF1)*L1*cos(theta1)+F2*sin(phiF2)*(L6-L5*cos(theta9));
        Ry = F1+F2-Qy;

        Ax = [-cos(theta1), 1, cos(theta3), 0, 0, 0, 0 ];
        Ay = [sin(theta1) 0 sin(theta3) 0 0 0 0 ];
        Bx = [0 -1 0 -cos(theta6) cos(theta9) 0 0 ];
        By = [0 0 0 -sin(theta6) -sin(theta9) 0 0 ];
        Cx = [cos(theta1) 0 0 0 0 1 0 ];
        Cy = [sin(theta1) 0 0 0 0 0 0 ];
        Dx = [0 0 -cos(theta3) cos(theta8) 0 -1 1];
        Dy = [0 0 sin(theta3) sin(theta8) 0 0 0];
        Ex = [0 0 0 0 -cos(theta9) 0 -1];
        Ey = [0 0 0 0 sin(theta9) 0 0];

        A_mat = [Ax;Ay;Bx;By;Cx;Cy;Dx;Dy;Ex;Ey];
        b_mat = [-F1*cos(phiF1); F1*sin(phiF1); -F2*cos(phiF2); F2*sin(phiF2); -Rx; -Ry; 0; 0; 0; -Qy];
        xForces = mldivide(A_mat,b_mat);
        
        % Convert these Forces into stress
        
        % Tensile condition
            if F/Area > 0
            F/Area < Sut/1.5;
        end

        % Buckling condition
        if F/Area < 0
            F/Area > Sy/1.5;
        end

        angle_force = 5;
        phiF1 < 90+angle_force;
        phiF1 > 90-angle_force;
        phiF2 < 90+angle_force;
        phiF2 > 90-angle_force; 

        theta6+theta7 > 90;
        theta1+theta2+theta3 == 180;
        theta4+theta5+theta6 == 180;
        theta7+theta8+theta9 == 180;
        %objective function
        f = weight; %minimize weight
        
        %inequality constraints (c<=0)
        c = zeros(3,1);         % create column vector
        c(1) = stress-100;      %stress <= 100ksi
        c(2) = stress-bstress;  %stress-bstress <= 0
        c(3) = deflection-.25;  %deflection <= 0.25
        
        %equality constraints (ceq=0)
        ceq = [];

    end


    % ------------Call fmincon------------
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    xopt %design variables at the minimum
    fopt %objective function value at the minumum  fopt = f(xopt)
    

    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x) 
        [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x) 
        [~, c, ceq] = objcon(x);
    end
end