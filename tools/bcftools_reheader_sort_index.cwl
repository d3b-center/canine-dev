cwlVersion: v1.2
class: CommandLineTool
id: bcftools_reheader_sort_index
doc: |
  BCFTOOLS reheader, sort, and optionall index
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
      bcftools reheader
  - position: 10
    shellQuote: false
    valueFrom: >
      | bcftools sort
  - position: 90
    shellQuote: false
    valueFrom: >
      $(inputs.output_type == "b" || inputs.output_type == "z" ? "&& bcftools index --threads inputs.cpu" : "")

inputs:
  # Required Arguments
  input_file: { type: 'File', inputBinding: { position: 9 }, doc: "VCF/BCF file to reheader" }
  output_filename: { type: 'string', inputBinding: { position: 12, prefix: "--output-file"}, doc: "output file name [stdout]" }

  # Reheader Arguments
  fai: { type: 'File?', inputBinding: { position: 2, prefix: "--fai"}, doc: "update sequences and their lengths from the .fai file" }
  header: { type: 'File?', inputBinding: { position: 2, prefix: "--header"}, doc: "new header" }
  samples: { type: 'File?', inputBinding: { position: 2, prefix: "--samples"}, doc: "new sample names" }

  # Sort Arguments
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
  min_shift: { type: 'int?', inputBinding: { position: 92, prefix: "--min-shift"}, doc: "set minimal interval size for CSI indices to 2^INT [14]" }
  force: { type: 'boolean?', inputBinding: { position: 92, prefix: "--force"}, doc: "overwrite index if it already exists" }
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
    default: 8 
    doc: "GB size of RAM to allocate to this task."
    inputBinding:
      position: 12
      prefix: "--max-mem"
      valueFrom: |
        $(self*1000)M
outputs:
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: $(inputs.output_filename)
