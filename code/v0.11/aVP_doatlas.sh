#!/bin/bash
#
# This script is part of the aVP-Toolbox v0.11, 12.2023 software
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
# Takes the on?_normalized_4.nii.gz images and binarizes them and makes a joint mask
# then divides by the number of sides for each to get percentage masks
# 
# Does the same for each iOrb, iCan, iCran, OC and OT subdivisions
#
# expects 
#  $imPath/StudyID/onl_normalized_4_iso06.nii.gz
#  $imPath/StudyID/onr_normalized_4_iso06.nii.gz


StudyPath=$(< ./ONcontrol.txt)
imPath="${StudyPath}/data/proc"
templPath="${StudyPath}/templates"
mkdir $templPath
NormdImage="_normalized_4bc_iso06.nii.gz"



pwd


sbjcount=0

while read sbj ;
do
    echo $sbj
    let sbjcount=${sbjcount}+1;
    for ss in r l ;
    do
        if [ "${sbjcount}" = "1" ] ;
        then
            echo "A"
            fslmaths "${imPath}/${sbj}/on${ss}${NormdImage}" -bin "${templPath}/"tonbb${ss}
            if [ "${ss}" = "r" ] ;
            then
                echo "1"
                fslmaths "${templPath}/"tonbb${ss} -mul 1 "${templPath}/"tonbbW
            else
                echo "2"
                fslmaths "${templPath}/"tonbb${ss} -add "${templPath}/"tonbbW "${templPath}/"tonbbW
            fi
        else
            echo "B"
            fslmaths "${imPath}/${sbj}/on${ss}${NormdImage}" -bin -add "${templPath}/"tonbb${ss} "${templPath}/"tonbb${ss}
            fslmaths "${imPath}/${sbj}/on${ss}${NormdImage}" -bin -add "${templPath}/"tonbbW "${templPath}/"tonbbW
        fi
    done
    echo $sbj $sbjcount
done < "${StudyPath}/data/sbj.list"


# calculate the percentages
fslmaths "${templPath}/"tonbbr -mul 100 -div ${sbjcount} "${templPath}/"aVP_prob_r
fslmaths "${templPath}/"tonbbl -mul 100 -div ${sbjcount} "${templPath}/"aVP_prob_l
fslmaths "${templPath}/"tonbbW -mul 100 -div ${sbjcount} -div 2 "${templPath}/"aVP_prob

#remove temp files
rm "${templPath}/"ton*

echo "Atlas created from" $sbjcount "subjects. Now generating anatomical subdivision probability masks. . . "



# generate iOrb prob masks

while read sbj ;
do
        ii="${imPath}/${sbj}"
        
        echo "Splitting" $sbj $ii

		fslmaths ${ii}/onl_normalized_4bc_iso06.nii.gz -thr 1 -uthr 1 -bin ${ii}/l_norm_iso06_iOrb
		fslmaths ${ii}/onl_normalized_4bc_iso06.nii.gz -thr 2 -uthr 2 -bin ${ii}/l_norm_iso06_iCan
		fslmaths ${ii}/onl_normalized_4bc_iso06.nii.gz -thr 4 -uthr 4 -bin ${ii}/l_norm_iso06_iCran
		fslmaths ${ii}/onl_normalized_4bc_iso06.nii.gz -thr 8 -uthr 8 -bin ${ii}/l_norm_iso06_OC
        	fslmaths ${ii}/onl_normalized_4bc_iso06.nii.gz -thr 16 -uthr 16 -bin ${ii}/l_norm_iso06_OT
		
		fslmaths ${ii}/onr_normalized_4bc_iso06.nii.gz -thr 1 -uthr 1 -bin ${ii}/r_norm_iso06_iOrb
		fslmaths ${ii}/onr_normalized_4bc_iso06.nii.gz -thr 2 -uthr 2 -bin ${ii}/r_norm_iso06_iCan
		fslmaths ${ii}/onr_normalized_4bc_iso06.nii.gz -thr 4 -uthr 4 -bin ${ii}/r_norm_iso06_iCran
		fslmaths ${ii}/onr_normalized_4bc_iso06.nii.gz -thr 8 -uthr 8 -bin ${ii}/r_norm_iso06_OC
		fslmaths ${ii}/onr_normalized_4bc_iso06.nii.gz -thr 16 -uthr 16 -bin ${ii}/r_norm_iso06_OT

