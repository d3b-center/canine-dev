cwlVersion: v1.2
class: CommandLineTool
id: bcftools_annotate
doc: |
  BCFTOOLS annotate
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
      bcftools annotate

inputs:
  # Required Inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF file to annotate and view" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output-file"}, doc: "output file name [stdout]" }

  # Annotate Arguments
  annotations: { type: 'File?', inputBinding: { position: 2, prefix: "--annotations"}, doc: "VCF file or tabix-indexed file with annotations: CHR\tPOS[\tVALUE]+" }
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
  columns: { type: 'string?', inputBinding: { position: 2, prefix: "--columns"}, doc: "list of columns in the annotation file, e.g. CHROM,POS,REF,ALT,-,INFO/TAG. See man page for details" }
  exclude: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  header_lines: { type: 'File?', inputBinding: { position: 2, prefix: "--header-lines"}, doc: "File containing lines which should be appended to the VCF header" }
  set_id: { type: 'string?', inputBinding: { position: 2, prefix: "--set-id"}, doc: "set ID column, see man page for details" }
  include: { type: 'string?', inputBinding: { position: 2, prefix: "--include"}, doc: "select sites for which the expression is true (see man page for details)" }
  keep_sites: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep-sites"}, doc: "leave -i/-e sites unchanged instead of discarding them" }
  merge_logic: { type: 'string?', inputBinding: { position: 2, prefix: "--merge-logic"}, doc: "merge logic for multiple overlapping regions (see man page for details), EXPERIMENTAL" }
  mark_sites: { type: 'string?', inputBinding: { position: 2, prefix: "--mark-sites"}, doc: "add INFO/tag flag to sites which are ('+') or are not ('-') listed in the -a file" }
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  rename_chrs: { type: 'File?', inputBinding: { position: 2, prefix: "--rename-chrs"}, doc: "rename sequences according to map file: from\tto" }
  samples: { type: 'string?', inputBinding: { position: 2, prefix: "--samples"}, doc: "comma separated list of samples to annotate (or exclude with '^' prefix)" }
  samples_file: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file"}, doc: "file of samples to annotate (or exclude with '^' prefix)" }
  single_overlaps: { type: 'boolean?', inputBinding: { position: 2, prefix: "--single-overlaps"}, doc: "keep memory low by avoiding complexities arising from handling multiple overlapping intervals" }
  remove: { type: 'string?', inputBinding: { position: 2, prefix: "--remove"}, doc: "list of annotations (e.g. ID,INFO/DP,FORMAT/DP,FILTER) to remove (or keep with '^' prefix). See man page for details" }
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 2
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]

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
    secondaryFiles: [{ pattern: '.csi', required: false }, { pattern: '.tbi', required: false }]
    outputBinding:
      glob: $(inputs.output_filename)
