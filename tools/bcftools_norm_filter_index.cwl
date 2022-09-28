cwlVersion: v1.2
class: CommandLineTool
id: bcftools_norm_filter_index
doc: |
  BCFTOOLS reheader and sort
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
      bcftools norm --output-type u
  - position: 10
    prefix: "|"
    shellQuote: false
    valueFrom: >
      bcftools filter --threads $(inputs.cpu)
  - position: 20
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "&& bcftools index --threads " + inputs.cpu + " --output-file " + inputs.output_filename : "")

inputs:
  # Required inputs
  input_vcf: { type: 'File', secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}], inputBinding: { position: 9 }, doc: "VCF(.GZ) to norm, filter, and optionally index." }
  output_filename: { type: 'string', inputBinding: { position: 12, prefix: "--output-file"}, doc: "output file name [stdout]" }

  # Norm Arguments
  check_ref: { type: 'string?', inputBinding: { position: 2, prefix: "--check-ref"}, doc: "check REF alleles and exit (e), warn (w), exclude (x), or set (s) bad sites [e]" }
  remove_duplicates: { type: 'boolean?', inputBinding: { position: 2, prefix: "--remove-duplicates"}, doc: "remove duplicate lines of the same type." }
  rm_dup:
    type:
      - 'null'
      - type: enum
        name: rm_dup
        symbols: ["snps", "indels", "both", "all", "exact"]
    inputBinding:
      prefix: "--rm-dup"
      position: 2
    doc: |
      remove duplicate snps|indels|both|all|exact
  fasta_ref: { type: 'File?', inputBinding: { position: 2, prefix: "--fasta-ref"}, doc: "reference sequence" }
  multiallelics: { type: 'string?', inputBinding: { position: 2, prefix: "--multiallelics"}, doc: "split multiallelics (-) or join biallelics (+), type: snps|indels|both|any [both]" }
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  do_not_normalize: { type: 'boolean?', inputBinding: { position: 2, prefix: "--do-not-normalize"}, doc: "do not normalize indels (with -m or -c s)" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  strict_filter: { type: 'boolean?', inputBinding: { position: 2, prefix: "--strict-filter"}, doc: "when merging (-m+), merged site is PASS only if all sites being merged PASS" }
  targets: { type: 'string?', inputBinding: { position: 2, prefix: "--targets"}, doc: "similar to -r but streams rather than index-jumps" }
  targets_file: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file"}, doc: "similar to -R but streams rather than index-jumps" }
  site_win: { type: 'int?', inputBinding: { position: 2, prefix: "--site-win"}, doc: "buffer for sorting lines which changed position during realignment" }

  # Filter Arguments
  snpgap: { type: 'int?', inputBinding: { position: 12, prefix: "--SnpGap"}, doc: "filter SNPs within <int> base pairs of an indel" }
  indelgap: { type: 'int?', inputBinding: { position: 12, prefix: "--IndelGap"}, doc: "filter clusters of indels separated by <int> or fewer base pairs allowing only one to pass" }
  exclude: { type: 'string?', inputBinding: { position: 12, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  include: { type: 'string?', inputBinding: { position: 12, prefix: "--include"}, doc: "include only sites for which the expression is true (see man page for details" }
  mode:
    type:
      - 'null'
      - type: enum
        name: mode
        symbols: ["+", "x", "+x"]
    inputBinding:
      prefix: "--mode"
      position: 12
    doc: |
      "+": do not replace but add to existing FILTER; "x": reset filters at sites which pass
  filter_no_version: { type: 'boolean?', inputBinding: { position: 12, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  soft_filter: { type: 'string?', inputBinding: { position: 12, prefix: "--soft-filter"}, doc: "annotate FILTER column with <string> or unique filter name ('Filter%d') made up by the program ('+')" }
  set_gts:
    type:
      - 'null'
      - type: enum
        name: set_gts
        symbols: [".", "0"]
    inputBinding:
      prefix: "--set-GTs"
      position: 12
    doc: |
      set genotypes of failed samples to missing (.) or ref (0)
  filter_regions: { type: 'string?', inputBinding: { position: 12, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  filter_regions_file: { type: 'File?', inputBinding: { position: 12, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  filter_targets: { type: 'string?', inputBinding: { position: 12, prefix: "--targets"}, doc: "similar to --regions but streams rather than index-jumps" }
  filter_targets_file: { type: 'File?', inputBinding: { position: 12, prefix: "--targets-file"}, doc: "similar to --regions-file but streams rather than index-jumps" }
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 12
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]

  # Index Arguments
  force: { type: 'boolean?', inputBinding: { position: 92, prefix: "--force"}, doc: "overwrite index if it already exists" }
  min_shift: { type: 'int?', inputBinding: { position: 92, prefix: "--min-shift"}, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  csi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--csi"}, doc: "generate CSI-format index for VCF/BCF files [default]" }
  tbi: { type: 'boolean?', inputBinding: { position: 92, prefix: "--tbi"}, doc: "generate TBI-format index for VCF files" }
  nrecords: { type: 'boolean?', inputBinding: { position: 92, prefix: "--nrecords"}, doc: "print number of records based on existing index file" }
  stats: { type: 'boolean?', inputBinding: { position: 92, prefix: "--stats"}, doc: "print per contig stats based on existing index file" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
