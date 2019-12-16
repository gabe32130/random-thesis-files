; calculate the SN II and SN Ia yield as used in gasoline 
; IMF 

min = 0.01 
max = 100.
nm = 1000000
dm = (max-min)/nm
mbins = findgen(nm)*dm + min  
dndm = fltarr(nm)
mtot = 1e4  ; total mass of gas particle

;goto, print
; kroupa 1993 IMF
ii1 = where(mbins ge 0.08 and mbins lt 0.5)
ii2 = where(mbins ge 0.5 and mbins lt 1)
ii3 = where(mbins ge 1)
dndm(ii1) = 2^0.9*mbins(ii1)^(-1.3)
dndm(ii2) = mbins(ii2)^(-2.2)
dndm(ii3) = mbins(ii3)^(-2.7)

integ = total(mbins*dndm*dm)
a = 1./integ

dndm = a*dndm  ; normalization

print, "coefficient, kroupa 1993", a 

retall
; kroupa 2001 IMF 

kk1 = where(mbins ge 0.01 and mbins lt 0.08)
kk2 = where(mbins ge 0.08 and mbins lt 0.5)
kk3 = where(mbins ge 0.5)
dndm_k = fltarr(nm)
dndm_k(kk1) = mbins(kk1)^(-0.3)
dndm_k(kk2) = mbins(kk2)^(-1.3)
dndm_k(kk3) = mbins(kk3)^(-2.3)
integ = total(mbins*dndm_k*dm)
a2 = 1./integ
dndm_k = a2*dndm_k

print, "coefficient, kroupa 2001", a2

; Chabrier IMF

jj1 = where(mbins le 1.)
jj2 = where(mbins gt 1.)
dndm_c = fltarr(nm)
mc = 0.08
sig = 0.69

b = exp(-alog10(mc)^2./(2*sig^2))

dndm_c(jj1) = exp(-(alog10(mbins(jj1)) - alog10(mc))^2. /(2.*sig^2))/mbins(jj1)
dndm_c(jj2) = b*mbins(jj2)^(-1.3)/mbins(jj2)

integ1 = total(mbins*dndm_c*dm)
a1 = 1./integ1

dndm_c = a1*dndm_c

print, "normalization Chabrier A, B", a1, b

plot, mbins, dndm, /ylog, /xlog
oplot, mbins, dndm_c, linestyle = 2

k = where(mbins ge 8. and mbins le 40.)
nsn = total(dndm(k)*dm(k))
nsnc = total(dndm_c(k)*dm(k))
nsnk = total(dndm_k(k)*dm(k))

print, "Kroupa 1993, Kroupa 2001,  Chabrier SN II per 1 solar mass", nsn, nsnk, nsnc

;mass = findgen(4000)*0.01 + 0.08
zmetal = alog10(0.0142) 
a0 = 10.13 + 0.07547*zmetal - 0.008084*(zmetal)^2
a1 = -4.424 - 0.7939*zmetal - 0.1187*zmetal^2
a2 = 1.262 + 0.3385*zmetal + 0.05417 *zmetal^2 

;logt = a0 + a1*alog10(mass) + a2*(alog10(mass))^2

;plot, mass, 10^logt, xtitle = 'stellar mass', ytitle = 'log life time', xrange = [8, 40], charsize = 1.5, /ylog, xstyle = 1
time = findgen(101)*1e6 + 1e6
logt = alog10(time)

root1 = fltarr(101)
root2 = fltarr(101)
for i=0, 100 do begin 
   a = a2 
   b = a1 
   c = a0-logt[i]
   root1[i] = (-b + sqrt(b^2 - 4*a*c))/(2*a)
   root2[i] = (-b - sqrt(b^2 - 4*a*c))/(2*a)
endfor 
mass = 10^root2

snrate = fltarr(101)
for i=0, 101-2 do begin 
   if (mass[i] gt 40.0 and mass[i+1] le 40.0) then begin
      index = where(mbins ge mass[i+1] and mbins lt 40.) 
      snrate[i] = total(dndm(index)*dm(index))
   endif 
   
   if (mass[i] lt 40.0 and mass[i+1] ge 8.0) then begin
      index = where(mbins ge mass[i+1] and mbins lt mass[i]) 
      snrate[i] = total(dndm(index)*dm(index))
   endif    
endfor 

print, snrate*6000*100

retall

idx = where (mbins ge 8. and mbins lt 40.)
n = n_elements(idx)
mfe = fltarr(n)
mo = fltarr(n)

mfe = mtot*2.802e-4*mbins(idx)^1.864*dndm(idx)*dm 
mo = mtot*4.586e-4*mbins(idx)^2.721*dndm(idx)*dm

mfe_c = mtot*2.802e-4*mbins(idx)^1.864*dndm_c(idx)*dm 
mo_c = mtot*4.586e-4*mbins(idx)^2.721*dndm_c(idx)*dm

mfe_c1 = mtot*0.375*exp(-17.94/mbins(idx))*dndm_c(idx)*dm  
mo_c1 = mtot*27.66*exp(-51.81/mbins(idx))*dndm_c(idx)*dm  

