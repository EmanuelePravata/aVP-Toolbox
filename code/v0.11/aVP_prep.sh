#!/bin/bash
# 
# This script is part of the aVP-Toolbox v0.11 - 2023 software. 
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
# Use thresholds to break-down the manual segmentations into a number of 
# optic nerve component segmentations, as well as a new unified segmentation.
#
#expects the following in StudyFolder/data/orig/SubjectID
# onc.nii.gz
# onr.nii.gz
# onl.nii.gz
# otr.nii.gz
# otl.nii.gz
#
#writes output to StudyFolder/data/proc/SubjectID 
#oc_r.nii.gz
#oc_l.nii.gz
#ot_r.nii.gz
#ot_l.nii.gz
#oninor_r.nii.gz
#oninca_r.nii.gz
#onincr_r.nii.gz
#oninor_l.nii.gz
#oninca_l.nii.gz
#onincr_l.nii.gz

StudyPath=$(< .//ONcontrol.txt)
inPath="${StudyPath}/data/orig"
outPath="${StudyPath}/data/proc"

if [[ -f "${StudyPath}/data/sbj.list" ]]; then rm "${StudyPath}/data/sbj.list"; fi

cd $inPath
for dir in *; 
do echo $dir >> "${StudyPath}/data/sbj.list"; 
done

mkdir "${StudyPath}/results"
mkdir "${outPath}"
while read sbj ;
do
        ii="${inPath}/${sbj}"
        oo="${outPath}/${sbj}"
        mkdir ${oo}
	echo $sbj $ii
    
 	for xx in r l ;
	do
		fslmaths ${ii}/ot${xx} -thr 10 -uthr 10 -bin -mul 16 ${oo}/ot_${xx}
		echo ${sbj} ont
	done

	fslmaths ${ii}/onc -thr 8 -uthr 8 -bin -mul 8 ${oo}/oc_r
	fslmaths ${ii}/onc -thr 9 -uthr 9 -bin -mul 8 ${oo}/oc_l
	echo ${sbj} onc

	for xx in r l ;
	do
		fslmaths ${ii}/on${xx} -thr 2 -uthr 2 -bin ${oo}/oninor_${xx}
		fslmaths ${ii}/on${xx} -thr 4 -uthr 4 -bin -mul 2 ${oo}/oninca_${xx}
		fslmaths ${ii}/on${xx} -thr 6 -uthr 6 -bin -mul 4 ${oo}/onincr_${xx}
        	echo ${sbj} oni ${xx}
	done
    	ls ${oo}

	for xx in r l ;
	do
		fslmaths ${oo}/ot_${xx} -add ${oo}/onincr_${xx} -add ${oo}/oninca_${xx} -add ${oo}/oninor_${xx} -add ${oo}/oc_${xx} ${oo}/on_${xx}
		ls ${oo}/on_${xx}.nii.gz
	done
done < "${StudyPath}/data/sbj.list"
