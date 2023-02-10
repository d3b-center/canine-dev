cwlVersion: v1.2
class: CommandLineTool
id: bedtools_intersect
doc: |
  BEDTOOLS intersect
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bedtools:2.29.2'
baseCommand: [bedtools, intersect]

inputs:
  # Required Inputs
  input_a: { type: 'File', inputBinding: { position: 2, prefix: "-a" }, doc: "bed/gff/vcf/bam file to intersect with input_b" }
  input_b: { type: 'File', inputBinding: { position: 2, prefix: "-b" }, doc: "bed/gff/vcf/bam file to intersect with input_a" }
  output_filename: { type: 'string', inputBinding: { position: 8, prefix: ">" }, doc: "Name for output file" }

  # Intersect Arguments
  wa: { type: 'boolean?', inputBinding: { position: 2, prefix: "-wa"}, doc: "Write the original entry in A for each overlap." }
  wb: { type: 'boolean?', inputBinding: { position: 2, prefix: "-wb"}, doc: "Write the original entry in B for each overlap. - Useful for knowing _what_ A overlaps. Restricted by -f and -r." }
  loj: { type: 'boolean?', inputBinding: { position: 2, prefix: "-loj"}, doc: "If no overlaps are found, report a NULL feature for B." }
  wo: { type: 'boolean?', inputBinding: { position: 2, prefix: "-wo"}, doc: "Write the original A and B entries plus the number of base pairs of overlap between the two features. - Overlaps restricted by -f and -r. Only A features with overlap are reported." }
  wao: { type: 'boolean?', inputBinding: { position: 2, prefix: "-wao"}, doc: "Write the original A and B entries plus the number of base pairs of overlap between the two features. Overlapping features restricted by -f and -r. However, A features w/o overlap are also reported with a NULL B feature and overlap = 0." }
  u: { type: 'boolean?', inputBinding: { position: 2, prefix: "-u"}, doc: "Write the original A entry _once_ if _any_ overlaps found in B. - In other words, just report the fact >=1 hit was found. - Overlaps restricted by -f and -r." }
  c: { type: 'boolean?', inputBinding: { position: 2, prefix: "-c"}, doc: "For each entry in A, report the number of overlaps with B. - Reports 0 for A entries that have no overlap with B. - Overlaps restricted by -f, -F, -r, and -s." }
  C: { type: 'boolean?', inputBinding: { position: 2, prefix: "-C"}, doc: "For each entry in A, separately report the number of - overlaps with each B file on a distinct line. - Reports 0 for A entries that have no overlap with B. - Overlaps restricted by -f, -F, -r, and -s." }
  v: { type: 'boolean?', inputBinding: { position: 2, prefix: "-v"}, doc: "Only report those entries in A that have _no overlaps_ with B. - Similar to 'grep -v' (an homage)." }
  ubam: { type: 'boolean?', inputBinding: { position: 2, prefix: "-ubam"}, doc: "Write uncompressed BAM output. Default writes compressed BAM." }
  s: { type: 'boolean?', inputBinding: { position: 2, prefix: "-s"}, doc: "Require same strandedness. That is, only report hits in B that overlap A on the _same_ strand. - By default, overlaps are reported without respect to strand." }
  S: { type: 'boolean?', inputBinding: { position: 2, prefix: "-S"}, doc: "Require different strandedness. That is, only report hits in B that overlap A on the _opposite_ strand. - By default, overlaps are reported without respect to strand." }
  f: { type: 'float?', inputBinding: { position: 2, prefix: "-f"}, doc: "Minimum overlap required as a fraction of A. - Default is 1E-9 (i.e., 1bp). - FLOAT (e.g. 0.50)" }
  F: { type: 'float?', inputBinding: { position: 2, prefix: "-F"}, doc: "Minimum overlap required as a fraction of B. - Default is 1E-9 (i.e., 1bp). - FLOAT (e.g. 0.50)" }
  r: { type: 'boolean?', inputBinding: { position: 2, prefix: "-r"}, doc: "Require that the fraction overlap be reciprocal for A AND B. - In other words, if -f is 0.90 and -r is used, this requires that B overlap 90% of A and A _also_ overlaps 90% of B." }
  e: { type: 'boolean?', inputBinding: { position: 2, prefix: "-e"}, doc: "B is covered. Without -e, both fractions would have to be satisfied." }
  split: { type: 'boolean?', inputBinding: { position: 2, prefix: "-split"}, doc: "Treat 'split' BAM or BED12 entries as distinct BED intervals." }
  g: { type: 'File?', inputBinding: { position: 2, prefix: "-g"}, doc: "Provide a genome file to enforce consistent chromosome sort order across input files. Only applies when used with -sorted option." }
  nonamecheck: { type: 'boolean?', inputBinding: { position: 2, prefix: "-nonamecheck"}, doc: "For sorted data, don't throw an error if the file has different naming conventions for the same chromosome. ex. 'chr1' vs 'chr01'." }
  sorted: { type: 'boolean?', inputBinding: { position: 2, prefix: "-sorted"}, doc: "Use the 'chromsweep' algorithm for sorted (-k1,1 -k2,2n) input." }
  names: { type: 'string[]?', inputBinding: { position: 2, prefix: "-names"}, doc: "When using multiple databases, provide an alias for each that will appear instead of a fileId when also printing the DB record." }
  filenames: { type: 'string[]?', inputBinding: { position: 2, prefix: "-filenames"}, doc: "When using multiple databases, show each complete filename instead of a fileId when also printing the DB record." }
  sortout: { type: 'boolean?', inputBinding: { position: 2, prefix: "-sortout"}, doc: "When using multiple databases, sort the output DB hits for each record." }
  bed: { type: 'boolean?', inputBinding: { position: 2, prefix: "-bed"}, doc: "If using BAM input, write output as BED." }
  header: { type: 'boolean?', inputBinding: { position: 2, prefix: "-header"}, doc: "Print the header from the A file prior to results." }
  nobuf: { type: 'boolean?', inputBinding: { position: 2, prefix: "-nobuf"}, doc: "Disable buffered output. Using this option will cause each line of output to be printed as it is generated, rather than saved in a buffer. This will make printing large output files noticeably slower, but can be useful in conjunction with other software tools and scripts that need to process one line of bedtools output at a time." }
  iobuf: { type: 'string?', inputBinding: { position: 2, prefix: "-iobuf"}, doc: "Specify amount of memory to use for input buffer. Takes an integer argument. Optional suffixes K/M/G supported. Note: currently has no effect with compressed files." }

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
