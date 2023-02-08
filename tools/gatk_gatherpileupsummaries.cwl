cwlVersion: v1.2
class: CommandLineTool
id: gatk_gatherpileupsummaries
doc: "Combine output files from GetPileupSummary in the order defined by a sequence dictionary"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.1.8.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk
  - position: 1
    shellQuote: false
    prefix: "--java-options"
    valueFrom: >-
      $("\"-Xmx"+Math.floor(inputs.max_memory*1000/1.074 - 1)+"M\"")
  - position: 2
    shellQuote: false
    valueFrom: >-
      GatherPileupSummaries
  - position: 3
    shellQuote: false
    prefix: "-O"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : 'output'; var ext = 'pileups.table.tsv'; return pre+'.'+ext}
inputs:
  input_tables:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 3
    doc: "Pileup table(s) output from PileupSummaryTable"
  reference_dict: { type: 'File', inputBinding: { position: 3, prefix: "--sequence-dictionary" }, doc: "sequence dictionary (.dict) file" }
  output_prefix:
    type: 'string?'
    doc: "String to use as the prefix for the outputs."
  max_memory:
    type: 'int?'
    default: 8
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.pileups.table.tsv'
