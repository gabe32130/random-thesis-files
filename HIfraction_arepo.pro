UnitLength_in_cm =        3.085678d21        ;  1.0 kpc
UnitMass_in_g    =        1.989d43 ;  1.0e10 solar masses
UnitVelocity_in_cm_per_s = 1d5  ;  1 km/sec
UnitTime_in_s= UnitLength_in_cm / UnitVelocity_in_cm_per_s
UnitDensity_in_cgs= UnitMass_in_g/ UnitLength_in_cm^3
UnitPressure_in_cgs= UnitMass_in_g/ UnitLength_in_cm/ UnitTime_in_s^2
UnitEnergy_in_cgs= UnitMass_in_g * UnitLength_in_cm^2 / UnitTime_in_s^2
GRAVITY   = 6.672d-8
BOLTZMANN = 1.3806d-16
PROTONMASS = 1.6726e-24
G=GRAVITY/ UnitLength_in_cm^3 * UnitMass_in_g * UnitTime_in_s^2
Xh=0.76D                        ; mass fraction of hydrogen
gamma= 5.0/3
mu = 0.6 

;dir = "/data/emergence4/deboras/Elliptical_ZoomIns/L40_512_LowDutyRadioWeak2EmTh0_01_HalfThermal_FixEta_BHChangeVel_RadEff/"
;outdir =
;"/data/emergence3/shens/Elliptical_ZoomIns/L40_512_LowDutyRadioWeak2EmTh0_01_HalfThermal_FixEta_BHChangeVel_RadEff/analysis/"
name = ['zoom_549_l11_large']
dir = '/data/ERCblackholes/shens/' + name[0] + '/'
outdir = '/data/ERCblackholes/shens/' + name[0] + '/analysis/'
iwrite = 1

;step = [10, 12, 15, 25] 
;step = [15]
;step = [72]
z = ['z3.0', 'z2.5', 'z1.0','z0.0'];, 'z0.5', 'z0.0']
step = [67, 74, 113, 203] 

for k=0, n_elements(step)-1 do begin 
print, "step", step[k]
snapshot = dir + 'snap_'+ string(step[k], format = '(i3.3)')+'.hdf5'
outfile = outdir + 'snap_'+ string(step[k], format = '(i3.3)')+'.HI'
file_id = H5F_OPEN(snapshot)
Header_id =  H5G_OPEN(file_id,'/Header')
npartall = H5A_READ(H5A_OPEN_NAME(Header_id, 'NumPart_Total'))
massarr = H5A_READ(H5A_OPEN_NAME(Header_id, 'MassTable'))
h = H5A_READ(H5A_OPEN_NAME(Header_id, 'HubbleParam'))
redshift = H5A_READ(H5A_OPEN_NAME(Header_id, 'Redshift'))
print, "redshift", redshift
npart = H5A_READ(H5A_OPEN_NAME(Header_id, 'NumPart_ThisFile'))
Ngas = npart(0)

print, "Ngas, npartall(0)", Ngas, npartall(0)

if npart(0) gt 0 then PartType0_id = H5G_OPEN(file_id,'/PartType0') 
if npart(0) gt 0 then Gas_rho = H5D_READ(H5D_OPEN(file_id, '/PartType0/Density'))
if npart(0) gt 0 then Gas_u = H5D_READ(H5D_OPEN(file_id, '/PartType0/InternalEnergy'))
if npart(0) gt 0 then Gas_metal = H5D_READ(H5D_OPEN(file_id, '/PartType0/GFM_Metallicity'))
if npart(0) gt 0 then HIabun = H5D_READ(H5D_OPEN(file_id, '/PartType0/NeutralHydrogenAbundance'))
if npart(0) gt 0 then H5G_CLOSE, PartType0_id 
print, "maximum and minimum gas metallicity", max(gas_metal), min(gas_metal)
print, "max and min HI abundance", max(HIabun), min(HIabun)

H5G_CLOSE, Header_id
H5F_CLOSE, File_id     
YH = dblarr(npart(0))

; the total mass fraction in H is about 0.764 for primordial gas, but
; with increase metallicity the abundance of He usually increase. Here
; I follow the observation relation in Jimenez et al. 2003 
for i=0L, npart(0) -1 do begin 
   if (Gas_metal[i] le 0.1) then begin 
      YHe =  (0.236 + 2.1*Gas_metal[i])/4.0 ; 
   endif else begin 
      YHe = (-0.446*(Gas_metal[i] - 0.1)/0.9 + 0.446)/4.0 ;
   endelse 

   YH[i] = 1.0 - YHe*4.0 - Gas_metal[i] 
endfor 
 
print, "min max total H mass fraction", min(YH), max(YH)   
 frac_HI = HIabun*YH 
print, "min max HI fraction", min(frac_HI), max(frac_HI) 
if (iwrite eq 1) then begin 
    close, 1
    openw, 1, outfile 
    printf, 1, n_elements(frac_HI)
    printf, 1, frac_HI
    close, 1 
endif 

endfor 

end 
