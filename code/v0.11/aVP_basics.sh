#!/bin/bash
#
# This script is part of aVP-Toolbox v0.11 - 2023. 
#
# aVP-Toolbox ("The software") is licensed under the Creative Commons Attribution 4.0 International License, 
# permitting use, sharing, adaptation, distribution and reproduction in any medium or format, 
# as long as you give appropriate credit to the original author(s) and the source, provide 
# a link to the Creative Commons licence, and indicate if changes were made. 
# The licensor offers the Licensed Material as-is and as-available, and makes no 
# representations or warranties of any kind concerning the Licensed Material, 
# whether express, implied, statutory, or other. This includes, without limitation, 
# warranties of title, merchantability, fitness for a particular purpose, non-infringement, 
# absence of latent or other defects, accuracy, or the presence or absence of errors, 
# whether or not known or discoverable. Where disclaimers of warranties are not allowed 
# in full or in part, this disclaimer may not apply to You. 
# Please go to http://creativecommons.org/licenses/by/4.0/ to view a complete copy of this licence.
#
# The sosftware takes side and segment seprated masks and calculates the volume in each
#
# expects the following in $inPath/$sbj
#  oc_r.nii.gz 
#  oc_l.nii.gz
#  ot_r.nii.gz
#  ot_l.nii.gz
#  oninor_r.nii.gz
#  oninca_r.nii.gz
#  onincr_r.nii.gz
#  oninor_l.nii.gz
#  oninca_l.nii.gz
#  onincr_l.nii.gz
#
# writes output to $outPath/$outFile as
# SubjectID;nerveSegment:Side;Number of Voxels;Volume"

StudyPath=$(< ./ONcontrol.txt)
inPath="${StudyPath}/data/proc"
outPath="${StudyPath}/results"
outFile="volume_orig_20230708.csv"
mkdir $outPath
echo "Subject;NerveSegment;Side;NumberVoxels;Volume" >> "${outPath}/${outFile}"

while read sbj ;
do
        ii="${inPath}/${sbj}"
        for ss in r l ;
        do
		for nn in ot oc onincr oninca oninor ;
		do
			mm=${ii}/${nn}_${ss}
			vv=$(fslstats  ${mm} -V | awk '{ print $1 ";" $2}')
			echo "${sbj};${nn};${ss};${vv}"
                        echo "${sbj};${nn};${ss};${vv}" >> "${outPath}/${outFile}"

		done
        done

done < "${StudyPath}/data//sbj.list"

