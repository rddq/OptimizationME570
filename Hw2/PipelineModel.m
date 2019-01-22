%Analysis Variables
L = 15; %miles - length of pipeline
W = 12.67; %lbm/sec - flowrate of limestone
Ql=W; %ft^3/sec - flowrate of limestone
a = 0.01; %ft. - average lump size of limestone before grinding
g = 32.17; %ft/sec^2 - acceleration due to gravity
gc = 32.17; % conversion between lbf and lbm lbmft/lbfsec^2
pw = 62.4; %lbm/ft3 - density of water 
mew = 7.392*10^-4;%lbm/(ft-sec) - viscosity of water
gamma = 168.5; %lbm/ft3 - limestone density

%Design Variables
Qw=10; %ft^3/sec water flow rate
D=4; %ft - internal diameter of pipe
d=0.00007; %ft - average limestone particle size after grinding

%Analysis Functions
A = pi*D^2/4; %ft^2 - cross sectional area of pipe
Q = Ql+Qw; %ft^3/sec - total slurry flow rate
V = Q/A; %ft/sec - average flow velocity
c = Ql/(Q) % volumetric concentration of slurry
S=gamma/pw; % specific gravity of the limestone

Rw = pw*V*D/mew;
if Rw<=10^5
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

f = fw*(pw/p+150*c*(pw/p)*((g*D*(S-1))/(V^2*sqrt(Cd))^1.5));
PumpingPowerHP = f/550;
Pg = 218*W*(1/sqrt(d)-1/sqrt(a)); %ftlbf/sec - Power for grinding
GrindingPowerHP = Pg/550;

changep = f*p*L*V^2/(D*2*gc);
Pf = changep*Q; %ft-lbf/sec - Friction power loss
Vc = (40*g*c*(S-1)*D/sqrt(Cd))^0.5;
mdot = p*A*V;

PlantOperationHoursPerYear = 8*300*24; %hours
CostOfEnergy = 0.07; %cost per horsepowerhour
InitialCostGrinder = GrindingPowerHP*300;
InitialCostPump = PumpingPowerHP*200;
CostPerYear = PlantOperationHoursPerYear*(PumpingPowerHP+GrindingPowerHP)*CostOfEnergy;
InitialCost = InitialCostGrinder+InitialCostGrinder;
i=0.07;
n= 7;
NetPresentCost = InitialCost+(CostPerYear*(1+i)^n-1)/(i*(1+i)^n);

%inequality constraints
c(1) = D-6;
c(2) = 1.1*Vc-V;
c(3)
