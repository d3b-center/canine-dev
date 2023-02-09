cwlVersion: v1.2
class: CommandLineTool
id: bedtools_makewindows
doc: |
  BEDTOOLS makewindows
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
      bedtools makewindows
stdout: chunked_$(inputs.output_filename)
inputs:
  genome: { type: 'File?', inputBinding: { position: 2, prefix: "-g" }, doc: "Genome file size (see notes below).  Windows will be created for each chromosome in the file." }
  bed: { type: 'File?', inputBinding: { position: 2, prefix: "-b" }, doc: "BED file (with chrom,start,end fields).  Windows will be created for each interval in the file." }
  window_size: { type: 'int?', inputBinding: { position: 2, prefix: "-w" }, doc: "Divide each input interval (either a chromosome or a BED interval) to fixed-sized windows (i.e. same number of nucleotide in each window).  Can be combined with -s <step_size>" }
  step_size: { type: 'int?', inputBinding: { position: 2, prefix: "-s" }, doc: "Step size: i.e., how many base pairs to step before creating a new window. Used to create 'sliding' windows." }
  number_of_windows: { type: 'int?', inputBinding: { position: 2, prefix: "-n" }, doc: "Divide each input interval (either a chromosome or a BED interval) to fixed number of windows (i.e. same number of windows, with varying window sizes)." }
  reverse: { type: 'boolean?', inputBinding: { position: 2, prefix: "-reverse" }, doc: "Reverse numbering of windows in the output, i.e. report windows in decreasing order" }
  output_filename: { type: 'string', doc: "output file name" }

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
    type: stdout
