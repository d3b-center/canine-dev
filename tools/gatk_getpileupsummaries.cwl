cwlVersion: v1.2
class: CommandLineTool
id: gatk_getpileupsummaries
doc: "Tabulates pileup metrics for inferring contamination" 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.1.8.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk
  - position: 1
    shellQuote: false
    prefix: "--java-options"
    valueFrom: >-
      $("\"-Xmx"+Math.floor(inputs.max_memory*1000/1.074 - 1)+"M\"")
  - position: 2
    shellQuote: false
    valueFrom: >-
      GetPileupSummaries
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_interval_list ? inputs.input_interval_list.nameroot : 'output'; var ext = 'pileups.table'; return pre+'.'+ext}
inputs:
  input_reads:
    type: 'File'
    secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }]
    doc: "BAM/SAM/CRAM file containing reads"
    inputBinding:
      position: 3
      prefix: "--input"
  input_variants:
    type: 'File'
    secondaryFiles: [{ pattern: ".tbi", required: false }]
    inputBinding:
      position: 3
      prefix: "--variant"
    doc: "A VCF file containing variants and allele frequencies"
  input_interval_list:
    type: 'File?'
    secondaryFiles: [{ pattern: ".tbi", required: false }]
    doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs."
    inputBinding:
      position: 3
      prefix: "--intervals"
  input_intervals:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--intervals"
    inputBinding:
      position: 3
    doc: "One or more genomic intervals over which to operate. Use this input when providing intervals as strings."
  indexed_reference:
    type: 'File?'
    doc: "Reference fasta"
    secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }]
    inputBinding:
      position: 3
      prefix: "--reference"
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    doc: |
      By default, the program merges abutting intervals (i.e. intervals that are
      directly side-by-side but do not actually overlap) into a single continuous
      interval. However you can change this behavior if you want them to be treated
      as separate intervals instead.
    inputBinding:
      position: 3
      prefix: "--interval-merging-rule"
  interval_set_rule:
    type:
      - 'null'
      - type: enum
        name: interval_set_rule
        symbols: ["UNION","INTERSECTION"]
    doc: |
      By default, the program will take the UNION of all intervals specified using -L
      and/or -XL. However, you can change this setting for -L, for example if you
      want to take the INTERSECTION of the sets instead. E.g. to perform the analysis
      only on chromosome 1 exomes, you could specify -L exomes.intervals -L 1
      --interval-set-rule INTERSECTION. However, it is not possible to modify the
      merging approach for intervals passed using -XL (they will always be merged
      using UNION). Note that if you specify both -L and -XL, the -XL interval set
      will be subtracted from the -L interval set.
    inputBinding:
      position: 3
      prefix: "--interval-set-rule"
  max_depth_per_sample: { type: 'int?', inputBinding: { position: 3, prefix: "--max-depth-per-sample"}, doc: "Maximum number of reads to retain per sample per locus. Reads above this threshold will be downsampled. Set to 0 to disable." }
  maximum_population_allele_frequency: { type: 'float?', inputBinding: { position: 3, prefix: "--maximum-population-allele-frequency"}, doc: "Maximum population allele frequency of sites to consider." }
  min_mapping_quality: { type: 'int?', inputBinding: { position: 3, prefix: "--min-mapping-quality"}, doc: "Minimum read mapping quality" }
  minimum_population_allele_frequency: { type: 'float?', inputBinding: { position: 3, prefix: "--minimum-population-allele-frequency"}, doc: "Minimum population allele frequency of sites to consider. A low value increases accuracy at the expense of speed." }
  sites_only_vcf_output: { type: 'boolean?', inputBinding: { position: 3, prefix: "--sites-only-vcf-output"}, doc: "If true, don't emit genotype fields when writing vcf file output." }
  extra_args:
    type: 'string?'
    doc: "Any valid, extra arguments for this tool."
    inputBinding:
      position: 4
      shellQuote: false
  output_prefix:
    type: 'string?'
    doc: "String to use as the prefix for the outputs."
  max_memory:
    type: 'int?'
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    doc: "Number of CPUs to allocate to this task."
outputs:
  output: { type: 'File', outputBinding: { glob: "*.pileup.table" } }
