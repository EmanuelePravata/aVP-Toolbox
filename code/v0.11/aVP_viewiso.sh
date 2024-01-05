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
# Presumes normalization and resampling previous steps  
# Calls FSL's slicesdir to build .html display
#

StudyPath=$(< .//ONcontrol.txt)
procPath="${StudyPath}/data/proc"
viewnorm_L_Path="${StudyPath}/results/normalized_iso_L"
viewnorm_R_Path="${StudyPath}/results/normalized_iso_R"

mkdir "${viewnorm_L_Path}"
mkdir "${viewnorm_R_Path}"

#copy normalized and 0.6iso resampled segmentations to /L or /R folders into the /results study path folder. Run slicesdir to view output

while read sbj ;
do
	cp ${procPath}/${sbj}/onl_normalized_4bc_iso06.nii.gz ${viewnorm_L_Path}/${sbj}_norm_iso06.nii.gz
	echo ${sbj} Left copied 
	
	cp ${procPath}/${sbj}/onr_normalized_4bc_iso06.nii.gz ${viewnorm_R_Path}/${sbj}_norm_iso06.nii.gz
        echo ${sbj} Right copied

done < "${StudyPath}/data/sbj.list"

cd ${viewnorm_L_Path}
slicesdir *_norm_iso06.nii.gz

cd ${viewnorm_R_Path}
slicesdir *_norm_iso06.nii.gz

