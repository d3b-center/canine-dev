cwlVersion: v1.2
class: CommandLineTool
id: bcftools_query
doc: |
  BCFTOOLS query
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
      bcftools query

inputs:
  # Required Inputs
  input_vcfs: { type: 'File[]', inputBinding: { position: 9 }, doc: "One or more VCF files to query." }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output-file"}, doc: "output file name" }

  # Query Arguments
  exclude: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  format: { type: 'string?', inputBinding: { position: 2, prefix: "--format"}, doc: "see man page for details" }
  print_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--print-header"}, doc: "print header" }
  include: { type: 'string?', inputBinding: { position: 2, prefix: "--include"}, doc: "select sites for which the expression is true (see man page for details)" }
  list_samples: { type: 'boolean?', inputBinding: { position: 2, prefix: "--list-samples"}, doc: "print the list of samples and exit" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  samples: { type: 'string?', inputBinding: { position: 2, prefix: "--samples"}, doc: "list of samples to include" }
  samples_file: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file"}, doc: "file of samples to include" }
  targets: { type: 'string?', inputBinding: { position: 2, prefix: "--targets"}, doc: "similar to -r but streams rather than index-jumps" }
  targets_file: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file"}, doc: "similar to -R but streams rather than index-jumps" }
  allow_undef_tags: { type: 'boolean?', inputBinding: { position: 2, prefix: "--allow-undef-tags"}, doc: "print '.' for undefined tags" }

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
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
