cwlVersion: v1.2
class: CommandLineTool
id: bedtools_slop
doc: |
  BEDTOOLS slop
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bedtools:2.29.2'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bedtools slop

inputs:
  # Required Inputs
  input_file: { type: 'File', inputBinding: { position: 2, prefix: "-i" }, doc: "bed/gff/vcf file to process" }
  output_filename: { type: 'string', inputBinding: { position: 9, prefix: ">"}, doc: "output file name" }
  genome: { type: 'File', inputBinding: { position: 2, prefix: "-g"}, doc: "Genome file" }

  # Slop Arguments
  both: { type: 'int?', inputBinding: { position: 2, prefix: "-b"}, doc: "Increase the BED/GFF/VCF entry -b base pairs in each direction." } 
  left: { type: 'float?', inputBinding: { position: 2, prefix: "-l"}, doc: "The number of base pairs to subtract from the start coordinate." }
  right: { type: 'float?', inputBinding: { position: 2, prefix: "-r"}, doc: "The number of base pairs to add to the end coordinate." }
  strand: { type: 'boolean?', inputBinding: { position: 2, prefix: "-s"}, doc: "Define -l and -r based on strand. E.g. if used, -l 500 for a negative-stranded feature, it will add 500 bp downstream." }
  percent: { type: 'boolean?', inputBinding: { position: 2, prefix: "-pct"}, doc: "Define -l and -r as a fraction of the feature's length. E.g. if used on a 1000bp feature, -l 0.50, will add 500 bp upstream" }
  header: { type: 'boolean?', inputBinding: { position: 2, prefix: "-header"}, doc: "Print the header from the input file prior to results." }

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename)
