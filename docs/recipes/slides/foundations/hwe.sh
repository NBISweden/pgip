wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel

# Make population-specific sample files
panel=integrated_call_samples_v3.20130502.ALL.panel
awk '{if ($2 == "CEU") print $1}' $panel > CEU.samples.txt
awk '{if ($2 == "CHB") print $1}' $panel > CHB.samples.txt
awk '{if ($2 == "YRI") print $1}' $panel > YRI.samples.txt

# Subset vcf to these files
VCF=ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
REGION=22:17000000-20000000
for pop in CEU CHB YRI; do
    echo $pop
    bcftools view -v snps -m 2 -M 2 -S $pop.samples.txt $VCF $REGION | bgzip -c > $pop.$REGION.vcf.gz
    tabix -f $pop.$REGION.vcf.gz
    plink --vcf $pop.$REGION.vcf.gz --hardy --out $pop.$REGION
    gzip -v $pop.${REGION}.hwe
done
