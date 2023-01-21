cwlVersion: v1.2
class: CommandLineTool
id: lancet 
doc: |
  Lancet is a somatic variant caller (SNVs and indels) for short read data.
  Lancet uses a localized micro-assembly strategy to detect somatic mutation with
  high sensitivity and accuracy on a tumor/normal pair. Lancet is based on the
  colored de Bruijn graph assembly paradigm where tumor and normal reads are
  jointly analyzed within the same graph. On-the-fly repeat composition analysis
  and self-tuning k-mer strategy are used together to increase specificity in
  regions characterized by low complexity sequences. Lancet requires the raw
  reads to be aligned with BWA
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/lancet:1.1.0'
baseCommand: [lancet]
inputs:
  # Required Arguments
  tumor: { type: 'File', secondaryFiles: [{ pattern: '.bai', required: false}, { pattern: '^.bai', required: false}], inputBinding: { position: 2, prefix: "--tumor"}, doc: "BAM file of mapped reads for tumor" }
  normal: { type: 'File', secondaryFiles: [{ pattern: '.bai', required: false}, { pattern: '^.bai', required: false}], inputBinding: { position: 2, prefix: "--normal"}, doc: "BAM file of mapped reads for normal" }
  ref: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }],  inputBinding: { position: 2, prefix: "--ref"}, doc: "FASTA file of reference genome" }
  reg: { type: 'string?', inputBinding: { position: 2, prefix: "--reg"}, doc: "genomic region (in chr:start-end format); Required if no BED file provided." }
  bed: { type: 'File?', inputBinding: { position: 2, prefix: "--bed"}, doc: "genomic regions from file (BED format); Required if no region string provided." }
  output_filename: { type: 'string', inputBinding: { position: 10, prefix: ">", shellQuote: false}, doc: "Name for output file" } 

  # Optional Arguments
  min_k: { type: 'int?', inputBinding: { position: 2, prefix: "--min-k"}, doc: "min kmersize [default: 11]" }
  max_k: { type: 'int?', inputBinding: { position: 2, prefix: "--max-k"}, doc: "max kmersize [default: 101]" }
  trim_lowqual: { type: 'int?', inputBinding: { position: 2, prefix: "--trim-lowqual"}, doc: "trim bases below qv at 5' and 3' [default: 10]" }
  min_base_qual: { type: 'int?', inputBinding: { position: 2, prefix: "--min-base-qual"}, doc: "minimum base quality required to consider a base for SNV calling [default: 17]" }
  quality_range: { type: 'string?', inputBinding: { position: 2, prefix: "--quality-range"}, doc: "quality value range [default: !]" }
  min_map_qual: { type: 'int?', inputBinding: { position: 2, prefix: "--min-map-qual"}, doc: "minimum read mapping quality in Phred-scale [default: 15]" }
  max_as_xs_diff: { type: 'int?', inputBinding: { position: 2, prefix: "--max-as-xs-diff"}, doc: "maximum difference between AS and XS alignments scores [default: 5]" }
  tip_len: { type: 'int?', inputBinding: { position: 2, prefix: "--tip-len"}, doc: "max tip length [default: 11]" }
  cov_thr: { type: 'int?', inputBinding: { position: 2, prefix: "--cov-thr"}, doc: "min coverage threshold used to select reference anchors from the De Bruijn graph [default: 5]" }
  cov_ratio: { type: 'float?', inputBinding: { position: 2, prefix: "--cov-ratio"}, doc: "minimum coverage ratio used to remove nodes from the De Bruijn graph [default: 0.01]" }
  low_cov: { type: 'int?', inputBinding: { position: 2, prefix: "--low-cov"}, doc: "low coverage threshold used to remove nodes from the De Bruijn graph [default: 1]" }
  max_avg_cov: { type: 'int?', inputBinding: { position: 2, prefix: "--max-avg-cov"}, doc: "maximum average coverage allowed per region [default: 10000]" }
  window_size: { type: 'int?', inputBinding: { position: 2, prefix: "--window-size"}, doc: "window size of the region to assemble (in base-pairs) [default: 600]" }
  padding: { type: 'int?', inputBinding: { position: 2, prefix: "--padding"}, doc: "left/right padding (in base-pairs) applied to the input genomic regions [default: 250]" }
  dfs_limit: { type: 'int?', inputBinding: { position: 2, prefix: "--dfs-limit"}, doc: "limit dfs/bfs graph traversal search space [default: 1000000]" }
  max_indel_len: { type: 'int?', inputBinding: { position: 2, prefix: "--max-indel-len"}, doc: "limit on size of detectable indel [default: 500]" }
  max_mismatch: { type: 'int?', inputBinding: { position: 2, prefix: "--max-mismatch"}, doc: "max number of mismatches for near-perfect repeats [default: 2]" }
  node_str_len: { type: 'int?', inputBinding: { position: 2, prefix: "--node-str-len"}, doc: "length of sequence to display at graph node (default: 100)" }

  # Filter Arguments
  min_alt_count_tumor: { type: 'int?', inputBinding: { position: 2, prefix: "--min-alt-count-tumor"}, doc: "minimum alternative count in the tumor [default: 3]" }
  max_alt_count_normal: { type: 'int?', inputBinding: { position: 2, prefix: "--max-alt-count-normal"}, doc: "maximum alternative count in the normal [default: 0]" }
  min_vaf_tumor: { type: 'float?', inputBinding: { position: 2, prefix: "--min-vaf-tumor"}, doc: "minimum variant allele frequency (AlleleCov/TotCov) in the tumor [default: 0.04]" }
  max_vaf_normal: { type: 'float?', inputBinding: { position: 2, prefix: "--max-vaf-normal"}, doc: "maximum variant allele frequency (AlleleCov/TotCov) in the normal [default: 0]" }
  min_coverage_tumor: { type: 'int?', inputBinding: { position: 2, prefix: "--min-coverage-tumor"}, doc: "minimum coverage in the tumor [default: 4]" }
  max_coverage_tumor: { type: 'int?', inputBinding: { position: 2, prefix: "--max-coverage-tumor"}, doc: "maximum coverage in the tumor [default: 1000000]" }
  min_coverage_normal: { type: 'int?', inputBinding: { position: 2, prefix: "--min-coverage-normal"}, doc: "minimum coverage in the normal [default: 10]" }
  max_coverage_normal: { type: 'int?', inputBinding: { position: 2, prefix: "--max-coverage-normal"}, doc: "maximum coverage in the normal [default: 1000000]" }
  min_phred_fisher: { type: 'float?', inputBinding: { position: 2, prefix: "--min-phred-fisher"}, doc: "minimum fisher exact test score [default: 5]" }
  min_phred_fisher_str: { type: 'float?', inputBinding: { position: 2, prefix: "--min-phred-fisher-str"}, doc: "minimum fisher exact test score for STR mutations [default: 25]" }
  min_strand_bias: { type: 'float?', inputBinding: { position: 2, prefix: "--min-strand-bias"}, doc: "minimum strand bias threshold [default: 1]" }

  # Short Tandem Repeat Arguments
  max_unit_length: { type: 'int?', inputBinding: { position: 2, prefix: "--max-unit-length"}, doc: "maximum unit length of the motif [default: 4]" }
  min_report_unit: { type: 'int?', inputBinding: { position: 2, prefix: "--min-report-unit"}, doc: "minimum number of units to report [default: 3]" }
  min_report_len: { type: 'int?', inputBinding: { position: 2, prefix: "--min-report-len"}, doc: "minimum length of tandem in base pairs [default: 7]" }
  dist_from_str: { type: 'int?', inputBinding: { position: 2, prefix: "--dist-from-str"}, doc: "distance (in bp) of variant from STR locus [default: 1]" }

  # Flag Arguments
  linked_reads: { type: 'boolean?', inputBinding: { position: 2, prefix: "--linked-reads"}, doc: "linked-reads analysis mode" }
  primary_alignment_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--primary-alignment-only"}, doc: "only use primary alignments for variant calling" }
  xa_tag_filter: { type: 'boolean?', inputBinding: { position: 2, prefix: "--XA-tag-filter"}, doc: "skip reads with multiple hits listed in the XA tag (BWA only)" }
  active_region_off: { type: 'boolean?', inputBinding: { position: 2, prefix: "--active-region-off"}, doc: "turn off active region module" }
  kmer_recovery: { type: 'boolean?', inputBinding: { position: 2, prefix: "--kmer-recovery"}, doc: "turn on k-mer recovery (experimental)" }
  print_graph: { type: 'boolean?', inputBinding: { position: 2, prefix: "--print-graph"}, doc: "print graph (in .dot format) after every stage" }
  verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "--verbose"}, doc: "be verbose" }
  more_verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "--more-verbose"}, doc: "be more verbose" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--num-threads"
  ram:
    type: 'int?'
    default: 8 
    doc: "GB size of RAM to allocate to this task."
outputs:
  vcf:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
