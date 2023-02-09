cwlVersion: v1.2
class: CommandLineTool
id: sequenza_coyote
doc: "Runs the custom TGEN Coyote Sequenza R script on the seqz.gz"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/sequenza:3.0.0'
  - class: InitialWorkDirRequirement
    listing:
    - entryname: sequenza.R 
      writable: false
      entry:
        $include: ../scripts/sequenza.R
baseCommand: [Rscript, sequenza.R]
arguments:
  - position: 2
    prefix: '--out_dir'
    shellQuote: false
    valueFrom: |
      $(inputs.sample_name)
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  input_seqz:
    type: 'File'
    doc: "Input seqz.gz file."
    inputBinding:
      position: 2
      prefix: "--sample_input"
  sample_name:
    type: 'string'
    doc: "Name of the sample."
    inputBinding:
      position: 2
      prefix: "--sample_name"

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'Directory'
    outputBinding:
      glob: $(inputs.sample_name)
