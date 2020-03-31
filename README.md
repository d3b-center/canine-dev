# canine-dev
Canine WF development

![data service logo](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9BnbvIsTkK3QlSGMDvlgu0tZQJ1q4crMvA-S3fcWfIq6y2d2Y)

This is the Kids First Data Resource Center (DRC) Whole Genome Sequencing (WGS) Somatic Workflow for canine data, which includes somatic variant calling. 
This workflow takes aligned bam input and performs somatic variant calling using Strelka2, and Mutect2.
Somatic variant call results are annotated using Variant Effect Predictor, with the Memorial Sloane Kettering Cancer Center (MSKCC) vcf2maf wrapper.

### Somatic Variant Calling:

[Strelka2](https://github.com/Illumina/strelka) v2.9.3 calls single nucleotide variants (SNV) and insertions/deletions (INDEL).
[Mutect2](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.1.0/org_broadinstitute_hellbender_tools_walkers_mutect_Mutect2.php) v4.1.10 from the Broad institute calls SNV, multi-nucleotide variants (MNV, basically equal length substitutions with length > 1) and INDEL.
The pre-`PASS` filtered results can still be obtained from the workflow in the event the user wishes to keep some calls that failed `PASS` criteria.

### Variant Annotation

[Variant Effect Predictor](https://useast.ensembl.org/info/docs/tools/vep/index.html) release 86?, wrapped by [vcf2maf](https://github.com/mskcc/vcf2maf) v1.6.17 is used to annotate somatic variant and SV calls.
Both the annotated vcf and maf file are made available.

### Tips To Run:

1) For input bam files, be sure to have indexed them beforehand as well.

2) What is `select_vars_mode` you ask? On occasion, using GATK's `SelectVariants` tool will fail, so a simple `grep` mode on `PASS` can be used instead.
Related, `bcftools_filter_vcf` is built in as a convenience in case your b allele frequency file has not been filtered on `PASS`.
You can use the `include_expression` `Filter="PASS"` to achieve this.

3) Suggested reference inputs are:

    - `reference_fasta`: [Canis_familiaris.CanFam3.1.dna.toplevel.fa](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0?pli=1) - need to have access to D3B  s3 bucket
    - `reference_dict`: [Canis_familiaris.CanFam3.1.dna.toplevel.dic](https://s3.console.aws.amazon.com/s3/object/bix-dev-data-bucket/references/canine-references/Canis_familiaris.CanFam3.1.dna.toplevel.dict?region=us-east-1&tab=overview) - need to have  access to D3B  s3 bucket
    - `wgs_calling_interval_list`: [Canis_familiaris.CanFam3.1.dna.chromosome.interval_list
](https://cavatica.sbgenomics.com/u/d3b-bixu/dev-canine-workflow/files/5e797425e4b09d9acf762d32/) - this was created using `picard  BedToIntervalList` from BED file and reference fasta file
    - `92indsAEDPCDTaimyr.biallelic.up.sort.vcf.gz`: [92indsAEDPCDTaimyr.biallelic.up.sort.vcf.gz](https://console.cloud.google.com/storage/browser/-gatk-best-practices/somatic-hg38) - need a valid google account, this is a link to the best practices google bucket from Broad GATK.
    - `exac_common_vcf`: [small_exac_common_3.hg38.vcf.gz](https://console.cloud.google.com/storage/browser/gatk-best-practices/somatic-hg38) - need a valid google account, this is a link to the best practices google bucket from Broad GATK.
    - `strelka2_bed`: [hg38_strelka.bed.gz'](https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md#extended-use-cases) - this link here has the bed-formatted text needed to copy to create this file. You will need to bgzip this file.
     - `vep_cache`: `homo_sapiens_vep_93_GRCh38.tar.gz` from ftp://ftp.ensembl.org/pub/release-93/variation/indexed_vep_cache/ - variant effect predictor cache.
     Current production workflow uses this version, and is compatible with the release used in the vcf2maf tool.
     - `threads`: 16

4) Output files (Note, all vcf files that don't have an explicit index output have index files output as as secondary file.  In other words, they will be captured at the end of the workflow):

    - Simple variant callers
        - Strelka2:
            - `strelka2_vep_vcf`: Variant effect predictor annotated vcf, filtered on `PASS`, somatic snv and indel call results from strelka2
            - `strelka2_vep_tbi`: Index file of above bgzipped vcf
            - `strelka2_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for strelka2. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter.
            - `strelka2_vep_maf`: Mutation annotation file (maf) format of `strelka2_vep_vcf`
        - Mutect2:
            - `mutect2_vep_vcf`: Variant effect predictor annotated vcf, filtered on `PASS`, somatic snv and indel call results from mutect2
            - `mutect2_vep_tbi`: Index file of above bgzipped vcf
            - `mutect2_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for mutect2. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter.
            - `mutect2_vep_maf`: maf of format of `mutect2_vep_vcf`


5) Docker images - the workflow tools will automatically pull them, but as a convenience are listed below:
    - `Strelka2`: obenauflab/strelka
    - `Mutect2` and all `GATK` tools: kfdrc/gatk:4.1.1.0
    - `samtools`: kfdrc/samtools:1.9
    - `bcftools` and `vcftools`: kfdrc/bvcftools:latest 

