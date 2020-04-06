# canine-dev
Canine WF development

![data service logo](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9BnbvIsTkK3QlSGMDvlgu0tZQJ1q4crMvA-S3fcWfIq6y2d2Y)

This is the Kids First Data Resource Center (DRC) Whole Genome Sequencing (WGS) Somatic Workflow for canine data, which includes somatic variant calling. 
This workflow takes aligned bam input and performs somatic variant calling using Strelka2, and Mutect2.


### Somatic Variant Calling:

[Strelka2](https://github.com/Illumina/strelka) v2.9.3 calls single nucleotide variants (SNV) and insertions/deletions (INDEL).
[Mutect2](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.1.0/org_broadinstitute_hellbender_tools_walkers_mutect_Mutect2.php) v4.1.10 from the Broad institute calls SNV, multi-nucleotide variants (MNV, basically equal length substitutions with length > 1) and INDEL.
The pre-`PASS` filtered results can still be obtained from the workflow in the event the user wishes to keep some calls that failed `PASS` criteria.

### Variant Annotation

[SnpEff](http://snpeff.sourceforge.net/) with genome version `CanFam3.1.86` was used for VCF annotation of SNV and INDEL calls. Use `java -jar snpEff.jar download  http://downloads.sourceforge.net/project/snpeff/databases/v4_3/snpEff_v4_3_CanFam3.1.86.zip`  to download annotation database

### Tips To Run:

1) For input bam files, be sure to have indexed them beforehand as well.

2) What is `select_vars_mode` you ask? On occasion, using GATK's `SelectVariants` tool will fail, so a simple `grep` mode on `PASS` can be used instead.
Related, `bcftools_filter_vcf` is built in as a convenience in case your b allele frequency file has not been filtered on `PASS`.
You can use the `include_expression` `Filter="PASS"` to achieve this.

3) Suggested reference inputs are:

    - **`reference_fasta`: [Canis_familiaris.CanFam3.1.dna.toplevel.fa](ftp://ftp.ensembl.org/pub/release-86/fasta/canis_familiaris/dna/Canis_familiaris.CanFam3.1.dna.toplevel.fa.gz)** - Use `gunzip Canis_familiaris.CanFam3.1.dna.toplevel.fa.gz` to unzip file
    - **`reference_dict`: `Canis_familiaris.CanFam3.1.dna.toplevel.dict`** - this was created using `gatk CreateSequenceDictionary` and reference fasta file as input  to generate dict file
    - **`wgs_calling_interval_list`: `Canis_familiaris.CanFam3.1.dna.chromosome.interval_list`** - this was created using `picard  BedToIntervalList` and BED file (full canonical chromosomes) and reference fasta file as input
    - **`af_only_gnomad_vcf`: [92indsAEDPCDTaimyr.biallelic.up.sort.vcf.gz](https://bigd.big.ac.cn/dogsdv2/pages/modules/download/vcf.jsp)** - Used for VCF annotations
    - **`strelka2_bed`: `Canis_WGS_withoutcontigs_withoutchrY.bed.gz`** - BED file with full canonical chromosomes. Should be gzipped and tabix indexed
     - **`threads`**: 16

4) Output files (Note, all vcf files that don't have an explicit index output have index files output as as secondary file.  In other words, they will be captured at the end of the workflow):

    - Simple variant callers
        - Strelka2:
            - `strelka2_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for strelka2. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter.
            - `strelka2_pass_vcf`: All somatic and indel calls from strelk2 filtered with `PASS`
        - Mutect2:
            - `mutect2_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for mutect2. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter.
            - `mutect2_pass_vcf`: All somatic and indel calls from mutect2 filtered with `PASS`
        - Lancet:
            - `lancet_prepass_vcf`: Somatic  SNV and indel call results with  all the `FILTER` categories from lancet tool. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter.
            - `lancet_pass_vcf`: All somatic and indel calls from lancet filtered with `PASS`
        - Vardict:
            - `vardict_prepass_vcf`:  Somatic snv and indel call results with all `FILTER` categories for vardict. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter.   
            - `vardict_pass_vcf`: All somatic and indel calls from vardict filtered with `PASS`



5) Docker images - the workflow tools will automatically pull them, but as a convenience are listed below:
    - `Strelka2`: obenauflab/strelka
    - `Mutect2` and all `GATK` tools: kfdrc/gatk:4.1.1.0
    - `Lancet`: kfdrc/lancet:1.0.7
    - `VarDict Java`: kfdrc/vardict:1.7.0 
    - `samtools`: kfdrc/samtools:1.9
    - `bcftools` and `vcftools`: kfdrc/bvcftools:latest 

