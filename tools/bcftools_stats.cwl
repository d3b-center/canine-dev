cwlVersion: v1.2
class: CommandLineTool
id: bcftools_stats
doc: |
  BCFTOOLS stats 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.10.2'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools stats 

inputs:
  # Required Inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF files to concat, sort, and optionally index" }
  output_filename: { type: 'string', inputBinding: { position: 10, prefix: ">"}, doc: "output file name [stdout]" }

  # Stats Options
  af_bins: { type: 'string?', inputBinding: { position: 2, prefix: "--af-bins"}, doc: "comma separated list of allele frequency bins (e.g. 0.1,0.5,1)" }
  af_tag: { type: 'string?', inputBinding: { position: 2, prefix: "--af-tag"}, doc: "allele frequency INFO tag to use for binning. By default the allele frequency is estimated from AC/AN, if available, or directly from the genotypes (GT) if not." }
  first_allele_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--1st-allele-only"}, doc: "consider only the 1st alternate allele at multiallelic sites" }
  collapse: 
    type:
      - 'null'
      - type: enum
        name: collapse 
        symbols: ["snps","indels","both","all","some","none"]
    inputBinding:
      prefix: "--collapse"
      position: 2
    doc: |
      treat as identical records with <snps|indels|both|all|some|none>
  depth: { type: 'string?', inputBinding: { position: 2, prefix: "--depth"}, doc: "ranges of depth distribution: min, max, and size of the bin" }
  debug: { type: 'boolean?', inputBinding: { position: 2, prefix: "--debug"}, doc: "produce verbose per-site and per-sample output" }
  exclude: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude"}, doc: "exclude sites for which EXPRESSION is true" }
  exons: { type: 'File?', secondaryFiles: [{pattern: '.tbi', required: true}], inputBinding: { position: 2, prefix: "--exons"}, doc: "bgzipped/tabix indexed tab-delimited file with exons for indel frameshifts statistics. The columns of the file are CHR, FROM, TO, with 1-based, inclusive, positions." }
  apply_filters: { type: 'string?', inputBinding: { position: 2, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings" }
  indexed_reference_fasta: { type: File?', secondaryFiles: [{pattern: '.fai', required: true}], inputBinding: { position: 2, prefix: "--fasta-ref"}, doc: "faidx indexed reference sequence file to determine INDEL context" }
  include: { type: 'string?', inputBinding: { position: 2, prefix: "--include"}, doc: "include only sites for which EXPRESSION is true" }
  split_by_id: { type: 'boolean?', inputBinding: { position: 2, prefix: "--split-by-ID"}, doc: "collect stats separately for sites which have the ID column set or which do not have the ID column set" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict stats to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict stats to regions listed in file" }
  samples: { type: 'string?', inputBinding: { position: 2, prefix: "--samples"}, doc: "list of samples for sample stats" }
  samples_file: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file"}, doc: "file of samples to include" }
  targets: { type: 'string?', inputBinding: { position: 2, prefix: "--targets"}, doc: "similar to regions but streams rather than index-jumps" }
  targets_file: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file"}, doc: "similar to regions_file but streams rather than index-jumps" }
  user_tstv: { type: 'string?', inputBinding: { position: 2, prefix: "--user-tstv"}, doc: "collect Ts/Tv stats for any tag using the given binning [0:1:100]" }
  verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "--verbose"}, doc: "produce verbose per-site and per-sample output" }
  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      prefix: "--threads"
      position: 2
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  stats:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
