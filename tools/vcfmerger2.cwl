cwlVersion: v1.2
class: CommandLineTool
id: vcfmerger2
doc: "VCFmerger2"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/vcfmerger2:0.9.3_tgen'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)

baseCommand: [vcfMerger2.py]

inputs:
  vcfs: { type: 'File[]', inputBinding: { position: 2, prefix: "--vcfs", itemSeparator: "|" }, doc: "List of vcfs file" }
  toolnames: { type: 'string[]', inputBinding: { position: 2, prefix: "--toolnames", itemSeparator: "|" }, doc: "List of vcfs file delimited by DELIM character; default DELIM is pipe unless --delim option is used using --delim option" }
  refgenome: { type: 'File', inputBinding: { position: 2, prefix: "--refgenome"}, secondaryFiles: [{ pattern: '.fai', required: true }], doc: "reference genome fasta and associated fai index used with bcftools norm ; must match reference used for alignment" }
  dict: { type: 'File', inputBinding: { position: 2, prefix: "--dict"}, doc: "dictionary file of reference genome; required to get correct order of contig names; this should be a .dict file created by picard or samtools sequence dictionary module" }
  merged_vcf_outfilename: { type: 'File', inputBinding: { position: 2, prefix: "--merged-vcf-outfilename"}, doc: "outfilename for the merge vcf" }

  # Optional Arguments
  bams: { type: 'File[]?', inputBinding: { position: 2, prefix: "--bams", itemSeparator: "|" }, doc: "List of TUMOR/CASES bams used to call variants; Note1: if Strelka2 tool is given, the TUMOR BAM file is MANDATORY; Note2: If you do not have the bam put empty value in given piped ordered list; Note3: this option will be improved LATER to avoid confusion and misunderstanding of the BAM usage in vcfMerger2" }
  germline: { type: 'boolean?', inputBinding: { position: 2, prefix: "--germline"}, doc: "option required if dealing with GERMLINE VCFs, otherwise data will be considered as Somatic calls" }
  germline_snames: { type: 'string?', inputBinding: { position: 2, prefix: "--germline-snames"}, doc: "expected name of germline sample(s) in vcf file if option --germline is in use; currently dealing with only one sample per vcf is implemented ; more samples will lead to error;" }
  normal_sname: { type: 'string?', inputBinding: { position: 2, prefix: "--normal-sname"}, doc: "expected name of normal sample in vcf file" }
  tumor_sname: { type: 'string?', inputBinding: { position: 2, prefix: "--tumor-sname"}, doc: "expected name of tumor sample in vcf file" }
  prep_outfilenames: { type: 'string[]?', inputBinding: { position: 2, prefix: "--prep-outfilenames", itemSeparator: "|" }, doc: "names to the tool-specific prepared vcf files" }
  precedence: { type: 'string[]?', inputBinding: { position: 2, prefix: "--precedence", itemSeparator: "|" }, doc: "sorted delim-separated list of the toolnames as listed in --toolnames ; This list stipulates an order of precedence for the tools different from the default order given by the --toolnames list" }
  contigs_file_for_vcf_header: { type: 'File?', inputBinding: { position: 2, prefix: "--contigs-file-for-vcf-header"}, doc: "List of contigs necessary for capturing adding them to tool vcf header if needed; otherwise put empty_string as value for each tool; do not provide if bam file is given instead" }
  acronyms: { type: 'string[]?', inputBinding: { position: 2, prefix: "--acronyms", itemSeparator: "|" }, doc: "List of Acronyms for toolnames to be used as PREFIXES in INFO field ; same DELIM as --vcfs" }
  threshold_ar: { type: 'float?', inputBinding: { position: 2, prefix: "--threshold-AR"}, doc: "AlleRatio threshold value to assign genotype; 0/1 if less than threshold, 1/1 if equal or above threshold; default is 0.90 ; range ]0,1]" }
  lossy: { type: 'boolean?', inputBinding: { position: 2, prefix: "--lossy"}, doc: "This will create a lossy merged vcf by only keeping the information from the tool with first hand precedence" }
  skip_prep_vcfs: { type: 'boolean?', inputBinding: { position: 2, prefix: "--skip-prep-vcfs"}, doc: "skip the step for preparing vcfs up to specs and only run the merge step; implies all prep-vcfs are ready already ; same options and inputs required as if prep step was run" }
  filter_by_pass: { type: 'boolean?', inputBinding: { position: 2, prefix: "--filter-by-pass"}, doc: "enable vcf filtering of PASS variant using snpSift tool; String to snpSift hardcoded as (FILTER == 'PASS')" }
  filter: { type: 'string?', inputBinding: { position: 2, prefix: "--filter"}, doc: "enable vcf filtering using snpSift tool; A string argument is passed to this filter option; This string MUST be formatted as if you were using it for snpSift, i.e. we used 'as_is' the string provided; Therefore a valid format is mandatory; Check snpSift manual ; IMPORTANT NOTE: the filtering MUST use FLAG and TAGs that are COMMON to ALL the tools involved ; The Prepped vcfs have some common flags in the GENOTYPE fields (so far GT, DP, AR, AD), and the CC flag is common to ALL records. The filtering takes place after the prep_vcf step and before merging the vcfs; Example of String: '( GEN[TUMOR].AR >= 0.10 ) & ( GEN[NORMAL].AR <= 0.02 ) & ( CC >= 2 ) & ( GEN[TUMOR].DP >= 10 & GEN[NORMAL].DP>=10)', where NORMAL or TUMOR can be replaced with appropriate indices or other given names" }
  path_jar_snpsift: { type: 'string?', inputBinding: { position: 2, prefix: "--path-jar-snpsift"}, doc: "Provide full Path of the snpSift.jar you want to use for filtering the vcf before merging them" }
  skip_merge: { type: 'boolean?', inputBinding: { position: 2, prefix: "--skip-merge"}, doc: "enabling this flag prevents doing the merging step [useful if only the prep step needs to be done ]" }
  beds: { type: 'File[]?', inputBinding: { position: 2, prefix: "--beds", itemSeparator: "|" }, doc: "list of bed files to be used to make Venns or Upset plots; requires to enable --do-venn as well to validate making Venn/upset plots ; list MUST be delimited by DELIM character (--delim or default delim)" }
  do_venn: { type: 'boolean?', inputBinding: { position: 2, prefix: "--do-venn"}, doc: "using the bed files listed in --beds option, Venns or Upset plot will be created ; need to match the number of tools listed in --toolnames" }
  venn_title: { type: 'string?', inputBinding: { position: 2, prefix: "--venn-title"}, doc: "Default is empty string" }

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."

outputs:
  vcf:
    type: File
    outputBinding:
      glob: |
        $(inputs.merged_vcf_outfilename)
  vcfgz:
    type: File?
    secondaryFiles: [{ pattern: '.tbi', required: true }]
    outputBinding:
      glob: |
        $(inputs.merged_vcf_outfilename).gz
  venns:
    type: Directory[]?
    outputBinding:
      glob: "SummaryPlots_*"
