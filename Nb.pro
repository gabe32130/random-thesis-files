;dir =  '/Users/shens/mwrun/'

msolunit = 1.078e17
rho_mean = 0.0462 
lunit = 90.
kpcunit = 90000.
gmperccunit = 1.00169e-29
kmpersecunit = 2269.98
dhubble0 = 2.8944 ; code
vunit = 2269.98
omega_l = 0.76
omega_m = 0.24
m_pro = 1.6726d-24
Ao  = 15.9994
Ac = 12.0107
Afe = 55.845
Asi = 28.0855
Amg = 24.30506

kpctocm = 3.086d21
msun = 1.99d33
mpro = 1.67e-24
;z = 3;.03
z = 3.033248
sigcode_to_phys = msolunit/(kpcunit/(1+z))^2.

dir =  '/Users/shens/mw_newmc/'
sigfile1 = dir +  'L90Mpc8000_hithres_newmc.00063.NOVI_xy_hires'
sigfile2 = dir + 'L90Mpc8000_hithres_newmc.00063.NOVI_xy_hish'

nx = 0
ny = 0 

close, 1
openr, 1, sigfile1
readf, 1, nx, ny, xc, yc,zc, xl, yl, zl 
sig_ion_xy = fltarr(nx, ny)

for j=0L, ny-1 do begin
   for i=0L, nx-1 do begin
      readf, 1, tmp
      sig_ion_xy(i, j) = tmp
   endfor 
endfor 

close, 1

openr, 1, sigfile2
readf, 1, nx, ny, xc, yc,zc, xl, yl, zl 
sig_ion_xy2 = fltarr(nx, ny)

for j=0L, ny-1 do begin
   for i=0L, nx-1 do begin
      readf, 1, tmp
      sig_ion_xy2(i, j) = tmp
   endfor 
endfor 

close, 1

;endif 
xbins = fltarr(nx)
ybins = fltarr(ny)
xmax = xc + xl
xmin = xc - xl
ymax = yc + yl 
ymin = yc - yl 

xbins = findgen(nx)*(xmax-xmin)/(nx-1) + xmin
ybins = findgen(ny)*(ymax-ymin)/(ny-1) + ymin
xbinsp = (xbins-xc)*90000./(1+z)
ybinsp = (ybins-yc)*90000./(1+z)

; N_ion vs impact parameter
n = n_elements(sig_ion_xy)

rho = fltarr(n) 
ionp = fltarr(n)
ionp2 = fltarr(n)

for i=0L, n -1 do begin
   jj = 0L
   ii = 0L
   jj = i/ny
   ii = i - jj*ny 
   rho[i] = sqrt(xbinsp[ii]^2. + ybinsp[jj]^2)
   ;rho1[i] = sqrt(xbinsp1[ii]^2. + ybinsp1[jj]^2)
   ionp[i] = sig_ion_xy(ii, jj)
   ionp2[i] = sig_ion_xy2(ii,jj)
endfor 

lmax = max(alog10(rho)) 
;lmax = 100.0
lmin = 0.
nl = 50.
dl = (lmax-lmin)/nl
lbins = findgen(nl)*dl + lmin 
med_ion = fltarr(nl)
ave_ion = fltarr(nl)

med_ion2 = fltarr(nl)
ave_ion2 = fltarr(nl)


for j = 0, nl-2 do begin 
   index = where(alog10(rho) ge lbins[j] and alog10(rho) lt lbins[j]+dl)
   if(index[0] ne -1) then begin 
      med_ion[j] = median(ionp(index))
      ave_ion[j] = total(ionp(index))/n_elements(index)
      
      med_ion2[j] = median(ionp2(index))
      ave_ion2[j] = total(ionp2(index))/n_elements(index)
     endif 
endfor 

loadct, 39
item = ['O VI']
plottops = 1
!p.multi = [0, 1, 1]

if (plottops eq 1) then begin 
   entry_device = !d.name
   set_plot,'PS'
   device, bits_per_pixel = 8,/portrait, color = 1,filename ='N_b_OVI_UV.eps', xsize = xs, ysize =ys, xoffset=xoffset, yoffset=yoffset, /inches 
   tk = 3
   csize = 0
   yti = 'log(N!l'+item[0]+'!n) [cm!u-2!n]'
endif else begin 
   tk = 1
   window, 1, retain = 2
   csize = 1.5
    yti = 'log(N!l'+item[0]+'!n) [cm!u-2!n]'
endelse 

