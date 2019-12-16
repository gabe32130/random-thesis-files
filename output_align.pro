dir = "/Users/shens/mwrun/"
tipfile = dir + "L90Mpc8000_hithres.00400"
statfile = dir + "L90Mpc8000_hithres.00400.grpcenter"
velfile = dir +  "L90Mpc8000_hithres.00400.grpvc"
outfile = dir + "L90Mpc8000_hithres.00400.align"

lunit = 90. 
msolunit = 1.078e17
;goto, write
print, 'read tipsy'
;rtipsy, tipfile, h, gas, dark, star
;a = h.time 
;z = (1-a)/a


after:
close, 1
openr, 1, statfile 
nn = 0
readf, 1, nn
xc_all = fltarr(nn)
yc_all = fltarr(nn)
zc_all = fltarr(nn)
readf, 1, xc_all
readf, 1, yc_all
readf, 1, zc_all 

xc = xc_all[1]
yc = yc_all[1]
zc = zc_all[1]

close, 1

close, 1
openr, 1, velfile 
nn = 0
readf, 1, nn
vxc_all = fltarr(nn)
vyc_all = fltarr(nn)
vzc_all = fltarr(nn)
readf, 1, vxc_all
readf, 1, vyc_all
readf, 1, vzc_all 

vxc = vxc_all[1]
vyc =vyc_all[1]
vzc = vzc_all[1]

close, 1
retall
; shift to center

gas.pos[0] = gas.pos[0] - xc 
gas.pos[1] = gas.pos[1] - yc 
gas.pos[2] = gas.pos[2] - zc 
star.pos[0] = star.pos[0] - xc 
star.pos[1] = star.pos[1] - yc 
star.pos[2] = star.pos[2] - zc 
dark.pos[0] = dark.pos[0] - xc 
dark.pos[1] = dark.pos[1] - yc 
dark.pos[2] = dark.pos[2] - zc 

gas.vel[0] = gas.vel[0] - vxc 
gas.vel[1] = gas.vel[1] - vyc 
gas.vel[2] = gas.vel[2] - vzc 
star.vel[0] = star.vel[0] - vxc 
star.vel[1] = star.vel[1] - vyc 
star.vel[2] = star.vel[2] - vzc 
dark.vel[0] = dark.vel[0] - vxc 
dark.vel[1] = dark.vel[1] - vyc 
dark.vel[2] = dark.vel[2] - vzc


;after:
limit = 10.0/(lunit*1000./(1+z))
print, 'align'
align, gas, dark, star, limit

write:
print, 'write'
close, 1
openw, 1, outfile 
writeu, 1, h
writeu, 1, gas
writeu, 1, dark
writeu, 1, star

close, 1


end