done < "${StudyPath}/data/sbj.list"


NormdImage="_norm_iso06_iOrb"
sbjcount=0

while read sbj ;
do
    echo $sbj
    let sbjcount=${sbjcount}+1;
    for ss in r l ;
    do
        if [ "${sbjcount}" = "1" ] ;
        then
            echo "A"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin "${templPath}/"iOrb_ton${ss}
            if [ "${ss}" = "r" ] ;
            then
                echo "1"
                fslmaths "${templPath}/"iOrb_ton${ss} -mul 1 "${templPath}/"iOrb_tonW
            else
                echo "2"
                fslmaths "${templPath}/"iOrb_ton${ss} -add "${templPath}/"iOrb_tonW "${templPath}/"iOrb_tonW
            fi
        else
            echo "B"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"iOrb_ton${ss} "${templPath}/"iOrb_ton${ss}
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"iOrb_tonW "${templPath}/"iOrb_tonW
        fi
    done
    echo $sbj $sbjcount
done < "${StudyPath}/data/sbj.list"


# calculate the percentages
fslmaths "${templPath}/"iOrb_tonr -mul 100 -div ${sbjcount} "${templPath}/"iOrb_prob_r
fslmaths "${templPath}/"iOrb_tonl -mul 100 -div ${sbjcount} "${templPath}/"iOrb_prob_l
fslmaths "${templPath}/"iOrb_tonW -mul 100 -div ${sbjcount} -div 2 "${templPath}/"iOrb_prob

#remove temp files
rm "${templPath}/"iOrb_ton*

echo "iOrb probability mask created from" $sbjcount "subjects." 




# generate iCan prob masks

NormdImage="_norm_iso06_iCan"
sbjcount=0

while read sbj ;
do
    echo $sbj
    let sbjcount=${sbjcount}+1;
    for ss in r l ;
    do
        if [ "${sbjcount}" = "1" ] ;
        then
            echo "A"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin "${templPath}/"iCan_ton${ss}
            if [ "${ss}" = "r" ] ;
            then
                echo "1"
                fslmaths "${templPath}/"iCan_ton${ss} -mul 1 "${templPath}/"iCan_tonW
            else
                echo "2"
                fslmaths "${templPath}/"iCan_ton${ss} -add "${templPath}/"iCan_tonW "${templPath}/"iCan_tonW
            fi
        else
            echo "B"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"iCan_ton${ss} "${templPath}/"iCan_ton${ss}
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"iCan_tonW "${templPath}/"iCan_tonW
        fi
    done
    echo $sbj $sbjcount
done < "${StudyPath}/data/sbj.list"


# calculate the percentages
fslmaths "${templPath}/"iCan_tonr -mul 100 -div ${sbjcount} "${templPath}/"iCan_prob_r
fslmaths "${templPath}/"iCan_tonl -mul 100 -div ${sbjcount} "${templPath}/"iCan_prob_l
fslmaths "${templPath}/"iCan_tonW -mul 100 -div ${sbjcount} -div 2 "${templPath}/"iCan_prob

#remove temp files
rm "${templPath}/"iCan_ton*

echo "iCan probability mask created from" $sbjcount "subjects." 



# generate iCran prob masks

NormdImage="_norm_iso06_iCran"
sbjcount=0

while read sbj ;
do
    echo $sbj
    let sbjcount=${sbjcount}+1;
    for ss in r l ;
    do
        if [ "${sbjcount}" = "1" ] ;
        then
            echo "A"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin "${templPath}/"iCran_ton${ss}
            if [ "${ss}" = "r" ] ;
            then
                echo "1"
                fslmaths "${templPath}/"iCran_ton${ss} -mul 1 "${templPath}/"iCran_tonW
            else
                echo "2"
                fslmaths "${templPath}/"iCran_ton${ss} -add "${templPath}/"iCran_tonW "${templPath}/"iCran_tonW
            fi
        else
            echo "B"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"iCran_ton${ss} "${templPath}/"iCran_ton${ss}
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"iCran_tonW "${templPath}/"iCran_tonW
        fi
    done
    echo $sbj $sbjcount
