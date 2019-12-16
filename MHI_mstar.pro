datafile = 'MHI_Mstar.dat'
close, 1 
openr, 1, datafile
nlines = file_lines(datafile)
ncom = 46 
ndata = nlines - ncom 
comment = 'comment'

struc = {agc:0L, f_agc:'s', rah:0, ram:0, ras:0.0, de:'s', ded:0, dem:0, des:0, fuvmag:0.0, efuvmag:0.0, nuvmag:0.0, enuvmag:0.0, rmag:0.0, ermag:0.0, umr:0.0, eumr:0.0, sflag:'a', dis:0.0, edis:0.0, logmHI:0.0, elogmHI:0.0, logms:0.0, elogms:0.0, logsfr:0.0, elogsfr:0.0}
data = replicate(struc, ndata)

for i=0, ncom-1 do begin 
   readf, 1, comment 
endfor 
for i=0, ndata-1 do begin 
   readf, 1, struc, format = '(I6, A1, 1x, I2, 1x, I2, 1x, f4.1, 1x, a1, 3(i2, 1x), 2(f7.2, 1x), f5.2, 1x, f4.2, 1x, f5.2, 1x, 3(f4.2, 1x), a6, 1x, f4.1, 1x, f3.1, 1x, 4(f4.2, 1x), f5.2, 1x, f4.2, 1x)'
   data[i] = struc
endfor 

close, 1

print, data[0]
print, data[ndata-1]

index = where(data.logms ne 0.)
subdata = data(index)

ms = [1.15e8, 3.40e7, 9.60e4, 5.30e5]
mhi = [2.34e7, 1.98e7, 1.96e6, 5.40e5]
fgas = mhi/ms

ms_data = 10^subdata.logms
ms_data_up = 10^(subdata.logms+ subdata.elogms)
sig_ms = ms_data_up - ms_data
rel_ms = sig_ms/ms_data

mhi_data = 10^subdata.logmhi
mhi_data_up = 10^(subdata.logmhi+subdata.elogmhi)
sig_mhi = mhi_data_up - mhi_data 
rel_mhi = sig_mhi/mhi_data 

rel_err = sqrt(rel_ms^2 + rel_mhi^2)
fgas_data = mhi_data/ms_data 
sig_fgas = rel_err*fgas_data

logf_data = alog10(fgas_data)
sigf_data = alog10(sig_fgas) 

fgas_leop = [2.6, 2.6]
fgas_leop_up = fgas_leop + 0.5 
fgas_leop_lo = fgas_leop - 0.5 

fleo = alog10(fgas_leop)
sigleo1 = alog10(fgas_leop_up)-alog10(fgas_leop)
sigleo2 = alog10(fgas_leop)-alog10(fgas_leop_lo)

ms_leo = [3.6e5, 3.6e5]
logms_leo = alog10(ms_leo)

loadct, 39
plottops = 1
if (plottops eq 1) then begin 
   entry_device = !d.name
   set_plot,'PS'
   device, bits_per_pixel = 8,/portrait, color = 1,filename ='fHI_Ms.eps';, xsize = xs, ysize =ys, xoffset=xoffset, yoffset=yoffset, /inches 
   tk = 3
endif else begin 
   tk = 1
   window, 0, retain = 2
endelse 

colors = [250, 100, 70, 160]

;plot, subdata.logms, subdata.logmHI, psym = 4, symsize = 1.5,xtitle = "log(M!l*!n/M"+sunsymbol()+")", ytitle = "log(M!lH I!n/M"+sunsymbol()+")", xthick = tk, ythick = tk, thick = tk, charthick = tk, xrange = [10, 4], yrange = [5, 9.5], charsize = 1.5, ystyle = 1, xticks = 6

loadct, 0
plot, subdata.logms, logf_data, psym = 4, symsize = 1.5,xtitle = "log(M!l*!n/M"+sunsymbol()+")", ytitle = "log(M!lHI!n/M!l*!n)", xthick = tk, ythick = tk, thick = tk, charthick = tk, xrange = [10, 4], yrange = [-4, 5],  charsize = 1.5, ystyle = 1, xticks = 6,/nodata

oploterror, subdata.logms, logf_data, subdata.elogms, sigf_data, psym = 4, symsize = 1.5, errthick = tk, color = 150, errcolor = 150
oplot, logms_leo, fleo, psym = 6, symsize = 1.5, thick = tk
;oploterror, logms_leo, fleo, sigleo1, /hibar,psym = 6, symsize = 1.5, errthick = tk, thick = tk
;oploterror, logms_leo, fleo, sigleo2, /lobar,psym = 6, symsize = 1.5, errthick = tk, thick = tk

loadct, 39
for i=0, 3 do begin 
  ; oplot, [alog10(ms[i]), alog10(ms[i])], [alog10(mhi[i]), alog10(mhi[i])], psym = sym(1), symsize = 1.5, color = colors[i]
   oplot, [alog10(ms[i]), alog10(ms[i])], [alog10(fgas[i]), alog10(fgas[i])], psym = sym(1), symsize = 1.5, color = colors[i]
endfor 
items = ['Bashful', 'Doc', 'Dopey','Grumpy']
legend, items, color = colors, psym= sym(1), charthick = tk, symsize = [1.5, 1.5, 1.5, 1.5], /top, /left

loadct, 0
item = ['Huang et al. (2012)', 'Giovanelli et al. (2013)']
legend, item, psym = [4, 6], box = 0, symsize = [1.5, 1.5], color=[150, 0], /right, /bottom, charthick = tk, thick =tk

label = ['Leo P']
legend, label, box = 0, charthick = tk, pos = [0.72, 0.52], /norm

if (plottops eq 1) then begin 
   device, /close_file
   set_plot, entry_device
endif 

end 
