cwlVersion: v1.2
class: CommandLineTool
id: summarize_samstats
doc: "Summarize samstats"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/r-util:3.6.1'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: summarize_samstats_8c45d63.R
      writable: false
      entry:
        $include: ../scripts/summarize_samstats_8c45d63.R
baseCommand: [Rscript, summarize_samstats_8c45d63.R]
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  bam: { type: 'string?', inputBinding: { position: 2, prefix: "--bam"}, doc: "BAM filename (For Graph Title)" }
  samtoolsStatsFile: { type: 'File?', inputBinding: { position: 2, prefix: "--samtoolsStatsFile"}, doc: "samtools stats summary numbers table" }
  samtoolsDuplicatesFile: { type: 'File?', inputBinding: { position: 2, prefix: "--samtoolsDuplicatesFile"}, doc: "samtools markdup stats table" }
  sample: { type: 'string?', inputBinding: { position: 2, prefix: "--sample"}, doc: "Unique Sample Identifier (ie. Bam spec: RG_SM)" }
  library: { type: 'string?', inputBinding: { position: 2, prefix: "--library"}, doc: "Unique Library Identifier(ie. Bam spec: RG_LB)" }
  readgroup: { type: 'string?', inputBinding: { position: 2, prefix: "--readgroup"}, doc: "Unique Read Group Identifier(ie. Bam spec: RG_ID)" }
  readformat:
    type:
      - 'null'
      - type: enum
        name: readformat
        symbols: ["PairedEnd", "SingleEnd"]
    inputBinding:
      prefix: "--readformat"
      position: 2
    doc: |
      Sequencing Read Format (PairedEnd or SingleEnd)

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."
outputs:
  base_dist_plot:
    type: 'File?'
    outputBinding:
      glob: "*baseDistribution_linePlot.png"
  base_qual_dist_hist_plot:
    type: 'File?'
    outputBinding:
      glob: "*baseQualityDistribution_histogram.png"
  base_qual_dist_hist:
    type: 'File?'
    outputBinding:
      glob: "*baseQualityDistribution_histogram.tsv"
  base_qual_yield:
    type: 'File?'
    outputBinding:
      glob: "*baseQualityYield_summary.tsv"
  coverage_hist_plot:
    type: 'File?'
    outputBinding:
      glob: "*coverage_histogram.png"
  coverage_hist:
    type: 'File?'
    outputBinding:
      glob: "*coverage_histogram.tsv"
  coverage_summary:
    type: 'File?'
    outputBinding:
      glob: "*coverage_summary.tsv"
  gc_depth_hist:
    type: 'File?'
    outputBinding:
      glob: "*gcDepth_histogram.tsv"
  gc_depth_plot:
    type: 'File?'
    outputBinding:
      glob: "*gcDepth_plot.png"
  indel_dist_plot:
    type: 'File?'
    outputBinding:
      glob: "*indelDistByCycle_linePlot.png"
  indel_size_plot:
    type: 'File?'
    outputBinding:
      glob: "*indelSize_linePlot.png"
  insertsize_hist_plot:
    type: 'File?'
    outputBinding:
      glob: "*insertSize_histogram.png"
  insertsize_hist:
    type: 'File?'
    outputBinding:
      glob: "*insertSize_histogram.tsv"
  insertsize_summary:
    type: 'File?'
    outputBinding:
      glob: "*insertSize_summary.tsv"
  mean_base_qual_hist:
    type: 'File?'
    outputBinding:
      glob: "*meanBaseQualityByCycle_histogram.tsv"
  mean_base_qual_plot:
    type: 'File?'
    outputBinding:
      glob: "*meanBaseQualityByCycle_lineplot.png"
  summary_numbers:
    type: 'File?'
    outputBinding:
      glob: "*summaryNumbers_summary.tsv"
