#!/bin/tcsh -m
foreach iz(`seq 1 1 400`)    #loop (start inc end)
#foreach iz(400)

set step=`printf "%05d\n" $iz`                                            #which sim
#set outdir=/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/ #where the file goes

#mv L90Mpc8000_hithres.$step.gord_eu_idx1 /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/L90Mpc8000_hithres.$step.gord_eu_idx1

#mv L90Mpc8000_hithres.$step.gord_euonly_cumu_idx1 /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/L90Mpc8000_hithres.$step.gord_euonly_cumu_idx1

#mv L90Mpc8000_hithres.$step.painteu.gidlist_idx1p0 /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/L90Mpc8000_hithres.$step.painteu.gidlist_idx1p0

#mv L90Mpc8000_hithres.$step.painteu.gidlist_idx1p0.log /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/L90Mpc8000_hithres.$step.painteu.gidlist_idx1p0.log

#mv L90Mpc8000_hithres.$step.sid_merger_0p05 /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/L90Mpc8000_hithres.$step.sid_merger_0p05

#mv output.$step.ord_sml_idx1p0 /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/output.$step.ord_sml_idx1p0

#mv output.$step.sid_merger_0p05 /mn/stornext/d17/extragalactic/personal/gabrierg/rprocess/output.$step.sid_merger_0p05

#cp -a /mn/stornext/d17/extragalactic/personal/shens/Eris_AHF/L90Mpc8000_hithres.$step.* /mn/stornext/d17/extragalactic/personal/gabrierg/Eris_AHF/

cp -a /mn/stornext/u3/shens/scratch/Eris_data/L90Mpc8000_hithres.$step /mn/stornext/d17/extragalactic/personal/gabrierg/Eris_AHF/

end
exit
