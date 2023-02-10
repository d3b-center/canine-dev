cwlVersion: v1.2
class: CommandLineTool
id: bcftools_view_view_index
doc: |
  Niche tool for two tier bcftools view filtering (include then exclude) followed by optionally index 
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
      bcftools view
  - position: 10
    shellQuote: false
    valueFrom: >
      | bcftools view
  - position: 90
    prefix: "&&"
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "bcftools index --threads " + inputs.cpu : "echo DONE")
  - position: 99
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? inputs.output_filename : "")

inputs:
  # Required Inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF files to concat, sort, and optionally index" }
  output_filename: { type: 'string', inputBinding: { position: 12, prefix: "--output-file"}, doc: "output file name [stdout]" }
  include: { type: 'string', inputBinding: { position: 2, prefix: "--include"}, doc: "include sites for which the expression is true (see man page for details)" }
  exclude: { type: 'string', inputBinding: { position: 12, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }

  # Optional Arugments
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
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
