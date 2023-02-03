cwlVersion: v1.2
class: CommandLineTool
id: tar_dir
requirements:
  - class: InitialWorkDirRequirement
    listing: $(inputs.input_dir)
baseCommand: [tar, -czf]
inputs:
  tarfile:
    type: string
    inputBinding:
      position: 1
  input_dir:
    type: Directory
    inputBinding:
      position: 2
      valueFrom: $(self.basename)
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.tarfile)
