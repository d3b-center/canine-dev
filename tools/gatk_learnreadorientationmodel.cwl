cwlVersion: v1.2
class: CommandLineTool
id: gatk_learnreadorientationmodel
doc: "Get the maximum likelihood estimates of artifact prior probabilities in the orientation bias mixture model filter"
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
      LearnReadOrientationModel 
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : 'output'; var ext = 'artifact-priors.tar.gz'; return pre+'.'+ext}

inputs:
  input_f1r2_tars:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input 
    inputBinding:
      position: 3
  convergence_threshold: { type: 'float?', inputBinding: { position: 3, prefix: "--convergence-threshold"}, doc: "Stop the EM when the distance between parameters between iterations falls below this value" }
  max_depth: { type: 'int?', inputBinding: { position: 3, prefix: "--max-depth"}, doc: "sites with depth higher than this value will be grouped" }
  num_em_iterations: { type: 'int?', inputBinding: { position: 3, prefix: "--num-em-iterations"}, doc: "give up on EM after this many iterations" }
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
      glob: '*.artifact-priors.tar.gz'
