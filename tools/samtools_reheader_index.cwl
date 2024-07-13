class: CommandLineTool
cwlVersion: v1.2
id: samtools_reheader_index
doc: |-
  reheaders BAM/CRAM then indexes
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'staphb/samtools:1.20'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      samtools reheader
  - position: 9
    shellQuote: false
    prefix: ">"
    valueFrom: >
      $(inputs.output_filename ? inputs.output_filename : inputs.input_reads.basename.replace(/(cr|b)am$/, "rehead.$&"))
  - position: 10
    shellQuote: false
    prefix: "&&"
    valueFrom: >
      samtools index
  - position: 19
    shellQuote: false
    valueFrom: >
      $(inputs.output_filename ? inputs.output_filename : inputs.input_reads.basename.replace(/(cr|b)am$/, "rehead.$&"))
inputs:
  # View Positional Arguments
  input_header: { type: 'File?', inputBinding: { position: 7 }, doc: "New header file" }
  input_reads: { type: File, inputBinding: { position: 8 }, doc: "Input BAM/CRAM file" }
  output_filename: { type: 'string?', doc: "Output filename" }

  # Reheader Arguments
  no_pg: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-PG" }, doc: "Do not generate a @PG header line." }
  command: { type: 'string?', inputBinding: { position: 2, shellQuote: true, prefix: "--command" }, doc: "Allow the header from in.bam to be processed by external CMD and read back the result." }

  # Index Arguments
  bai: { type: 'boolean?', inputBinding: { position: 12, prefix: "-b"}, doc: "Generate BAI-format index for BAM files [default]" }
  csi: { type: 'boolean?', inputBinding: { position: 12, prefix: "-c"}, doc: "Generate CSI-format index for BAM files" }
  min_interval: { type: 'int?', inputBinding: { position: 12, prefix: "-m"}, doc: "Set minimum interval size for CSI indices to 2^INT [14]" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      prefix: "--threads"
      position: 12
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."

outputs:
  output:
    type: File
    secondaryFiles: [{pattern: '.bai', required: false}, {pattern: '^.bai', required: false}, {pattern: '.crai', required: false}, {pattern: '^.crai', required: false}]
    outputBinding:
      glob: '*.*am'

$namespaces:
  sbg: https://sevenbridges.com
