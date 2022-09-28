cwlVersion: v1.2
class: CommandLineTool
id: bedtools_merge
doc: |
  BEDTOOLS merge
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
      bedtools merge

inputs:
  # Required Inputs
  input_file: { type: 'File', inputBinding: { position: 2, prefix: "-i" }, doc: "bed/gff/vcf file to process" }
  output_filename: { type: 'string', inputBinding: { position: 9, prefix: ">"}, doc: "output file name" }

  # Merge Arguments
  force_strandedness: { type: 'boolean?', inputBinding: { position: 2, prefix: "-s" }, doc: "Force strandedness. That is, only merge features that are on the same strand. By default, merging is done without respect to strand." }
  merge_strand: { type: 'string?', inputBinding: { position: 2, prefix: "-S" }, doc: "Force merge for one specific strand only. Follow with + or - to force merge from only the forward or reverse strand, respectively." }
  max_distance: { type: 'int?', inputBinding: { position: 2, prefix: "-d" }, doc: "Maximum distance between features allowed for features to be merged." }
  columns: { type: 'string?', inputBinding: { position: 2, prefix: "-c" }, doc: "Specify columns from the B file to map onto intervals in A. Default: 5. Multiple columns can be specified in a comma-delimited list." }
  operations:
    type: 'string?'
    inputBinding:
      position: 2
      prefix: "-o"
    doc: |-
      Specify the operation that should be applied to -c.
      Valid operations:
          sum, min, max, absmin, absmax,
          mean, median, mode, antimode
          stdev, sstdev
          collapse (i.e., print a delimited list (duplicates allowed)),
          distinct (i.e., print a delimited list (NO duplicates allowed)),
          distinct_sort_num (as distinct, sorted numerically, ascending),
          distinct_sort_num_desc (as distinct, sorted numerically, desscending),
          distinct_only (delimited list of only unique values),
          count
          count_distinct (i.e., a count of the unique values in the column),
          first (i.e., just the first value in the column),
          last (i.e., just the last value in the column),
      Default: sum
      Multiple operations can be specified in a comma-delimited list." } 
  delimiter: { type: 'string?', inputBinding: { position: 2, prefix: "-delim" }, doc: "Specify a custom delimiter for the collapse operations." }
  precision: { type: 'int?', inputBinding: { position: 2, prefix: "-prec" }, doc: "Sets the decimal precision for output" }
  bed: { type: 'boolean?', inputBinding: { position: 2, prefix: "-bed" }, doc: "If using BAM input, write output as BED" }
  header: { type: 'boolean?', inputBinding: { position: 2, prefix: "-header" }, doc: "Print the header from the A file prior to results." }
  nobuf: { type: 'boolean?', inputBinding: { position: 2, prefix: "-nobuf" }, doc: "Disable buffered output. Using this option will cause each line of output to be printed as it is generated, rather than saved in a buffer. This will make printing large output files noticeably slower, but can be useful in conjunction with other software tools and scripts that need to process one line of bedtools output at a time." } 
  iobuf: { type: 'string?', inputBinding: { position: 2, prefix: "-iobuf" }, doc: "Specify amount of memory to use for input buffer. Takes an integer argument. Optional suffixes K/M/G supported. Note: currently has no effect with compressed files" }

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
