; Calculates neutron star merger rates
; reading in SFR of the simulation 

th = 13.7*1000  ; bubble time in Myr 

file1 = '/Users/shens/mwrun/L90Mpc8000_hithres.00400.sfr_time.grp01'

close, 1
openr, 1, file1
id1 = 0 
string = "a"
nt = 0
readf, 1, id1
readf, 1, string 
print, string 
readf, 1, nt 
tbins = fltarr(nt)
z_arr = fltarr(nt)
sfh = fltarr(nt)
massform_cum = fltarr(nt)
mass_cum = fltarr(nt)

readf, 1, tbins
readf, 1, z_arr
readf, 1, sfh
readf, 1, massform_cum
readf, 1, mass_cum
close, 1 

; probablitity distribution for time-delay 
p1 = fltarr(nt)
; not normalized distribution 
p1 = tbins^(-1.0)
index = where(tbins lt 1e8)
p1(index) = 0.0 

index1 = where(tbins gt 1.37e10)
sfh(index1) = 0.0 

window, 0, retain = 1
plot, tbins, p1, xtitle = "time [yr]", ytitle = "Probability P(t)" 
window, 1, retain = 1
plot, tbins, sfh, xtitle = "time [yr]", ytitle = "SFH (M_sun/yr)"
 
NS_rate1 = fltarr(nt)
;for i=0, nt-1 do begin 
   NS_rate1 = convol(sfh, p1)
;endfor 

window, 2, retain = 1
plot, tbins, NS_rate1, xtitle = "time [yr]", ytitle = "r-process (M_sun/yr)", charsize = 1.5

end 