done < "${StudyPath}/data/sbj.list"


# calculate the percentages
fslmaths "${templPath}/"iCran_tonr -mul 100 -div ${sbjcount} "${templPath}/"iCran_prob_r
fslmaths "${templPath}/"iCran_tonl -mul 100 -div ${sbjcount} "${templPath}/"iCran_prob_l
fslmaths "${templPath}/"iCran_tonW -mul 100 -div ${sbjcount} -div 2 "${templPath}/"iCran_prob

#remove temp files
rm "${templPath}/"iCran_ton*

echo "iCran probability mask created from" $sbjcount "subjects." 



# generate OC prob masks

NormdImage="_norm_iso06_OC"
sbjcount=0

while read sbj ;
do
    echo $sbj
    let sbjcount=${sbjcount}+1;
    for ss in r l ;
    do
        if [ "${sbjcount}" = "1" ] ;
        then
            echo "A"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin "${templPath}/"OC_ton${ss}
            if [ "${ss}" = "r" ] ;
            then
                echo "1"
                fslmaths "${templPath}/"OC_ton${ss} -mul 1 "${templPath}/"OC_tonW
            else
                echo "2"
                fslmaths "${templPath}/"OC_ton${ss} -add "${templPath}/"OC_tonW "${templPath}/"OC_tonW
            fi
        else
            echo "B"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"OC_ton${ss} "${templPath}/"OC_ton${ss}
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"OC_tonW "${templPath}/"OC_tonW
        fi
    done
    echo $sbj $sbjcount
done < "${StudyPath}/data/sbj.list"


# calculate the percentages
fslmaths "${templPath}/"OC_tonr -mul 100 -div ${sbjcount} "${templPath}/"OC_prob_r
fslmaths "${templPath}/"OC_tonl -mul 100 -div ${sbjcount} "${templPath}/"OC_prob_l
fslmaths "${templPath}/"OC_tonW -mul 100 -div ${sbjcount} -div 2 "${templPath}/"OC_prob

#remove temp files
rm "${templPath}/"OC_ton*

echo "OC probability mask created from" $sbjcount "subjects." 


# generate OT prob masks

NormdImage="_norm_iso06_OT"
sbjcount=0

while read sbj ;
do
    echo $sbj
    let sbjcount=${sbjcount}+1;
    for ss in r l ;
    do
        if [ "${sbjcount}" = "1" ] ;
        then
            echo "A"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin "${templPath}/"OT_ton${ss}
            if [ "${ss}" = "r" ] ;
            then
                echo "1"
                fslmaths "${templPath}/"OT_ton${ss} -mul 1 "${templPath}/"OT_tonW
            else
                echo "2"
                fslmaths "${templPath}/"OT_ton${ss} -add "${templPath}/"OT_tonW "${templPath}/"OT_tonW
            fi
        else
            echo "B"
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"OT_ton${ss} "${templPath}/"OT_ton${ss}
            fslmaths "${imPath}/${sbj}/${ss}${NormdImage}" -bin -add "${templPath}/"OT_tonW "${templPath}/"OT_tonW
        fi
    done
    echo $sbj $sbjcount
done < "${StudyPath}/data/sbj.list"


# calculate the percentages
fslmaths "${templPath}/"OT_tonr -mul 100 -div ${sbjcount} "${templPath}/"OT_prob_r
fslmaths "${templPath}/"OT_tonl -mul 100 -div ${sbjcount} "${templPath}/"OT_prob_l
fslmaths "${templPath}/"OT_tonW -mul 100 -div ${sbjcount} -div 2 "${templPath}/"OT_prob

#remove temp files
rm "${templPath}/"OT_ton*

echo "OT probability mask created from" $sbjcount "subjects." 





