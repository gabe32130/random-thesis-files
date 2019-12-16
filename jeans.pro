gamma = 5./3. 
gamma = 1.
kb = 1.38d-16
g_newton = 6.67d-8
mh = 1.67d-24
pc = 3.08d18
msolar = 1.99d33
mu = 0.6

T = 500.
Mgas = 1e4 
N_res = 64. 
M_j = N_res*Mgas*msolar 

rho = 2.92^2. * (gamma*kb*T)^3./(g_newton*mu*mh)^3./M_j^2
nh = rho*0.764/mh
vs = sqrt(gamma*kb*T/mu/mh)
lambda_j = sqrt(!pi*gamma*kb*T/(g_newton*mu*mh*rho))
h = (3.*Mgas*msolar/(4.*!pi*rho))^0.33333*2.

print, "rho in g/cm^3", rho
print, "nH in cm^-3", nH
print, "jeans length in pc", lambda_j/pc
print, "sound speed in km/s", vs/1e5
print, "smoothing length in pc", h/pc
end 
