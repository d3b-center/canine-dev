cwlVersion: v1.2
class: CommandLineTool
id: coyote_delly_sv_annotation
doc: "Coyote Python script to annotate Delly Output"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/delly:0.7.6'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname:  
      writable: false
      entry: svtop.delly.sv_annotation.parallel_8820499.py
        $include: ../scripts/svtop.delly.sv_annotation.parallel_8820499.py
baseCommand: [python, svtop.delly.sv_annotation.parallel_8820499.py]
inputs:
  input_vcf: { type: 'File', inputBinding: { position: 2, prefix: "--vcf" }, doc: "VCF from Delly" }
  input_annotation_bed: { type: 'File', inputBinding: { position: 2, prefix: "--annof" }, doc: "BED file containing neccsary annotation information for Delly outputs." }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix; "--outvcfname" }, doc: "Name for the output file." }

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
    type: File
    outputBinding:
      glob: $(inputs.output_filename) 
