cwlVersion: v1.2
class: CommandLineTool
id: coyote_manta_sv_annotation_parallel
doc: "Extends segments"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/pysam-bedtools:3.9'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: manta_sv_annotation_parallel_8820499.py
      writable: false
      entry:
        $include: ../scripts/manta_sv_annotation_parallel_8820499.py
baseCommand: [python, manta_sv_annotation_parallel_8820499.py]
arguments:
  - position: 2
    prefix: "--tempdir"
    valueFrom:
      .
inputs:
  input_vcf: { type: 'File', inputBinding: { position: 2, prefix: "--vcf" }, doc: "input file VCF file" }
  annotation_bed: { type: 'File', inputBinding: { position: 2, prefix: "--annof" }, doc: "BED file containing annotation information" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--outvcfname" }, doc: "String to use as output_filename(relative or full path)" }
  add_genes_in_between: { type: 'boolean?', inputBinding: { position: 2, prefix: "--add-genes-in-between" }, doc: "Add genes in between" }
  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
