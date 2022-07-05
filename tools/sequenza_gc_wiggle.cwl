cwlVersion: v1.2
class: CommandLineTool
id: sequenza_gc_wiggle
doc: "Given a fasta file and a window size it computes the GC percentage across the sequences, and returns a file in the UCSC wiggle format."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'sequenza/sequenza:3.0.0'
baseCommand: [sequenza-utils, gc_wiggle]
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  input_fasta:
    type: 'File'
    doc: "Input fasta file."
    inputBinding:
      position: 2
      prefix: "--fasta"
  window:
    type: 'int?'
    doc: "Window size used for binning the original seqz file."
    inputBinding:
      position: 2
      prefix: "-w"
  output_filename:
    type: 'string'
    doc: "Name of output file."
    inputBinding:
      position: 2
      prefix: "-o"

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  wiggle:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
