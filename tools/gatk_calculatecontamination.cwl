cwlVersion: v1.2
class: CommandLineTool
id: gatk_calculatecontamination
doc: "Calculate the fraction of reads coming from cross-sample contamination"
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
      CalculateContamination 
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_tumor_pileup.nameroot; var ext = 'contamination.table'; return pre+'.'+ext}
  - position: 3
    shellQuote: false
    prefix: "--tumor-segmentation"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_tumor_pileup.nameroot; var ext = 'segmentation.table'; return pre+'.'+ext}
inputs:
  input_tumor_pileup: { type: 'File', inputBinding: { position: 2, prefix: "--input"}, doc: "The tumor/test input pileup table" }
  input_normal_pileup: { type: 'File?', inputBinding: { position: 2, prefix: "--matched-normal"}, doc: "The matched normal input pileup table" }
  high_coverage_ratio_threshold: { type: 'float?', inputBinding: { position: 2, prefix: "--high-coverage-ratio-threshold"}, doc: "The maximum coverage relative to the mean." }
  low_coverage_ratio_threshold: { type: 'float?', inputBinding: { position: 2, prefix: "--low-coverage-ratio-threshold"}, doc: "The minimum coverage relative to the median." }
  output_prefix: { type: 'string?', doc: "String to use as the prefix for the outputs." }

  max_memory:
    type: 'int?'
    default: 4
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
outputs:
  contamination_table:
    type: File
    outputBinding:
      glob: '*.contamination.table'
  segmentation_table:
    type: File
    outputBinding:
      glob: '*.segmentation.table'
