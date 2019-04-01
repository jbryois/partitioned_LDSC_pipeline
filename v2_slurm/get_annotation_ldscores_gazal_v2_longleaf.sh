#!/usr/bin/sh

#Julien Bryois 4.10.2017

#Neccessary files
path_name="/nas/depts/007/sullilab/shared/partitioned_LDSC/"
all_snps="1000genomes_phase3_SNPs.bed2"
all_annotations="baselineLD_v1.1_annot"
plink_file="1000G_EUR_Phase3_plink"
hapmap_snps="hm_snp.txt"

#Add annotation, annotation +/- 500bp and get LDscores
#Running script for each bed file in the folder

for f in *.bed
do
echo $f
awk '{print $1"\t"$2-500"\t"$3+500"\t"$1":"$2"-"$3}' $f > $f"_500bp_ext"
awk '{ if ($2<0) print $1"\t"0"\t"$3"\t"$4; else print $0}' $f"_500bp_ext" > temp
mv temp $f"_500bp_ext"
intersectBed -c -a $path_name$all_snps -b $f > $f".1000genomes.intersect"
intersectBed -c -a $path_name$all_snps -b $f"_500bp_ext" > $f"_500bp_ext.1000genomes.intersect"
awk '{if($5!=0) print $4}' $f".1000genomes.intersect" > $f".1000genomes.intersect.snp"
awk '{if($5!=0) print $4}' $f"_500bp_ext.1000genomes.intersect" > $f"_500bp_ext.1000genomes.intersect.snp"
mkdir $f"_gazal_dir"
rm $f".1000genomes.intersect"
rm $f"_500bp_ext.1000genomes.intersect"
rm $f"_500bp_ext"
cd $f"_gazal_dir"
for j in $path_name$all_annotations/*.annot
do
echo $j
file_name=`basename $j`
perl $path_name/fast_match2_minimal.pl ../$f".1000genomes.intersect.snp" $f $j > a
perl $path_name/fast_match2.pl ../$f"_500bp_ext.1000genomes.intersect.snp" $f"_500bp_ext" a > $file_name
done
rm a
gzip *annot
rename "LD" "" *
for i in {1..22}
do
sbatch -t 1:00:00 -n 1 -o log_$i --wrap="ldsc.py --l2 --bfile $path_name$plink_file/1000G.EUR.QC.$i --ld-wind-cm 1 --print-snps $path_name$hapmap_snps --annot baseline.$i.annot.gz --out baseline.$i"
done
cd ..
rm $f".1000genomes.intersect.snp"
rm $f"_500bp_ext.1000genomes.intersect.snp"
done