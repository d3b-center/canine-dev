cwlVersion: v1.2
class: CommandLineTool
id: bcftools_index
doc: |
  BCFTOOLS index 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.10.2'
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.input_vcf)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools index

inputs:
  # Required Inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF(.GZ) file to index" }

  # Index Arguments
  force: { type: 'boolean?', inputBinding: { position: 2, prefix: "--force"}, doc: "overwrite index if it already exists" }
  min_shift: { type: 'int?', inputBinding: { position: 2, prefix: "--min-shift"}, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  csi: { type: 'boolean?', inputBinding: { position: 2, prefix: "--csi"}, doc: "generate CSI-format index for VCF/BCF files [default]" }
  tbi: { type: 'boolean?', inputBinding: { position: 2, prefix: "--tbi"}, doc: "generate TBI-format index for VCF files" }
  nrecords: { type: 'boolean?', inputBinding: { position: 2, prefix: "--nrecords"}, doc: "print number of records based on existing index file" }
  stats: { type: 'boolean?', inputBinding: { position: 2, prefix: "--stats"}, doc: "print per contig stats based on existing index file" }

  cpu:
    type: 'int?'
    default: 2
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
      glob: $(inputs.input_vcf.basename) 