;window, 0, retain = 2
;plot, rho, alog10(ionp), psym = 3, xtitle = 'Impact parameter b [kpc]', ytitle = yti, charsize = csize,yrange =[12, 22], /xlog, xrange = [1, 300], xstyle = 1
;oplot, rho, alog10(ionp1), color = 160, psym = 3
;oplot, 10^lbins, alog10(med_ion), color = 70, thick = tk
;oplot, 10^lbins, alog10(ave_ion), color = 250, thick = tk

plot, 10^lbins, alog10(ave_ion), xtitle = 'Impact parameter b [kpc]', ytitle = yti, charsize = csize,yrange =[12, 16], /xlog, xrange = [1, 200], xstyle = 1
oplot, 10^lbins, alog10(ave_ion2), linestyle = 2
oplot, 10^lbins, alog10(med_ion), color = 250
oplot, 10^lbins, alog10(med_ion2), color = 250, linestyle = 2 
legend, item, box = 0, /top, /right

items = ['UVB z = 3', 'Shielded']
legend, items, linestyle = [0, 2], /bottom, /right

items1 = ['average', 'mediam']
legend, items1, color = [0, 250], /bottom, /left, linestyle = 0

if (plottops eq 1) then begin 
   device, /close_file
   set_plot, entry_device
endif 
;print, "C code", max(sig_ion)
;print, "idl code", max(sig_ion1)

retall

rvir = 48.0
rmax = 48.0 
rmin = -48.0
xp = findgen(101)*((rmax-rmin)/100.) + rmin 
yp = sqrt(rvir^2. - xp^2.)

;maxion = 15.0
;minion = 10.0 
minion = 17.0
maxion = 22.0

loadct, 39
zsolar = 0.0142

image = bytscl(alog10(sig_ion), max=maxion, min=minion, top=255)


!p.multi = [0, 0, 0]
;plot:
xwidth = 8.5
ywidth = 11.0 
xs = 8.0
ys = 8.0
xoffset = (xwidth - xs)*0.5
yoffset = (ywidth - ys)*0.5 
;plottops = 0

if (plottops eq 1) then begin 
   entry_device = !d.name
   set_plot,'PS'
   device, bits_per_pixel = 8,/portrait, color = 1,filename ='ErisNew_z3_ionmap_HI_xy_cut.eps', xsize = xs, ysize =ys, xoffset=xoffset, yoffset=yoffset, /inches 
   tk = 3
   barti = 'log(N!l'+item[0]+'!n) [cm!u-2!n]'
endif else begin 
   tk = 1
   window, 2, retain = 2
   barti = 'log(N!l' +item[0] +'!n) [cm!u-2!n]'
endelse 

xw = [0.12, 0.90]
yw = [0.12, 0.90]
xsize = (xw[1] - xw[0])
ysize = (yw[1]-yw[0])

position0 = [xw[0], yw[0], xw[1], yw[1]]

barpos0 = [xw[0]+0.02, yw[0]+0.05, xw[1]-0.02, yw[0]+0.07]

xnulltick = replicate(' ', 5)
ynulltick = xnulltick
xnullp = replicate(' ', 1)

;loadct, 39
loadct, 0
bw = 0
cgplot, xbinsp, ybinsp, /nodata, xrange = [-250, 250], yrange = [-250, 250], position = position0, charsize = 1, charthick = tk, ytitle = 'y [kpc]', axiscolor = bw, xstyle = 1, ystyle = 1, xtitle = 'x [kpc]'
loadct, 39  
cgimage, image, /noerase, /overplot
;retall
loadct, 0
cgplot, xbinsp, ybinsp, /nodata, xrange = [-250, 250], yrange = [-250, 250], position = position0, charsize = 1, charthick = tk, /noerase, axescolor = 254, xtickname = xnulltick, ytickname = ynulltick, xthick = tk, ythick = tk, xstyle = 1, ystyle = 1 
cgplot, [0, 0], [0, 0], psym = 1, /overplot, /noerase, thick = tk
cgplot, xp, yp, thick = tk,/overplot, /noerase
cgplot, xp, -yp, thick = tk,/overplot, /noerase

legend, item, /top, /left, box = 0, charthick = tk, textcolor = 254, charsize = 1.5
loadct, 39
;colorbar, position =barpos0, ticknames = ['10.0', '11.0', '12.0', '13.0', '14.0','15.0'],divisions = 5, charsize = 0, color = 255, title = barti, charthick = tk

colorbar, position =barpos0, ticknames = ['17.0', '18.0', '19.0', '20.0', '21.0','22.0'],divisions = 5, charsize = 0, color = 255, title = barti, charthick = tk

if (plottops eq 1) then begin 
   device, /close_file
   set_plot, entry_device
endif 




end
