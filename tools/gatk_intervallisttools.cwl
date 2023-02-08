cwlVersion: v1.2
class: CommandLineTool
id: gatk_intervallisttools
doc: "A tool for performing various IntervalList manipulations"
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
      IntervalListTools 
  - position: 3
    shellQuote: false
    prefix: "--OUTPUT"
    valueFrom: >-
      ${
        if (inputs.scatter_count > 1 && inputs.scatter_content > 1) {
          return "."
        }
        else {
          if ( inputs.output_prefix == null ) {
            return "output.interval_list"
          }
          else {
            return inputs.output_prefix + ".interval_list";
          }
        }
      }

inputs:
  enable_tool: { type: 'string?', doc: "Hook to disable this tool when using it in a CWL workflow." }
  input_intervals:
    type:
      - type: array
        items: File
        inputBinding:
          prefix: "--INPUT"
    inputBinding:
      position: 3
    doc: |
      One or more interval lists. If multiple interval lists are provided the output
      is theresult of merging the inputs. Supported formats are interval_list and
      VCF. This argument must be specified at least once.
  action:
    type:
      - 'null'
      - type: enum
        name: action 
        symbols: ["CONCAT","UNION","INTERSECT","SUBTRACT","SYMDIFF","OVERLAPS"]
    doc: |
      Action to take on inputs.  Default value: CONCAT. CONCAT (The concatenation of all the
      intervals in all the INPUTs, no sorting or merging of overlapping/abutting intervals
      implied. Will result in a possibly unsorted list unless requested otherwise.)
      UNION (Like CONCATENATE but with UNIQUE and SORT implied, the result being the set-wise
      union of all INPUTS, with overlapping and abutting intervals merged into one.)
      INTERSECT (The sorted and merged set of all loci that are contained in all of the INPUTs.)
      SUBTRACT (Subtracts the intervals in SECOND_INPUT from those in INPUT. The resulting loci
      are those in INPUT that are not in SECOND_INPUT.)
      SYMDIFF (Results in loci that are in INPUT or SECOND_INPUT but are not in both.)
      OVERLAPS (Outputs the entire intervals from INPUT that have bases which overlap any
      interval from SECOND_INPUT. Note that this is different than INTERSECT in that each
      original interval is either emitted in its entirety, or not at all.)
  break_bands_at_multiples_of: { type: 'int?', inputBinding: { position: 2, prefix: "--BREAK_BANDS_AT_MULTIPLES_OF"}, doc: "If set to a positive value will create a new interval list with the original intervals broken up at integer multiples of this value. Set to 0 to NOT break up intervals." }
  comment:
    type:
      - 'null'
      - type: array
        items: string
        inputBinding:
          prefix: "--COMMENT"
    inputBinding:
      position: 3
    doc: |
      One or more lines of comment to add to the header of the output file (as @CO
      lines in the SAM header). This argument may be specified 0 or more times.
  include_filtered:
    type:
      - 'null'
      - type: enum
        name: include_filtered
        symbols: ["true","false"]
    inputBinding:
      position: 3
    doc: "Whether to include filtered variants in the vcf when generating an interval list from vcf."
  invert:
    type:
      - 'null'
      - type: enum
        name: invert
        symbols: ["true","false"]
    inputBinding:
      position: 3
    doc: |
      Produce the inverse list of intervals, that is, the regions in the genome that
      are not covered by any of the input intervals. Will merge abutting intervals
      first. Output will be sorted.
  output_value:
    type:
      - 'null'
      - type: enum
        name: output_value
        symbols: ["NONE", "BASES", "INTERVALS"]
    inputBinding:
        position: 3
    doc: |
      What value to output to COUNT_OUTPUT file or stdout (for scripting). If
      COUNT_OUTPUT is provided, this parameter must not be NONE.
  count_output_filename: { type: 'string?', inputBinding: { position: 2, prefix: "--COUNT_OUTPUT"}, doc: "File to which to print count of bases or intervals in final output interval list. When not set, value indicated by OUTPUT_VALUE will be printed to stdout. If this parameter is set, OUTPUT_VALUE must not be NONE." }
  padding: { type: 'int?', inputBinding: { position: 2, prefix: "--PADDING"}, doc: "The amount to pad each end of the intervals by before other operations are undertaken. Negative numbers are allowed and indicate intervals should be shrunk. Resulting intervals < 0 bases long will be removed. Padding is applied to the interval lists (both INPUT and SECOND_INPUT, if provided) before the ACTION is performed." }
  scatter_content: { type: 'int?', inputBinding: { position: 2, prefix: "--SCATTER_CONTENT"}, doc: "When scattering with this argument, each of the resultant files will (ideally) have this amount of 'content', which means either base-counts or interval-counts depending on SUBDIVISION_MODE. When provided, overrides SCATTER_COUNT" }
  scatter_count: { type: 'int?', inputBinding: { position: 2, prefix: "--SCATTER_COUNT"}, doc: "The number of files into which to scatter the resulting list by locus; in some situations, fewer intervals may be emitted." }
  second_input:
    type:
      - 'null'
      - type: array
        items: File
        inputBinding:
          prefix: "--SECOND_INPUT"
    inputBinding:
        position: 3
    doc: |
      Second set of intervals for SUBTRACT and DIFFERENCE operations. This argument
      may be specified 0 or more times.
  sort:
    type:
      - 'null'
      - type: enum
        name: sort
        symbols: ["true","false"]
    inputBinding:
      position: 3
    doc: "If true, sort the resulting interval list by coordinate."
  subdivision_mode:
    type:
      - 'null'
      - type: enum
        name: subdivision_mode
        symbols: ["INTERVAL_SUBDIVISION","BALANCING_WITHOUT_INTERVAL_SUBDIVISION","BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW","INTERVAL_COUNT"]
    inputBinding:
      position: 3
    doc: |
      The mode used to scatter the interval list.  Default value: INTERVAL_SUBDIVISION.
      INTERVAL_SUBDIVISION (Scatter the interval list into similarly sized interval lists (by
      base count), breaking up intervals as needed.)
      BALANCING_WITHOUT_INTERVAL_SUBDIVISION (Scatter the interval list into similarly sized
      interval lists (by base count), but without breaking up intervals.)
      BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW (Scatter the interval list into
      similarly sized interval lists (by base count), but without breaking up intervals. Will
      overflow current interval list so that the remaining lists will not have too many bases to
      deal with.)
      INTERVAL_COUNT (Scatter the interval list into similarly sized interval lists (by interval
      count, not by base count). Resulting interval lists will contain similar number of
      intervals.)
  unique:
    type:
      - 'null'
      - type: enum
        name: unique
        symbols: ["true","false"]
    inputBinding:
      position: 3
    doc:  "If true, merge overlapping and adjacent intervals to create a list of unique intervals. Implies SORT=true."
  output_prefix:
    type: 'string?'
    doc: "String to use as the prefix for the outputs."
  max_memory:
    type: 'int?'
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    doc: "Number of CPUs to allocate to this task."
outputs:
  intervals:
    type: 'File[]'
    outputBinding:
      glob: '*.interval_list'
  count_output:
    type: 'File?'
    outputBinding:
      glob: $(inputs.count_output_filename)
