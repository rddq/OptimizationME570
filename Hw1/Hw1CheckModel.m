% Design variables
d = .06; % wire diameter
D = 0.7; % coil diameter
n = 7.5928; % number of coils in the spring
hf = 1.3691; % free height (spring exerting no force)

% Constants
G = 12e6;
Se = 45000;
w = 0.18;
Sf = 1.5;
Q= 150000;

% Analysis variables
h0 = 1.0; % preload height
delta0 = 0.4;

% Output variables
hdef = h0-delta0;
k = (G*d^4)/(8*D^3*n);
K = (4*D-d)/(4*(D-d))+0.62*d/D;
Fh0 = k*(hf-h0);
Fhdef = k*(hf-hdef);
tauh0 = (8*Fh0*D)/(pi*d^3)*K;
tauhdef = (8*Fhdef*D)/(pi*d^3)*K;

taum = (tauhdef+tauh0)/2;
taua = (tauhdef-tauh0)/2;

hs = n*d;
Fhs = k*(hf-hs);
tauhs = (8*Fhs*D)/(pi*d^3)*K;

Sy = 0.44*Q/(d^w);

first = taua+taum
second = Sy/Sf
