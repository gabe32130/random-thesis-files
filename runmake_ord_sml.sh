#!/bin/tcsh -m
#foreach iz(`seq 1 1 12`)     #loop (start inc end)
#foreach iz(`seq 13 1 34`)    #no .painteu.gidlist before 13
#foreach iz(`seq 41 1 70`)
#foreach iz(`seq 71 1 100`)
#foreach iz(`seq 101 1 130`)
#foreach iz(`seq 131 1 160`)
#foreach iz(`seq 161 1 190`)
#foreach iz(`seq 191 1 220`)
#foreach iz(`seq 221 1 250`)
#foreach iz(`seq 251 1 280`) #redo
#next foreach iz(`seq 281 1 310`) #no more disk space for this and on
#next foreach iz(`seq 311 1 340`)
#next foreach iz(`seq 341 1 370`)
#next foreach iz(`seq 371 1 400`)
#foreach iz(1 2 3 4 5 `seq 35 1 400`)
foreach iz(`seq 35 1 40`)
#foreach iz(251)


set name = L90Mpc8000_hithres                                            #the sim
set step = `printf "%05d\n" $iz`                                         #which sim
set tipsydir=/mn/stornext/u3/shens/scratch/Eris_data/                    #where the sims are
set iorddir=/mn/stornext/u3/shens/scratch/Eris_data/iordfile/            #where .iord files are
set outdir=/uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/ #where outfile goes


set tipfile=$name.$step                         #the main sim snapshot
set listfile=$name.$step.iord                   #snapshot with extension .iord
set gridfile=$name.$step.painteu.gidlist_idx1p0 #the output from step 1
set outfile=$name.$step.gord_eu_idx1            #this output
#echo $tipfile
#echo $gridfile
#echo $outfile


#set pbsfile = $name.$step.painteu.pbs
#set pbsfile = $name.$step.gord_eu.pbs
#set pbsfile = $name.$step.gord_eu_cumu_200Myr.pbs
#set pbsfile = $name.$step.smooth.pbs
#echo $pbsfile
#qsub $pbsfile
#echo $tipfile


./make_ord_sml /mn/stornext/u3/shens/scratch/Eris_data/$tipfile /mn/stornext/u3/shens/scratch/Eris_data/iordfile/$listfile /uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/$gridfile /uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/$outfile >> /uio/hume/student-u56/gabrierg/Desktop/thesis_code/trial_run/output.$step.ord_sml_idx1p0 &


end
exit
