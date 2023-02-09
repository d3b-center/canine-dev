cwlVersion: v1.2
class: CommandLineTool
id: gatk_filterintervals
doc: "Filters intervals based on annotations and/or count statistics"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.1.8.0'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk
  - position: 1
    shellQuote: false
    prefix: "--java-options"
    valueFrom: >-
      $("\"-Xmx"+Math.floor(inputs.max_memory*1000/1.074 - 1)+"M\"")
  - position: 2
    shellQuote: false
    valueFrom: >-
      FilterIntervals
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var prefix = inputs.output_prefix ? inputs.output_prefix : 'output'; return prefix + '.interval_list';}
inputs:
  # Required Arguments
  input_intervals_list: { type: 'File?', inputBinding: { position: 3, prefix: "--intervals"}, doc: "File containing genomic intervals over which to operate." }
  input_intervals:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--intervals"
    inputBinding:
      position: 3
    doc: "One or more genomic intervals over which to operate."

  # Optional Arguments
  input_exclude_intervals_list: { type: 'File?', inputBinding: { position: 3, prefix: "--exclude-intervals"}, doc: "File containing genomic intervals to exclude from processing." }
  input_exclude_intervals:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--exclude-intervals"
    inputBinding:
      position: 3
    doc: "One or more genomic intervals to exclude from processing."
  annotated_intervals: { type: 'File?', inputBinding: { position: 3, prefix: "--annotated-intervals"}, doc: "Input file containing annotations for genomic intervals (output of AnnotateIntervals). Must be provided if no counts files are provided." }
  input_read_counts:
    type:
      - 'null'
      - type: array
        items: File
        inputBinding:
          prefix: "--input"
    inputBinding:
      position: 3
    doc: |
      Input TSV or HDF5 files containing integer read counts in genomic intervals
      (output of CollectReadCounts). Must be provided if no annotated-intervals file
      is provided. This argument may be specified 0 or more times.
  extreme_count_filter_maximum_percentile: { type: 'float?', inputBinding: { position: 3, prefix: "--extreme-count-filter-maximum-percentile"}, doc: "Maximum-percentile parameter for the extreme-count filter. Intervals with a count that has a percentile strictly greater than this in a percentage of samples strictly greater than extreme-count-filter-percentage-of-samples will be filtered out. (This is the second count-based filter applied.)" }
  extreme_count_filter_minimum_percentile: { type: 'float?', inputBinding: { position: 3, prefix: "--extreme-count-filter-minimum-percentile"}, doc: "Minimum-percentile parameter for the extreme-count filter. Intervals with a count that has a percentile strictly less than this in a percentage of samples strictly greater than extreme-count-filter-percentage-of-samples will be filtered out. (This is the second count-based filter applied.)" }
  extreme_count_filter_percentage_of_samples: { type: 'float?', inputBinding: { position: 3, prefix: "--extreme-count-filter-percentage-of-samples"}, doc: "Percentage-of-samples parameter for the extreme-count filter. Intervals with a count that has a percentile outside of [extreme-count-filter-minimum-percentile, extreme-count-filter-maximum-percentile] in a percentage of samples strictly greater than this will be filtered out. (This is the second count-based filter applied.)" }
  interval_exclusion_padding: { type: 'int?', inputBinding: { position: 3, prefix: "--interval-exclusion-padding"}, doc: "Amount of padding (in bp) to add to each interval you are excluding." }
  interval_merging_rule:
    type:
      - 'null'
      - type: enum
        name: interval_merging_rule
        symbols: ["ALL","OVERLAPPING_ONLY"]
    inputBinding:
      position: 3
      prefix: "--interval-merging-rule"
    doc: "By default, the program merges abutting intervals (i.e. intervals that are directly side-by-side but do not actually overlap) into a single continuous interval. However you can change this behavior if you want them to be treated as separate intervals instead."
  interval_set_rul:
    type:
      - 'null'
      - type: enum
        name: interval_set_rule
        symbols: ["UNION","INTERSECTION"]
    inputBinding:
      position: 3
      prefix: "--interval-set-rule"
    doc: "Set merging approach to use for combining interval inputs"
  interval_padding: { type: 'int?', inputBinding: { position: 3, prefix: "--interval-padding"}, doc: "Amount of padding (in bp) to add to each interval you are including." }
  low_count_filter_count_threshold: { type: 'int?', inputBinding: { position: 3, prefix: "--low-count-filter-count-threshold"}, doc: "Count-threshold parameter for the low-count filter. Intervals with a count strictly less than this threshold in a percentage of samples strictly greater than low-count-filter-percentage-of-samples will be filtered out. (This is the first count-based filter applied.)" }
  low_count_filter_percentage_of_samples: { type: 'float?', inputBinding: { position: 3, prefix: "--low-count-filter-percentage-of-samples"}, doc: "Percentage-of-samples parameter for the low-count filter. Intervals with a count strictly less than low-count-filter-count-threshold in a percentage of samples strictly greater than this will be filtered out. (This is the first count-based filter applied.)" }
  maximum_gc_content: { type: 'float?', inputBinding: { position: 3, prefix: "--maximum-gc-content"}, doc: "Maximum allowed value for GC-content annotation (inclusive)." }
  maximum_mappability: { type: 'float?', inputBinding: { position: 3, prefix: "--maximum-mappability"}, doc: "Maximum allowed value for mappability annotation (inclusive)." }
  maximum_segmental_duplication_content: { type: 'float?', inputBinding: { position: 3, prefix: "--maximum-segmental-duplication-content"}, doc: "Maximum allowed value for segmental-duplication-content annotation (inclusive)." }
  minimum_gc_content: { type: 'float?', inputBinding: { position: 3, prefix: "--minimum-gc-content"}, doc: "Minimum allowed value for GC-content annotation (inclusive)." }
  minimum_mappability: { type: 'float?', inputBinding: { position: 3, prefix: "--minimum-mappability"}, doc: "Minimum allowed value for mappability annotation (inclusive)." }
  minimum_segmental_duplication_content: { type: 'float?', inputBinding: { position: 3, prefix: "--minimum-segmental-duplication-content"}, doc: "Minimum allowed value for segmental-duplication-content annotation (inclusive)." }
  output_prefix:
    type: 'string?'
    doc: "String to use as the prefix for the outputs."
  max_memory:
    type: 'int?'
    default: 16
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
outputs:
  output: { type: 'File?', outputBinding: { glob: '*.interval_list' } }
