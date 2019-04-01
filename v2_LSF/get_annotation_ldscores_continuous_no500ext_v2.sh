#!/usr/bin/sh
#bsub -Ip /bin/bash

#Julien Bryois 21.11.2017

#Neccessary files
path_name="/nas/depts/007/sullilab/shared/partitioned_LDSC/"
all_snps="1000genomes_phase3_SNPs.bed2"
all_annotations="1000G_EUR_Phase3_baseline_annot"
plink_file="1000G_EUR_Phase3_plink"
hapmap_snps="hm_snp.txt"

#Add annotation, annotation +/- 500bp and get LDscores
#Running script for each bed file in the folder

for f in *.bed
do
echo $f
intersectBed -wb -a $path_name$all_snps -b $f > $f".1000genomes.intersect"
awk '{print $4"\t"$9}' $f".1000genomes.intersect" > $f".1000genomes.intersect.snp"
mkdir $f"_continuous_no500ext_Finucane_dir"
rm $f".1000genomes.intersect"
cd $f"_continuous_no500ext_Finucane_dir"
for j in $path_name$all_annotations/*.annot
do
echo $j
file_name=`basename $j`
perl $path_name/fast_match2_minimal_continuous.pl ../$f".1000genomes.intersect.snp" $f $j > $file_name
done
gzip *annot
for i in {1..22}
do
bsub -o log_$i -M 6 "ldsc.py --l2 --bfile $path_name$plink_file/1000G.EUR.QC.$i --ld-wind-cm 1 --print-snps $path_name$hapmap_snps --annot baseline.$i.annot.gz --out baseline.$i"
done
cd ..
rm $f".1000genomes.intersect.snp"
done