mfe_k = mtot*2.802e-4*mbins(idx)^1.864*dndm_k(idx)*dm 
mo_k = mtot*4.586e-4*mbins(idx)^2.721*dndm_k(idx)*dm

idxia = where(mbins ge 1.4 and mbins le 8)
;idxia = where(mbins le 8)
nia = n_elements(idxia)
phim2 = fltarr(nia)

maxb = 16. 
minb = 3. 
nmb = 1000.
dmb = (maxb-minb)/nmb
mbbins = findgen(nmb)*dmb + minb

for i =0L, nia - 1 do begin 
   if (2*mbins[idxia(i)] gt 3.) then begin 
      Minf = 2*mbins[idxia(i)] 
   endif else begin 
      Minf = 3.
   endelse 
   Msup = mbins[idxia(i)] + 8.
   idx2 = where(mbbins gt Minf and mbbins le Msup)
   if (idx2[0] ne -1) then begin 
      phim2(i) = 0.04847*total((mbins[idxia(i)]/mbbins(idx2))^2*mbbins(idx2)^(-2.7)*dmb)
   endif 
endfor 

rateia = mtot*total(phim2*dm)
mo_ia = 0.13*rateia
mfe_ia = 0.63*rateia 


for i =0L, nia - 1 do begin 
   if (2*mbins[idxia(i)] gt 3.) then begin 
      Minf = 2*mbins[idxia(i)] 
   endif else begin 
      Minf = 3.
   endelse 
   Msup = mbins[idxia(i)] + 8.
   idx2 = where(mbbins gt Minf and mbbins le Msup)
   if (idx2[0] ne -1) then begin 
      phim2(i) = 0.16*a2*total((mbins[idxia(i)]/mbbins(idx2))^2*mbbins(idx2)^(-2.3)*dmb)
   endif 
endfor 

rateia = mtot*total(phim2*dm)
mo_ia_k01 = 0.13*rateia
mfe_ia_k01 = 0.63*rateia 


for i =0L, nia - 1 do begin 
   if (2*mbins[idxia(i)] gt 3.) then begin 
      Minf = 2*mbins[idxia(i)] 
   endif else begin 
      Minf = 3.
   endelse 
   Msup = mbins[idxia(i)] + 8.
   idx2 = where(mbbins gt Minf and mbbins le Msup)
   if (idx2[0] ne -1) then begin 
      phim2(i) = 0.16*a1*b*total((mbins[idxia(i)]/mbbins(idx2))^2*mbbins(idx2)^(-2.3)*dmb)
   endif 
endfor 

rateia_c = mtot*total(phim2*dm)
mo_ia_c = 0.13*rateia_c
mfe_ia_c = 0.63*rateia_c 


print: 

print, "Kroupa 93:"
print, "type Ia supernva, O, Fe", mo_ia, mfe_ia
print, "type II O, Fe", total(mo)/mtot, total(mfe)/mtot
print, "total type II yield", (total(mfe) + total(mo))/mtot
print, "total yield", (total(mfe) + total(mo) + mo_ia + mfe_ia)/mtot
print, "total Oxygen", (total(mo) + mo_ia)/mtot
print, "[O/H] + 12", alog10((total(mo) + mo_ia)/mtot/0.737/16) + 12
print, "[Fe/H] + 12", alog10((total(mfe) + mfe_ia)/mtot/0.737/56) + 12

print, "Kroupa 2001:"
print, "type Ia supernva, O, Fe", mo_ia_k01, mfe_ia_k01
print, "type II O, Fe", total(mo_k)/mtot, total(mfe_k)/mtot
print, "total type II yield", (total(mo_k) + total(mfe_k))/mtot
print, "total Oxygen", (total(mo_k) + mo_ia_k01)/mtot
print, "total yield", (total(mo_k) + total(mfe_k) + mo_ia_k01 + mfe_ia_k01)/mtot
print, "total oxy yield", (total(mo_k) + mo_ia_k01)/mtot
print, "total fe yield", (total(mfe_k) + mfe_ia_k01)/mtot

print, "total metal yield", ((total(mo_k) + mo_ia_k01)*2.09 + (total(mfe_k) + mfe_ia_k01)*1.06)/mtot


print, "Chabrier"
print, "type Ia supernva, O, Fe", mo_ia_c, mfe_ia_c
print, "type II O, Fe", total(mo_c)/mtot, total(mfe_c)/mtot
print, "type II O, Fe (new yields)", total(mo_c1)/mtot, total(mfe_c1)/mtot
print, "total type II yield", (total(mfe_c) + total(mo_c))/mtot

print, "total yield", (total(mfe_c) + total(mo_c) + mo_ia_c + mfe_ia_c)/mtot
print, "[O/H] + 12", alog10((total(mo_c) + mo_ia_c)/mtot/0.737/16) + 12
print, "[Fe/H] + 12", alog10((total(mfe_c) + mfe_ia_c)/mtot/0.737/56) + 12

end
