cwlVersion: v1.2
class: CommandLineTool
id: untar
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      $(inputs.outdir ? "mkdir -p " + inputs.outdir + " && " : "") tar -xf

inputs:
  tarfile:
    type: File
    inputBinding:
      position: 1
  outdir:
    type: string?
    inputBinding:
      position: 2
      prefix: "--directory"
  output_name:
    type: string?
outputs:
  output:
    type: 'Directory?'
    outputBinding:
      loadListing: deep_listing
      glob: |
        $(inputs.outdir ? inputs.outdir : inputs.output_name)
