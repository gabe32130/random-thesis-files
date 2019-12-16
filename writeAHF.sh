#!/bin/tcsh -m 

#foreach step("00016" "00032" "00048" "00064" "00080" "00096" "00112" "00128" "00144" "00160" "00176" "00192" "00208" "00224" "00240" "00256" "00272" "00288" "00304" "00320" "00336" "00352" "00368" "00384" "00400" "00416" "00432" "00448" "00464" "00480" "00496" "00512")
#foreach iz(`jot 24 5 120`)
#foreach iz(45)
foreach iz(`seq 1 1 400`)
#foreach iz(512)
#foreach step("00105" "00067" "00062")
set step = `printf "%05d\n" $iz`
echo $step
cd /mn/stornext/d17/extragalactic/personal/gabrierg/Eris_AHF/
set outfile = L90Mpc8000_hithres.$step.input
set file = L90Mpc8000_hithres.$step
set dir = /mn/stornext/u3/shens/scratch/Eris_data/
echo $dir$file 90 2 > $outfile
echo $file >> $outfile
echo 256 >>  $outfile
echo 6 >>  $outfile
echo 6 >>  $outfile
echo 0 >>  $outfile
echo 0 >>  $outfile
echo 0 >>  $outfile
echo 0 >>  $outfile

end 
exit 
