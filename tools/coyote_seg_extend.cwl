cwlVersion: v1.2
class: CommandLineTool
id: coyote_seg_extend
doc: "Extends segments"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'python:3.7.2'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: seg_extend_229b8c7.py
      writable: false
      entry:
        $include: ../scripts/seg_extend_229b8c7.py
    - entry: $(inputs.input_seg)
      writable: true
baseCommand: [python, seg_extend_229b8c7.py]
inputs:
  input_centromere_bed: { type: 'File', inputBinding: { position: 1 }, doc: "BED file containing centromere regions" }
  input_seg: { type: 'File', inputBinding: { position: 2, valueFrom: $(inputs.input_seg.basename) }, doc: "Modified ModelFinal SEG file" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.input_seg.basename) 
