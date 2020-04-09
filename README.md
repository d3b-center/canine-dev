# Canine Somatic WF (beta)

<p align="center">
  <img alt="Logo for The Center for Data Driven Discovery" src="https://raw.githubusercontent.com/d3b-center/handbook/master/website/static/img/chop_logo.svg?sanitize=true" width="400px" />
</p>

This is the Kids First Data Resource Center (DRC) Whole Genome Sequencing (WGS) Somatic Workflow, which includes somatic variant calling. 
This workflow takes aligned bam input and performs somatic variant calling using Strelka2, Mutect2, Lancet, and VarDict Java, CNV estimation using CNVkit, and SV calls using Manta. Somatic variant call results are annotated using SnpEff. The `workflows/kfdrc_production_WGS_somatic_variant_cnv.cwl` would run all tools described below for WGS.


### Somatic Variant Calling:

[Strelka2](https://github.com/Illumina/strelka) v2.9.3 calls single nucleotide variants (SNV) and insertions/deletions (INDEL).
[Mutect2](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.1.0/org_broadinstitute_hellbender_tools_walkers_mutect_Mutect2.php) v4.1.1.0 from the Broad institute calls SNV, multi-nucleotide variants (MNV, basically equal length substitutions with length > 1) and INDEL.
[Lancet](https://github.com/nygenome/lancet) v1.0.7 from the New York Genome Center (NYGC) calls SNV, MNV, and INDEL.
[VarDict Java](https://github.com/AstraZeneca-NGS/VarDictJava) v1.7.0 from AstraZeneca calls SNV, MNV, INDEL and more.
Each caller has a different approach to variant calling, and together one can glean confident results. Strelka2 is run with default settings, similarly Mutect2 following Broad Best Practices, as of this [workflow](https://github.com/broadinstitute/gatk/blob/4.1.1.0/scripts/mutect2_wdl/mutect2.wdl). Lancet is run in what I'd call an "Exome+" mode, based on the NYGC methods described [here](https://www.biorxiv.org/content/biorxiv/early/2019/04/30/623702.full.pdf). In short, regions from GENCODE gtf with feature annotations `exon` and `UTR` are used as intervals, as well as regions flanking hits from `strelka2` and `mutect2`. Lastly, VarDict Java run params follow the protocol that the [Blue Collar Bioinformatics](https://bcbio-nextgen.readthedocs.io/en/latest/index.html) uses, with the exception of using a min variant allele frequency (VAF) of 0.05 instead of 0.1, which we find to be relevant for rare cancer variant discovery. We also employ their false positive filtering methods.
Furthermore, each tool's results, in variant call format (vcf), are filtered on the `PASS` flag, with VarDict Java results additionally filtered for the flag `StrongSomatic`. Their results also include germline hits and other categories by default.
The pre-`PASS` filtered results can still be obtained from the workflow in the event the user wishes to keep some calls that failed `PASS` criteria.

### CNV estimation:

[cnvkit](https://cnvkit.readthedocs.io/en/stable/) v2.9.3 is currently being used to predict copy number alterations. The result files include calls.cns, calls.cnr, gain_loss, seg and metrics files

### SV calling:

[Manta](https://github.com/Illumina/manta) v1.4.0 is used to call SVs. Output is also in vcf format, with calls filtered on PASS. Default settings are used at run time.

### Variant Annotation:

[SnpEff](http://snpeff.sourceforge.net/) with genome version `CanFam3.1.86` was used for VCF annotation of SNV and INDEL calls. Use `java -jar snpEff.jar download  http://downloads.sourceforge.net/project/snpeff/databases/v4_3/snpEff_v4_3_CanFam3.1.86.zip`  to download annotation database

### Tips To Run:

1) For input bam files, be sure to have indexed them beforehand as well. For a bam file with name `file.bam`, the corresponding bai file should be  named `file.bai`


2) As a cavatica app, certain features  like number of  threads and `PASS` filter mode are populated by default

3) What is `select_vars_mode` you ask? On occasion, using GATK's `SelectVariants` tool will fail, so a simple `grep` mode on `PASS` can be used instead.
Related, `bcftools_filter_vcf` is built in as a convenience in case your b allele frequency file has not been filtered on `PASS`.
You can use the `include_expression` `Filter="PASS"` to achieve this.

4) Suggested reference inputs are:

    - `reference_fasta`: [Canis_familiaris.CanFam3.1.dna.toplevel.fa](ftp://ftp.ensembl.org/pub/release-86/fasta/canis_familiaris/dna/Canis_familiaris.CanFam3.1.dna.toplevel.fa.gz) - Use `gunzip Canis_familiaris.CanFam3.1.dna.toplevel.fa.gz` to unzip file
    - `reference_dict`: `Canis_familiaris.CanFam3.1.dna.toplevel.dict` - this was created using `gatk CreateSequenceDictionary` and reference fasta file as input  to generate dict file
    - `wgs_calling_interval_list`: `Canis_familiaris.CanFam3.1.dna.chromosome.interval_list` - this was created using `picard  BedToIntervalList` and BED file (full canonical chromosomes) and reference fasta file as input
    - `af_only_gnomad_vcf`: [92indsAEDPCDTaimyr.biallelic.up.sort.vcf.gz](https://bigd.big.ac.cn/dogsdv2/pages/modules/download/vcf.jsp) - Used for VCF annotations
    - `strelka2_bed`: `Canis_WGS_withoutcontigs_withoutchrY.bed.gz` - BED file with full canonical chromosomes. Should be gzipped and tabix indexed
     - `threads`: 16

5) Output files (Note, all vcf files that don't have an explicit index output have index files output as as secondary file.  In other words, they will be captured at the end of the workflow):

    - Simple variant callers
        - Strelka2:
            - `strelka2_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for strelka2. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter
            - `strelka2_pass_vcf`: Somatic SNV and indel call results  that are  filtered for `PASS`
            - `strelka2_snpeff_vcf`: PASS somatic SNV and indel calls that are annotated with SnpEff
        - Mutect2:
            - `mutect2_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for mutect2. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter
            - `mutect2_pass_vcf`: Somatic SNV and indel call results  that are  filtered for `PASS`
            - `mutect2_snpeff_vcf`: PASS somatic SNV and indel calls that are annotated with SnpEff
        - VardictJava
            - `vardict_prepass_vcf`: All call results with all `FILTER` categories for VardictJava. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter and our `StrongSomatic` subset.
            - `vardict_pass_vcf`: Somatic SNV and indel call results  that are  filtered for `PASS`
            - `vardict_snpeff_vcf`: PASS somatic SNV and indel calls that are annotated with SnpEff
        - Lancet
          - `lancet_prepass_vcf`: Somatic snv and indel call results with all `FILTER` categories for lancet. Use this file if you believe important variants are being left out when using the algorithm's `PASS` filter
          - `lancet_pass_vcf`: Somatic SNV and indel call results  that are  filtered for `PASS`
          - `lancet_snpeff_vcf`: PASS somatic SNV and indel calls that are annotated with SnpEff

    - Structural variant callers
        - Manta:
            - `manta_prepass_vcf`: SV results with all FILTER categories for manta. Use this file if you believe important variants are being left out when using the algorithm's PASS filter
            - `manta_pass_vcf`: SV results filtered for `PASS`

    - Copy number variation callers
        - CNVkit
          - `cnvkit_cnr`: Copy number ratio
          - `cnvkit_cnn_output`: Normal/control sample copy number
          - `cnvkit_calls`: Tumor/sample copy number
          - `cnvkit_metrics`: Basic seg count and call stats
          - `cnvkit_gainloss`: Per-gene log2 ratio
          - `cnvkit_seg`: Classic microarray-style seg file  


6) Docker images - the workflow tools will automatically pull them, but as a convenience are listed below:
    - `Strelka2`: obenauflab/strelka
    - `Mutect2` and all `GATK` tools: kfdrc/gatk:4.1.1.0
    - `Lancet`: kfdrc/lancet:1.0.7
    - `VarDict Java`: kfdrc/vardict:1.7.0
    - `CNVkit`: images.sbgenomics.com/milos_nikolic/cnvkit:0.9.3
    - `samtools`: kfdrc/samtools:1.9
    - `bcftools` and `vcftools`: kfdrc/bvcftools:latest 
    - `SnpEff`: kfdrc/snpeff:4_3t

