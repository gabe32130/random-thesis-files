;pro OmegaHI, totalHI1, totalHI2, tipfile, HIfile1, HIfile2, binary1 = binary1, binary2 = binary2 
pro OmegaHI, totalHI1, tipfile, HIfile1, binary1 = binary1

rtipsy, tipfile, h, g, d, s

if (keyword_set(binary1) eq 0) then begin 
   close, 1 
   ntot = 0L 
   openr, 1, HIfile1 
   readf, 1, ntot
   HI1 = fltarr(ntot) 
   readf, 1, HI1 
   close, 1 
endif else begin 
   HI1 = rbarray(HIfile1) 
endelse  


;if (keyword_set(binary2) eq 0) then begin 
;   close, 1 
;   ntot = 0L 
;   openr, 1, HIfile2 
;   readf, 1, ntot
;   HI2 = fltarr(ntot) 
;   readf, 1, HI2 
;   close, 1 
;endif else begin 
;   HI2 = rbarray(HIfile2) 
;endelse  
ngas = h.ngas 
totalHI1 = total(g.mass*HI1(0:ngas-1))
;totalHI2 = total(g.mass*HI2(0:ngas-1))

print, "Omaga HI", totalHI1;, totalHI2
h = 0. 
g = 0.
d = 0. 
s = 0. 
HI1 = 0.
;HI2 = 0.

end 
