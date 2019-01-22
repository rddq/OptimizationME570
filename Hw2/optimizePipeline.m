function [xopt, fopt, exitflag, output] = optimizePipeline()


    % ------------Starting point and bounds------------
    %var= Qw D d   %design variables
    x0 = [10,   0.2,    0.001]; %starting point
    ub = [30000000,   0.5,    100000000]; %upper bound
    lb = [0.000000001,  0.0000000001, 0.0005]; %lower bound

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, constraints, ceq] = objcon(x)
        
        %Design Variables
        Qw=x(1); %ft^3/sec water flow rate
        D=x(2); %ft - internal diameter of pipe
        d=x(3); %ft - average limestone particle size after grinding
        
        %Analysis Variables
        L = 15; %miles to feet - length of pipeline
        W = 12.67; %lbm/sec - flowrate of limestone
        Ql=W; %ft^3/sec - flowrate of limestone
        a = 0.01; %ft. - average lump size of limestone before grinding
        g = 32.17; %ft/sec^2 - acceleration due to gravity
        gc = 32.17; % lbmft/lbfsec^2 - conversion between lbf and lbm 
        pw = 62.4; %lbm/ft3 - density of water 
        mew = 7.392*10^-4;%lbm/(ft-sec) - viscosity of water
        gamma = 168.5; %lbm/ft3 - limestone density
       
        %Analysis Functions
        Area = pi*D^2/4; %ft^2 - cross sectional area of pipe
        Q = Ql+Qw; %ft^3/sec - total slurry flow rate
        V = Q/Area; %ft/sec - average flow velocity
        c = Ql/(Q); % volumetric concentration of slurry
        S=gamma/pw; % specific gravity of the limestone

        Rw = (pw*V*D)/mew;
        if Rw<10^5
        fw = 0.3164/Rw^0.25; % friction factor of water
        else
        fw = 0.0032+0.221*Rw^-0.237; % friction factor of water
        end
        CdRp2 = 4*g*pw*d^3*((gamma-pw)/(3*mew^2));
        % Curve fit is from JMP 14.
        a1 = 0.421534;
        b1= 104.95427;
        h1 = 0.5679997;
        d1 = 508.55715;
        f1 = 1.2131968;
        Cd = a1+b1*exp(-h1*log(CdRp2))+d1*exp(-f1*log(CdRp2));% average drag coefficient of the particles

        p = pw + c*(gamma-pw); % density of slurry lbm/ft^3

        f = fw*(pw/p+150*c*(pw/p)*((g*D*(S-1))/(V^2*sqrt(Cd)))^1.5);
        Pg = 218*W*(1/sqrt(d)-1/sqrt(a)); %ftlbf/sec - Power for grinding
        GrindingPowerHP = Pg/550;

        changep = f*p*L*V^2/(D*2*gc);
        Pf = changep*Q; %ft-lbf/sec - Friction power loss
        PumpingPowerHP = Pf/550;
        
        Vc = (40*g*c*(S-1)*D/sqrt(Cd))^0.5;
        mdot = p*Area*V;

        PlantOperationHoursPerYear = 8*300; %hours
        CostOfEnergy = 0.07; %cost per horsepowerhour
        InitialCostGrinder = GrindingPowerHP*300;
        InitialCostPump = PumpingPowerHP*200;
        CostPerYear = PlantOperationHoursPerYear*(PumpingPowerHP+GrindingPowerHP)*CostOfEnergy;
        InitialCost = InitialCostGrinder+InitialCostPump;
        i = 0.07;
        n = 7;
        NetPresentCost = InitialCost+(CostPerYear*((1+i)^n-1)/(i*(1+i)^n));        
        
        %objective function
        f = NetPresentCost; %minimize cost
        
        %inequality constraints (c<=0)
        constraints = zeros(6,1);         % create column vector
        constraints(1) = D-0.5; %Pipe diameter should not exceed six inches
        constraints(2) = 1.1*Vc-V; %V > 1.1 VC
        constraints(3) = c-0.4; %concentration of limestone less than 0.4
        constraints(4) = 0.0005 - d; %d is greater than 0.0005
        constraints(5) = 2.4 - CdRp2; % CdRp2 is greater than 2.4
        constraints(6) = CdRp2 - 9600000; % CdRp2 is less than 9600000
        
        %equality constraints (ceq=0)
        ceq = [];

    end


    % ------------Call fmincon------------
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    xopt %design variables at the minimum
    fopt %objective function value at the minumum  fopt = f(xopt)
    objcon(xopt)

    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x) 
        [f, ~, ~] = objcon(x);
    end
    function [constraints, ceq] = con(x) 
        [~, constraints, ceq] = objcon(x);
    end
end