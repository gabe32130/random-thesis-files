#!/bin/tcsh -m 

foreach iz(`seq 361 1 400`)
set step = `printf "%05d\n" $iz`
cd /mn/stornext/d17/extragalactic/personal/gabrierg/Eris_AHF/
set file = L90Mpc8000_hithres.$step.input
set output = L90Mpc8000_hithres.$step.out
/mn/stornext/u3/shens/scratch/amiga-v0.0/bin/AHFstep $file >> $output &

end

exit 
