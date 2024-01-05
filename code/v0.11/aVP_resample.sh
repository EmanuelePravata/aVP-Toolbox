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
# Takes the linearized and normalized images and makes isotropic 0.6mm versions of them
# expects: 
#  $imPath/StudyID/onl_normalized_4.nii.gz
#  $imPath/StudyID/onr_normalized_4.nii.gz
#  $imPath/StudyID/onl_linearize_4.nii.gz
#  $imPath/StudyID/onr_linearize_4.nii.gz
#
# produces: 
#  $imPath/StudyID/onl_normalized_4_iso6.nii.gz
#  $imPath/StudyID/onr_normalized_4_iso6.nii.gz
#  $imPath/StudyID/onl_linearize_4_iso06.nii.gz
#  $imPath/StudyID/onr_linearize_4_iso06.nii.gz
#

StudyPath=$(< ./ONcontrol.txt)
imPath="${StudyPath}/data/proc"
anat="on"

baseImage="_linearize_4bc.nii.gz"

while read sbj ;

do
    for ss in r l ;
    do
        ii=${imPath}/${sbj}/${anat}${ss}${baseImage}
        nn=$(basename $ii .nii.gz)
        mm=$(dirname  $ii)
	echo $ii
	echo $nn
	echo $mm
        fslmaths ${ii} -mul 1 ${mm}/${nn}2.nii.gz
	fslorient -setqformcode 1 ${mm}/${nn}2.nii.gz
        fslorient -setsformcode 1 ${mm}/${nn}2.nii.gz
    
       fslhd -x ${mm}/${nn}2.nii.gz | sed "s/dy = '[^\']*'/dy = '0.0245'/g" > ${mm}/hd.xml
       
    
        fslcreatehd ${mm}/hd.xml ${mm}/${nn}2.nii.gz
	rm ${mm}/hd.xml 
	fslorient -copyqform2sform ${mm}/${nn}2.nii.gz
#
#  set the origin to centre of first slice
#
#
        flirt -in ${mm}/${nn}2.nii.gz -ref ${mm}/${nn}2.nii.gz -applyisoxfm 0.6 -datatype int -interp nearestneighbour -nosearch -out ${mm}/${nn}_iso06pre
        imcp ${mm}/${nn}_iso06pre ${mm}/${nn}_iso06
        fslorient -setsform -0.6 0 0 74.4 0 0.6 0 -60.6  0 0 0.6 -21.0 0 0 0 1 ${mm}/${nn}_iso06
        fslorient -setqform -0.6 0 0 74.4 0 0.6 0 -60.6  0 0 0.6 -21.0 0 0 0 1 ${mm}/${nn}_iso06 
    	
	rm ${mm}/${nn}_iso06pre.nii.gz
	rm ${mm}/${nn}2.nii.gz
    done
done < "${StudyPath}/data/sbj.list"

#done


baseImage="_normalized_4bc.nii.gz"

while read sbj ;

do
    for ss in r l ;
    do
        ii=${imPath}/${sbj}/${anat}${ss}${baseImage}
        nn=$(basename $ii .nii.gz)
        mm=$(dirname  $ii)
	echo $ii
	echo $nn
	echo $mm
        fslmaths ${ii} -mul 1 ${mm}/${nn}2.nii.gz
	fslorient -setqformcode 1 ${mm}/${nn}2.nii.gz
        fslorient -setsformcode 1 ${mm}/${nn}2.nii.gz
    
       fslhd -x ${mm}/${nn}2.nii.gz | sed "s/dy = '[^\']*'/dy = '0.0245'/g" > ${mm}/hd.xml
       
    
        fslcreatehd ${mm}/hd.xml ${mm}/${nn}2.nii.gz
	rm ${mm}/hd.xml 
	fslorient -copyqform2sform ${mm}/${nn}2.nii.gz
#
#  set the origin to centre of first slice
#
#
        flirt -in ${mm}/${nn}2.nii.gz -ref ${mm}/${nn}2.nii.gz -applyisoxfm 0.6 -datatype int -interp nearestneighbour -nosearch -out ${mm}/${nn}_iso06pre
        imcp ${mm}/${nn}_iso06pre ${mm}/${nn}_iso06
        fslorient -setsform -0.6 0 0 74.4 0 0.6 0 -60.6  0 0 0.6 -21.0 0 0 0 1 ${mm}/${nn}_iso06
        fslorient -setqform -0.6 0 0 74.4 0 0.6 0 -60.6  0 0 0.6 -21.0 0 0 0 1 ${mm}/${nn}_iso06 
    	
	rm ${mm}/${nn}_iso06pre.nii.gz
	rm ${mm}/${nn}2.nii.gz
    done
done < "${StudyPath}/data/sbj.list"
#done
