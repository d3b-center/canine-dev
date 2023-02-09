cwlVersion: v1.2
class: CommandLineTool
id: coyote_annot_seg
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
    - entryname: annotSeg_7102f1c.pl
      writable: false
      entry:
        $include: ../scripts/annotSeg_7102f1c.pl
    - $(inputs.input_file)
baseCommand: [perl, annotSeg_7102f1c.pl]
inputs:
  input_annotation_gtf: { type: 'File',  inputBinding: { position: 1 }, doc: "Annotation file downloaded from Ensembl (eg. Ensembl_v70_hs37d5.gtf)." }
  input_file: { type: 'File', inputBinding: { position: 2, valueFrom: $(self.basename) }, doc: "File to annotate" }
  amp_threshold: { type: 'float', inputBinding: { position: 4 }, doc: "threshold for marking amplifications as PASS (e.g 0.58) and annotating" }
  del_threshold: { type: 'float', inputBinding: { position: 4 }, doc: "threshold for marking deletions as PASS (e.g -0.9) and annotating" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  output: 
    type: File
    outputBinding:
      glob: "*.vcf" 
