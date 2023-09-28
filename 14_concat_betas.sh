#!/bin/bash

#SBATCH --mem=4000 
#--output=logs/katzer3_14_concat_betas/%j.out

## Needs subject number and the order of the runs (1 = no labels first, 2 = labels first) 
sbj=$1
order=$2
dur="1 4"
tdinfo="isTD noTD"

if [ $order -eq 1 ]
	then 
	runs="perceptionNolabels_run-1 perceptionNolabels_run-2 perceptionLabels_run-1 perceptionLabels_run-2 recall_run-1 recall_run-2"

elif [ $order -eq 2 ]
	then
	runs="perceptionLabels_run-1 perceptionLabels_run-2 perceptionNolabels_run-1 perceptionNolabels_run-2 recall_run-1 recall_run-2"
fi


## Single trial betas 

for d in ${dur}
	do
	
	for td in ${tdinfo}
		do
		outputdir=~/Data/katzer3/sub-${sbj}/func/singletrial_${td}
		mkdir -p ${outputdir}

		for k in ${runs}
			do
			betadir=~/Data/katzer3/sub-${sbj}/func/singletrial_${td}/${k}_dur${d}.feat/stats
			cd ${betadir}
			mycode='fslmerge -t '${outputdir}'/betas_'${k}_dur${d}
			s=' pe'
			e='.nii.gz '
		
			if [ ${td} = "isTD" ]
			then
				for (( i=0; i<96; i+=2 ))
				do
					a=$(expr $i + 1)
					mycode=${mycode}$s$a$e
				done

				eval ${mycode}
			fi

			if [ ${td} = "noTD" ]
			then
				for (( i=0; i<48; i++ ))
				do
					a=$(expr $i + 1)
					mycode=${mycode}$s$a$e
				done

				eval ${mycode}
			fi
		done

		fslmerge -t ${outputdir}/betas_all_dur${d} ${outputdir}'/betas_perceptionLabels_run-1'_dur${d} \
		${outputdir}'/betas_perceptionLabels_run-2'_dur${d} ${outputdir}'/betas_perceptionNolabels_run-1'_dur${d} \
		${outputdir}'/betas_perceptionNolabels_run-2'_dur${d} ${outputdir}'/betas_recall_run-1'_dur${d} \
		${outputdir}'/betas_recall_run-2'_dur${d}
	done
done



## Single item betas

for d in ${dur}
	do
	
	for td in ${tdinfo}
		do
		outputdir=~/Data/katzer3/sub-${sbj}/func/singleitem_${td}
		mkdir -p ${outputdir}

		for k in ${runs}
			do
			betadir=~/Data/katzer3/sub-${sbj}/func/singleitem_${td}/${k}_dur${d}.feat/stats
			cd ${betadir}
			mycode='fslmerge -t '${outputdir}'/betas_'${k}_dur${d}
			s=' pe'
			e='.nii.gz '
		
			if [ ${td} = "isTD" ]
			then
				for (( i=0; i<32; i+=2 ))
				do
					a=$(expr $i + 1)
					mycode=${mycode}$s$a$e
				done

				eval ${mycode}
			fi

			if [ ${td} = "noTD" ]
			then
				for (( i=0; i<16; i++ ))
				do
					a=$(expr $i + 1)
					mycode=${mycode}$s$a$e
				done

				eval ${mycode}
			fi
		done

		fslmerge -t ${outputdir}/betas_all_dur${d} ${outputdir}'/betas_perceptionLabels_run-1'_dur${d} \
		${outputdir}'/betas_perceptionLabels_run-2'_dur${d} ${outputdir}'/betas_perceptionNolabels_run-1'_dur${d} \
		${outputdir}'/betas_perceptionNolabels_run-2'_dur${d} ${outputdir}'/betas_recall_run-1'_dur${d} \
		${outputdir}'/betas_recall_run-2'_dur${d}
	done
done
