cwlVersion: v1.2
class: Workflow
id: coyote_bam_stats 
doc: "Small workflow to get TGEN stats from a CRAM/BAM"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_reads: { type: 'File', doc: "BAM/CRAM/SAM file from which to gather stats." }
  indexed_reference_fasta: { type: 'File', doc: "Reference genome fasta file" }
  stats_target_regions: { type: 'File?', doc: "Do stats in these regions only. Tab-delimited file chr,from,to, 1-based, inclusive." }
  input_sample_name: { type: 'string?', doc: "Unique Sample Identifier (ie. Bam spec: RG_SM)" }
  input_library_name: { type: 'string?', doc: "Unique Library Identifier(ie. Bam spec: RG_LB)" }
  input_readgroup_id: { type: 'string?', doc: "Unique Read Group Identifier(ie. Bam spec: RG_ID)" }
  input_readformat:
    type:
      - 'null'
      - type: enum
        name: readformat
        symbols: ["PairedEnd", "SingleEnd"]
    doc: |
      Sequencing Read Format (PairedEnd or SingleEnd)

outputs:
  bamstats:  type: 'File', outputSource: samtools_view_stats/stats }
  base_dist_plot: { type: 'File?', outputSource: coyote_summarize_samstats/base_dist_plot} 
  base_qual_dist_hist_plot: { type: 'File?', outputSource: coyote_summarize_samstats/base_qual_dist_hist_plot }
  base_qual_dist_hist: { type: 'File?', outputSource: coyote_summarize_samstats/base_qual_dist_hist }
  base_qual_yield: { type: 'File?', outputSource: coyote_summarize_samstats/base_qual_yield }
  coverage_hist_plot: { type: 'File?', outputSource: coyote_summarize_samstats/coverage_hist_plot }
  coverage_hist: { type: 'File?', outputSource: coyote_summarize_samstats/coverage_hist }
  coverage_summary: { type: 'File?', outputSource: coyote_summarize_samstats/coverage_summary }
  gc_depth_hist: { type: 'File?', outputSource: coyote_summarize_samstats/gc_depth_hist }
  gc_depth_plot: { type: 'File?', outputSource: coyote_summarize_samstats/gc_depth_plot }
  indel_dist_plot: { type: 'File?', outputSource: coyote_summarize_samstats/indel_dist_plot }
  indel_size_plot: { type: 'File?', outputSource: coyote_summarize_samstats/indel_size_plot }
  insertsize_hist_plot: { type: 'File?', outputSource: coyote_summarize_samstats/insertsize_hist_plot }
  insertsize_hist: { type: 'File?', outputSource: coyote_summarize_samstats/insertsize_hist }
  insertsize_summary: { type: 'File?', outputSource: coyote_summarize_samstats/insertsize_summary }
  mean_base_qual_hist: { type: 'File?', outputSource: coyote_summarize_samstats/mean_base_qual_hist }
  mean_base_qual_plot: { type: 'File?', outputSource: coyote_summarize_samstats/mean_base_qual_plot }
  summary_numbers: { type: 'File?', outputSource: coyote_summarize_samstats/summary_numbers }

steps:
  samtools_view_stats:
    run: ../tools/samtools_view_stats.cwl
    in:
      input_reads: input_reads
      reference_fasta: indexed_reference_fasta 
      target_regions: stats_target_regions 
      output_filename:
        valueFrom: $(inputs.input_reads.nameroot).bamstats.txt
      min_mapq:
        valueFrom: $(20)
      include_header:
        valueFrom: $(1 == 1)
      remove_dups:
        valueFrom: $(1 == 1)
      remove_overlaps:
        valueFrom: $(1 == 1)
      gc_depth:
        valueFrom: $(100)
      filtering_flag:
        valueFrom: "256"
      coverage:
        valueFrom: "1,2500,1"
    out: [stats]

  coyote_summarize_samstats:
    run: ../tools/coyote_summarize_samstats.cwl
    in:
      bam:
        source: input_reads
        valueFrom: $(self.nameroot)
      samtoolsStatsFile: samtools_view_stats/stats 
      sample: input_sample_name 
      library: input_library_name 
      readgroup: input_readgroup_id 
      readformat: input_readformat
    out: [base_dist_plot, base_qual_dist_hist_plot, base_qual_dist_hist, base_qual_yield, coverage_hist_plot, coverage_hist, coverage_summary, gc_depth_hist, gc_depth_plot, indel_dist_plot, indel_size_plot, insertsize_hist_plot, insertsize_hist, insertsize_summary, mean_base_qual_hist, mean_base_qual_plot, summary_numbers]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
