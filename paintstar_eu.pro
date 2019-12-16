msolunit = 1.078e17
rho_mean = 0.042 
lunit = 90.
lunitkpc = 90000.
mH = 1.67e-24
rhounit = 1.00169e-29
dyrUnit = 1.22341e18/24./365./3600.
;goto, after
dir ='/pfs/shens/Eris/'
name = 'L90Mpc8000_hithres.'
logfile = dir + name + 'starlog'
gidfile = dir + name + '00015.gord_euonly' ; anyfile should have the same iorder list
outfile = dir + name + 'sid_paint'
dir1 ='/pfs/shens/Eris_data/'
ns_hist = lonarr(400)
nfiles = 400 
for i=0, nfiles-1 do begin 
   tipfile = dir1 + name + string(i+1, format = '(i5.5)') 
   read_tipsy_header, tipfile, h 
   ns_hist[i] = h.nstar 
endfor 

slog = rstarlog(logfile, /verbose)
ns = 0L
ns = n_elements(slog)
print, "total number of stars", ns
; each gas particle can sprout star particles with mass of 1/3 of the
; initial gas mass, but note that if the gas particles increases it
; can form more than 3 star particles 

norigin = 12936000 
sort_idx = sort(slog.iordergas)
sort_id = slog(sort(slog.iordergas)).iordergas
;sort_slog = slog(sort(slog.iordergas)) ; the whole structure sorted according to the iord number for gas
unique = uniq(sort_id) 
uid = sort_id(unique)
nu = n_elements(unique)
didx = lonarr(nu)
didx[0] = 2
for i=0l, nu-2 do begin 
   didx[i+1] = unique[i+1]-unique[i]
endfor 
; now uid is the unique number of iord for gas, didx is how many times
; this number repeated 
gidmap = replicate({nappear:0, start:0L, finish:0L}, norigin)

for j=0l, nu-1 do begin 
   if (j/10000*10000 eq j) then print, j, nu
   gidmap[uid[j]].nappear = didx[j]
   gidmap[uid[j]].finish = unique[j]
   gidmap[uid[j]].start =  unique[j]-didx[j]+1
endfor 

;retall
print, max(didx)
numbers =  didx(uniq(didx, sort(didx)))
; crazy gas particles, maximum 522 star particles formed out of one particle!  

close, 1
openr, 1, gidfile
ngeu = 0L
readf, 1, ngeu 
gid  = lonarr(ngeu)
tipid = lonarr(ngeu)
;eumass = fltarr(ngeu)
;gmass = fltarr(ngeu) 
n1 = 0L
n2 = 0L 
for i=0, ngeu-1 do begin 
   readf, 1, n1, n2, x1, x2
   gid[i] = n1
   tipid[i] = n2
 ;  eumass[i] = x1
 ;  mass[i] = x2
endfor
close, 1  

k = 0L
;record = {iOrderStar:0L, iOrderGas:0L, timeform:0.d, massform:0.0d}
;spaint = replicate(record, ns) 
sp_id_big = lonarr(ns) ; make a big array now, will trim it later
sp_gid_big = lonarr(ns)
for i=0L, ngeu-1 do begin
   if(i/10000*10000 eq i) then print, i, ngeu-1
   ;   index = where(slog.iordergas eq gid[i])
   nn= gidmap[gid[i]].nappear
   if(nn ne 0) then begin 
      sp_id_big[k:k+nn-1] = sort_idx[gidmap[gid[i]].start:gidmap[gid[i]].finish]
      sp_gid_big[k:k+nn-1] = gid[i]
      k = k+nn 
   endif 
endfor  
nstot = k 

print, "total number of stars need to be painted", nstot

sp_id = sp_id_big(0:nstot-1)
sp_gid = sp_gid_big(0:nstot-1)
sort_sp_id = sp_id(sort(sp_id))
sort_sp_gid = sp_gid(sort(sp_id))

record = {sid:0L,gid:0L,stepform:0,timeform:0.0d, massform:0.0d}
sout = replicate(record, nstot)

for i=0l, nstot-1 do begin 
   sout[i].sid = sort_sp_id[i]
   sout[i].gid = sort_sp_gid[i]
   for j=0,nfiles-1 do begin 
      if (sout[i].sid le ns_hist[j]-1) then begin 
         sout[i].stepform = j
         break
      endif 
   endfor 
   sout[i].timeform = slog[sout[i].sid].timeform
   sout[i].massform = slog[sout[i].sid].massform
endfor 

print, sout[0]
print, sout[1]

close, 1
openw, 1, outfile 
printf, 1, nstot
printf, 1, sout 
close, 1 

end 
