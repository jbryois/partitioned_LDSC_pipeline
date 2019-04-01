#!/usr/bin/sh

#Julien Bryois 7.11.2017

#Neccessary files
path_name="/nas/depts/007/sullilab/shared/partitioned_LDSC/"
all_snps="1000genomes_phase3_SNPs.bed2"
all_annotations="1000G_EUR_Phase3_baseline"
plink_file="1000G_EUR_Phase3_plink"
hapmap_snps="hm_snp.txt"

#Add the annotation to the baseline model -> To compare same annotation accross different tissues.
#Running script for each bed file in the folder

for f in *.bed
do
echo $f
intersectBed -c -a $path_name$all_snps -b $f > $f".1000genomes.intersect"
awk '{if($5!=0) print $4}' $f".1000genomes.intersect" > $f".1000genomes.intersect.snp"
mkdir $f"_tissue_dir"
rm $f".1000genomes.intersect"
cp $path_name$all_annotations/*annot.gz $f"_tissue_dir"
cd $f"_tissue_dir"
gunzip *
for j in *.annot
do
echo $j
perl $path_name/fast_match2.pl ../$f".1000genomes.intersect.snp" $f $j > $j".txt"
done
gzip *annot.txt
rm *.annot
rm a
rename ".txt" "" *
for i in {1..22}
do
bsub -o log_$i "ldsc.py --l2 --bfile $path_name$plink_file/1000G.EUR.QC.$i --ld-wind-cm 1 --print-snps $path_name$hapmap_snps --annot baseline.$i.annot.gz --out baseline.$i"
done
cd ..
rm $f".1000genomes.intersect.snp"
done