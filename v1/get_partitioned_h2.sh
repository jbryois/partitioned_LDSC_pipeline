#!/usr/bin/sh

#Julien Bryois 5.10.2017

sumstats=$1

path_name="/nas/depts/007/sullilab/shared/partitioned_LDSC/"

weights="1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC."
frq="1000G_Phase3_frq/1000G.EUR.QC."

for f in *_dir 
do
echo $f
gwas_name=`basename $sumstats | cut -d "." -f 1`
echo $gwas_name
cd $f
bsub -o log_$gwas_name "ldsc.py --h2 $sumstats --ref-ld-chr baseline. --w-ld-chr $path_name$weights --overlap-annot --frqfile-chr $path_name$frq --print-coefficients --out ../${gwas_name}_${f}"
cd ..
done