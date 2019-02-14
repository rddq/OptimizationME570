function [xopt, fopt, exitflag, output] = OptimizeTruss()

    % ------------Starting point and bounds------------
    %var= L1,3,4,5,6 theta1,2,3,4,5,6,7,8,9   %design variables
    x0 = [30,30,30,1,1,0.5,0.5,0.01]; %starting point
    ub = [90,90,90,1000,1000,1000,1000,1000]; %upper bound
    lb = [5,5,5,0.001,0.001,0.001,0.001,0.00000000000000000000000000001]; %lower bound

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        %---Design Variables---%   
        
        % Angle in degrees
        theta1 = x(1);
        theta4 = x(2);       
        theta8 = x(3); 
        
        % Length in meters
        L1 = x(4);
        L2 = x(5);
        L6 = x(6);
        L7 = x(7);
        
        % area of cross section of beam (assuming square beam)
        Area = x(8);
        
        %---Constants---%
        
        % Yield strength - MPa
        Sy = 220;
        % Ultimate Tensile Strength - MPa
        Sut = 341;  
        % Density kg/m^3
        density = 7850;
        % Factor of Safety
        FOS = 1.5;
        
        % Degrees that angle of Forces will be shifted
        angle_s = 2;
                
        F1 = 100000; %N
        F2 = 100000; %N
        phiF1 = 90; %degrees
        phiF2 = 90; %degrees
        
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
        
        all_member_stress = zeros(1,63);
        
        % Find Member Stress in all configurations
        phiF1 = [phiF1-angle_s,phiF1,phiF1+angle_s];
        phiF2 = [phiF2-angle_s,phiF2,phiF2+angle_s];
        iteration = 0;
        for index_phiF1 = 1:3
            for index_phiF2 = 1:3
                iteration = iteration+1;
                memberForces = calculateForces(F1,phiF1(index_phiF1),F2,phiF2(index_phiF2),theta1,theta3,theta6,theta8,theta9,L1,L6,L5);
                all_member_stress(7*iteration-6:7*iteration) = (memberForces./Area);
            end
        end
              
        function memberForces = calculateForces(F1,phiF1,F2,phiF2,theta1,theta3,theta6,theta8,theta9,L1,L6,L5)
            % Reaction Forces
            Rx = -(F1*cos(phiF1)+F2*cos(phiF2));
            Qy = F1*sin(phiF1)*L1*cos(theta1)+F2*sin(phiF2)*(L6-L5*cos(theta9));
            Ry = F1+F2-Qy;
            
            % Solve system of equations for member forces
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
            memberForces = mldivide(A_mat,b_mat);
        end

        %---Objective function---%
        weight = (L1+L2+L3+L4+L5+L6+L7)*Area*density;
        f = weight; %minimize weight
        
        
        %---Inequality constraints (c<=0)---%
        [constraint_number,~] = size(all_member_stress);
        c = zeros(constraint_number*2,1); % create column vector
        for index = 1:size(all_member_stress)
            c(2*index-1) = all_member_stress(index)-Sy/(FOS);
            c(2*index) = -Sut/(FOS)-all_member_stress(index);
        end
        c(64) = 5-theta2;
        c(65) = 5-theta3;
        c(66) = 5-theta5;
        c(67) = 5-theta6;
        c(68) = 5-theta7;
        c(69) = 5-theta9;
        
        %equality constraints (ceq=0)
        ceq = [];

    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    xopt %design variables at the minimum
    fopt %objective function value at the minumum  fopt = f(xopt)
    plot_truss(xopt);

    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x) 
        [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x) 
        [~, c, ceq] = objcon(x);
    end
end
function a = lawCosinesLength(b,c,A)
            a = sqrt(b^2+c^2-2*b.*c*cos(A));
end
function angle = lawCosinesAngle(A,b,c)
    angle = acos((-A^2+b^2+c^2)/(2*b*c));
end
function plot_truss(xopt)
    clf    
    theta1 = xopt(1);
    theta4 = xopt(2);
    theta8 = xopt(3);
    L1 = xopt(4);
    L2 = xopt(5);
    L6 = xopt(6);
    L7 = xopt(7);
    L3 = lawCosinesLength(L1,L6,theta1);
    L4 = lawCosinesLength(L2,L3,theta4);
    L5 = lawCosinesLength(L4,L7,theta8); 
    theta2 = lawCosinesAngle(L6,L1,L3);
    theta3 = 180-theta1-theta2;
    theta5 = lawCosinesAngle(L2,L3,L4);
    theta6 = 180-theta4-theta5;
    theta7 = lawCosinesAngle(L7,L4,L5);
    theta9 = 180-theta8-theta7;
    C = [0,0];
    A = [L1*cos(theta1),L1*sin(theta1)];
    B = [A(1)+L2,A(2)];
    E = [L6+L7,0];
    D = [L6,0];
    
    figure(1);
    X = [C(1),A(1),B(1),E(1),D(1),C(1)]
    Y = [C(2),A(2),B(2),E(2),D(2),C(2)]
    plot(X,Y)
    hold on
    plot([A(1),D(1),B(1)],[A(2),D(2),B(2)])
end
        