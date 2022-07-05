cwlVersion: v1.2
class: CommandLineTool
id: gatk_getpileupsummaries
doc: "Tabulates pileup metrics for inferring contamination"
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
      MergeMutectStats
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : 'output'; var ext = 'Mutect2.merged.stats'; return pre+'.'+ext}
inputs:
  input_stats:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --stats
    inputBinding:
      position: 3
    doc: "Stats from Mutect2 scatters of a single tumor or tumor-normal pair  This argument must be specified at least once."
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
  merged_stats:
    type: File
    outputBinding:
      glob: '*.merged.stats'
