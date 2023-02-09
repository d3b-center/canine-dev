cwlVersion: v1.2
class: Workflow
id: canine_gatk_cnv_module
doc: "Port of Canine GATK CNV Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  # Killswitch
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }], doc: "Reference fasta with FAI and DICT indicies" }
  centromere_regions: { type: 'File', doc: "BED file containing the regions of the centromeres (e.g. CanFam3.1.centromere.nochr.bed)." }
  mappability_track: { type: 'File?', secondaryFiles: [{ pattern: '.tbi', required: false }, { pattern: '.idx', required: false }],  doc: "BED file containing the mappability track (e.g. k100.umap.no_header.bed)." }
  annotation_gtf: { type: 'File', doc: "GTF file to use for segment annotation (e.g. Canis_familiaris.CanFam3.1.98.gtf)" } 

  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the normal sample" }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  sample_type:
    type:
      - type: enum
        name: config_sex
        symbols: ["Exome","Genome"]
    doc: "Is the sample exome or genome"
  config_sex:
    type:
      - type: enum
        name: config_sex
        symbols: ["Female","Male"]
    doc: "Sex of the sample"
  deepvariant_vcf: { type: 'File', secondaryFiles: [{ pattern: ".tbi", required: true }], doc: "VCF.GZ and index containing the PASS variants called by Deepvariant" }

  # Stats and metrics
  bam_stats_tumor: { type: 'File', doc: "The bamstats file generated from the aligned tumor reads" }
  bam_stats_normal: { type: 'File', doc: "The bamstats file generated from the aligned normal reads" }
  sex_check_normal: { type: 'File?', doc: "The sexCheck file generated from the aligned normal reads" }

  # Intervals
  normal_target_intervals: { type: 'File?', doc: "For exome samples, provide the targets file used to align the normal sample reads." }
  tumor_target_intervals: { type: 'File?', doc: "For exome samples, provide the targets file used to align the tumor sample reads." }
  gatk_cnv_primary_contigs_male: { type: 'File?', doc: "For genome samples, provide a file containing the male primary contigs (e.g. Canis_familiaris.CanFam3.1.primary.contigs.male.interval_list)" }
  gatk_cnv_primary_contigs_female: { type: 'File?', doc: "For genome samples, provide a file containing the female primary contigs (e.g. Canis_familiaris.CanFam3.1.primary.contigs.female.interval_list)" }
  
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

outputs:
  gatk_normal_allelic_counts: { type: 'File', outputSource: gatk_collectalleliccounts_normal_snps/output }
  gatk_tumor_allelic_counts: { type: 'File', outputSource: gatk_collectalleliccounts_tumor_snps/output }
  gatk_standardized_cr: { type: 'File', outputSource: gatk_denoisereadcounts/standardized_copy_ratios }
  gatk_denoised_cr: { type: 'File', outputSource: gatk_denoisereadcounts/denoised_copy_ratios }
  gatk_hets_normal: { type: 'File', outputSource: gatk_modelsegments/normal_het_allelic_counts }
  gatk_hets: { type: 'File', outputSource: gatk_modelsegments/het_allelic_counts }
  gatk_model_begin_seg: { type: 'File', outputSource: gatk_modelsegments/modeled_segments_begin }
  gatk_model_begin_cr: { type: 'File', outputSource: gatk_modelsegments/copy_ratio_parameters_begin }
  gatk_model_begin_af: { type: 'File', outputSource:  gatk_modelsegments/allele_fraction_parameters_begin }
  gatk_model_final_seg: { type: 'File', outputSource: gatk_modelsegments/modeled_segments }
  gatk_model_final_cr: { type: 'File', outputSource: gatk_modelsegments/copy_ratio_parameters }
  gatk_model_final_af: { type: 'File', outputSource: gatk_modelsegments/allele_fraction_parameters }
  gatk_cr_seg: { type: 'File', outputSource: gatk_modelsegments/copy_ratio_only_segments }
  gatk_cr_igv_seg: { type: 'File', outputSource: gatk_modelsegments/copy_ratio_legacy_segments }
  gatk_af_igv_seg: { type: 'File', outputSource: gatk_modelsegments/allele_fraction_legacy_segments }
  gatk_called_seg: { type: 'File', outputSource: gatk_callcopyratiosegments/called_segments}
  gatk_called_igv_seg: { type: 'File', outputSource: gatk_callcopyratiosegments/called_legacy_segments }
  denoised_cr_gender_corrected: { type: 'File', outputSource: coyote_omega_awk/denoisedcr_corr}
  model_final_seg_gender_corrected: { type: 'File', outputSource: coyote_omega_awk/modelfinal_corr }
  cna_plots: { type: 'File[]', outputSource: coyote_plotCNVplus/plots }
  recentered_cr_seg: { type: 'File', outputSource: coyote_plotCNVplus/recentered_seg }
  recentered_cr_seg_vcf: { type: 'File', outputSource: coyote_annot_seg/output }
  thred_hrd_scores: { type: 'File', outputSource: thred/hrd_scores }
  thred_hrd_flt_segments: { type: 'File', outputSource: thred/hrd_flt_segments }
  thred_hrd_ori_segments: { type: 'File', outputSource: thred/hrd_ori_segments }
  thred_excluded90_hrd_excluded_segments: { type: 'File', outputSource: thred/excluded90_hrd_excluded_segments }
  thred_hrd_captured_genome_territory: { type: 'File', outputSource: thred/hrd_captured_genome_territory }
  thred_original_segments_karyoplot_1: { type: 'File?', outputSource: thred/original_segments_karyoplot_1 }
  thred_original_segments_karyoplot_2: { type: 'File?', outputSource: thred/original_segments_karyoplot_2 }
  thred_segments_filtered_karyoplot_1: { type: 'File?', outputSource: thred/segments_filtered_karyoplot_1 }
  thred_segments_filtered_karyoplot_2: { type: 'File?', outputSource: thred/segments_filtered_karyoplot_2 }
  thred_segments_excluded_karyoplot_1: { type: 'File?', outputSource: thred/segments_excluded_karyoplot_1 }
  thred_segments_excluded_karyoplot_2: { type: 'File?', outputSource: thred/segments_excluded_karyoplot_2 }

steps:
  clt_grep_cut_sex:
    run: ../tools/clt_grep_cut.cwl
    when: $(inputs.infile != null)
    in:
      infile: sex_check_normal
      grep_regex: normal_sample_name
      cut_field:
        source: disable_workflow # Hiding this here because I hate cavatica
        valueFrom: $(20)
    out: [output]

  expr_sex_guess:
    run: ../tools/expr_sex_guess.cwl
    in:
      config_sex: config_sex
      sex_check_sex: clt_grep_cut_sex/output
    out: [output]

  gatk_intervallisttools:
    run: ../tools/gatk_intervallisttools.cwl
    when: $(inputs.enable_tool == "Exome")
    in:
      enable_tool:
        source: sample_type 
        valueFrom: $(self)
      input_intervals:
        source: [normal_target_intervals, tumor_target_intervals]
      action:
        valueFrom: "INTERSECT"
      output_prefix:
        valueFrom: "pair_intersect"
    out: [intervals, count_output]

  grep_drop_y_chrom:
    run: ../tools/grep.cwl
    when: $(inputs.infile != null && inputs.enable_tool == "Female")
    in:
      enable_tool: expr_sex_guess/output
      infile:
        source: gatk_intervallisttools/intervals
        valueFrom: $(self[0])
      outfile:
        valueFrom: "pair_intersect.interval_list"
      regexp:
        valueFrom: "Y"
      invert_match:
        valueFrom: $(1 == 1)
    out: [output]

  coyote_awk_bamstats:
    run:  ../tools/coyote_awk_bamstats.cwl
    in:
      tumor_bam_stats: bam_stats_tumor
      normal_bam_stats: bam_stats_normal
    out: [ max_length, normal_average_depth, tumor_average_depth ]

  coyote_awk_interval:
    run:  ../tools/coyote_awk_interval.cwl
    when: $(inputs.enable_tool == "Exome")
    in:
      enable_tool:
        source: sample_type 
        valueFrom: $(self)
      interval_list:
        source: [grep_drop_y_chrom/output, gatk_intervallisttools/intervals]
        valueFrom: |
          $(self[0] != null ? self[0] : self[1][0])
      max_length: coyote_awk_bamstats/max_length
    out: [min_interval]

  expr_gatk_cnv_variables:
    run: ../tools/expr_gatk_cnv_variables.cwl
    in:
      exome: 
        source: sample_type
        valueFrom: |
          $(self == "Exome")
      bamstats_max_length: coyote_awk_bamstats/max_length
      intervals_min_interval: coyote_awk_interval/min_interval
      normal_average_depth: coyote_awk_bamstats/normal_average_depth
      tumor_average_depth: coyote_awk_bamstats/tumor_average_depth
    out: [ bin_length, padding, exp_1x_counts, min_vaf, max_vaf, min_dp ]

  clt_pick_intervals:
    run: ../tools/clt_pick_intervals.cwl
    in:
      exome_male:
        source: gatk_intervallisttools/intervals
        valueFrom: |
          $(self != null ? self[0] : self)
      exome_female: grep_drop_y_chrom/output
      genome_male: gatk_cnv_primary_contigs_male
      genome_female: gatk_cnv_primary_contigs_female
      exome:
        source: sample_type
        valueFrom: |
          $(self == "Exome")
      female:
        source: expr_sex_guess/output
        valueFrom: $(self == "Female")
    out: [output]

  gatk_preprocessintervals:
    run: ../tools/gatk_preprocessintervals.cwl
    in:
      input_interval_list: clt_pick_intervals/output
      bin_length: expr_gatk_cnv_variables/bin_length
      padding: expr_gatk_cnv_variables/padding
      reference: indexed_reference_fasta
      output_prefix:
        valueFrom: "preprocessed"
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
    out: [output]

  bcftools_view_index_deepvariant:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: deepvariant_vcf
      genotype:
        valueFrom: "het"
      targets:
        valueFrom: "^X:340578-6642728"
      exclude:
        source: [ expr_gatk_cnv_variables/min_vaf, expr_gatk_cnv_variables/max_vaf , expr_gatk_cnv_variables/min_dp ]
        valueFrom: |
          VAF<$(self[0]) | VAF>$(self[1]) | DP<$(self[2])
      exclude_variant_types:
        valueFrom: "indels,mnps,ref,bnd,other"
      output_filename:
        valueFrom: "tmp.preFilt.snps.vcf"
      output_type:
        valueFrom: "v"
    out: [output]

  bcftools_view_index_prefilt_snps:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: bcftools_view_index_deepvariant/output
      targets_file_exclude: centromere_regions
      output_filename:
        valueFrom: "tmp.snps.vcf"
      output_type:
        valueFrom: "v"
    out: [output]

  gatk_collectreadcounts_normal_preprocessed:
    run: ../tools/gatk_collectreadcounts.cwl
    in:
      input_aligned_reads: input_normal_reads
      input_interval_list: gatk_preprocessintervals/output
      reference: indexed_reference_fasta
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
      read_filter:
        valueFrom: $(["FirstOfPairReadFilter"])
      output_prefix:
        valueFrom: "normal"
    out: [output]

  gatk_annotateintervals_preprocessed:
    run: ../tools/gatk_annotateintervals.cwl
    in:
      do_explicit_gc_correction:
        valueFrom: $(1 == 1)
      mappability_track: mappability_track 
      input_interval_list: gatk_preprocessintervals/output
      reference: indexed_reference_fasta
      output_prefix:
        valueFrom: "PreFilter_anno_preprocessed"
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
    out: [output]

  gatk_filterintervals_preprocessed:
    run: ../tools/gatk_filterintervals.cwl
    in:
      input_intervals_list: gatk_preprocessintervals/output
      annotated_intervals: gatk_annotateintervals_preprocessed/output
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
      minimum_gc_content:
        valueFrom: $(0.1)
      maximum_gc_content:
        valueFrom: $(0.9)
      minimum_mappability:
        valueFrom: $(0.9)
      maximum_mappability:
        valueFrom: $(1.0)
      output_prefix:
        valueFrom: "preprocessed_filt_map"
    out: [output]

  gatk_filterintervals_preprocessed_filt_map:
    run: ../tools/gatk_filterintervals.cwl
    in:
      input_intervals_list: gatk_filterintervals_preprocessed/output
      input_exclude_intervals_list: centromere_regions
      input_read_counts:
        source: gatk_collectreadcounts_normal_preprocessed/output
        valueFrom: $([self])
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
      low_count_filter_count_threshold: expr_gatk_cnv_variables/exp_1x_counts
      low_count_filter_percentage_of_samples:
        valueFrom: $(0)
      extreme_count_filter_minimum_percentile:
        valueFrom: $(0)
      extreme_count_filter_maximum_percentile:
        valueFrom: $(100)
      extreme_count_filter_percentage_of_samples:
        valueFrom: $(100)
      output_prefix:
        valueFrom: "preprocessed_filt"
    out: [output]

  gatk_annotateintervals_preprocessed_filt:
    run: ../tools/gatk_annotateintervals.cwl
    in:
      do_explicit_gc_correction:
        valueFrom: $(1 == 1)
      input_interval_list: gatk_filterintervals_preprocessed_filt_map/output
      reference: indexed_reference_fasta
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
      output_prefix:
        valueFrom: "anno_preprocessed"
    out: [output]

  gatk_collectreadcounts_normal_preprocessed_filt:
    run: ../tools/gatk_collectreadcounts.cwl
    in:
      input_aligned_reads: input_normal_reads
      input_interval_list: gatk_filterintervals_preprocessed_filt_map/output
      reference: indexed_reference_fasta
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
      read_filter:
        valueFrom: $(["FirstOfPairReadFilter"])
      output_prefix:
        valueFrom: "normal_preprocessed_filt"
    out: [output]

  gatk_collectalleliccounts_normal_snps:
    run: ../tools/gatk_collectalleliccounts.cwl
    in:
      input_aligned_reads: input_normal_reads
      reference: indexed_reference_fasta
      input_interval_list: bcftools_view_index_prefilt_snps/output
      output_prefix: output_basename
    out: [output]

  gatk_collectreadcounts_tumor_preprocessed_filt:
    run: ../tools/gatk_collectreadcounts.cwl
    in:
      input_aligned_reads: input_tumor_reads
      input_interval_list: gatk_filterintervals_preprocessed_filt_map/output
      reference: indexed_reference_fasta
      interval_merging_rule:
        valueFrom: "OVERLAPPING_ONLY"
      read_filter:
        valueFrom: $(["FirstOfPairReadFilter"])
      output_prefix:
        valueFrom: "tumor_preprocessed_filt"
    out: [output]

  gatk_collectalleliccounts_tumor_snps:
    run: ../tools/gatk_collectalleliccounts.cwl
    in:
      input_aligned_reads: input_tumor_reads
      reference: indexed_reference_fasta
      input_interval_list: bcftools_view_index_prefilt_snps/output
      output_prefix: output_basename
    out: [output]

  gatk_createreadcountpanelofnormals:
    run: ../tools/gatk_createreadcountpanelofnormals.cwl
    in:
      input_counts:
        source: gatk_collectreadcounts_normal_preprocessed_filt/output
        valueFrom: $([self])
      input_annotated_intervals: gatk_annotateintervals_preprocessed_filt/output
      minimum_interval_median_percentile:
        valueFrom: $(0.0)
    out: [output]

  gatk_denoisereadcounts:
    run: ../tools/gatk_denoisereadcounts.cwl
    in:
      read_counts: gatk_collectreadcounts_tumor_preprocessed_filt/output
      count_panel_of_normals: gatk_createreadcountpanelofnormals/output
      output_prefix: output_basename
    out: [denoised_copy_ratios, standardized_copy_ratios]

  gatk_modelsegments:
    run: ../tools/gatk_modelsegments.cwl
    in:
      allelic_counts: gatk_collectalleliccounts_tumor_snps/output
      denoised_copy_ratios: gatk_denoisereadcounts/denoised_copy_ratios
      normal_allelic_counts: gatk_collectalleliccounts_normal_snps/output
      kernel_scaling_allele_fraction:
        valueFrom: $(0.0)
      kernel_variance_allele_fraction:
        valueFrom: $(0.0)
      minimum_total_allele_count_normal: expr_gatk_cnv_variables/min_dp
      number_of_changepoints_penalty_factor:
        valueFrom: $(0.05)
      number_of_smoothing_iterations_per_fit:
        valueFrom: $(1)
      smoothing_credible_interval_threshold_allele_fraction:
        valueFrom: $(3.5)
      smoothing_credible_interval_threshold_copy_ratio:
        valueFrom: $(3.5)
      window_size:
        valueFrom: $([4,8,16,32,64,128,256])
      output_prefix: output_basename
    out: [ allele_fraction_legacy_segments, allele_fraction_parameters, allele_fraction_parameters_begin, copy_ratio_legacy_segments, copy_ratio_only_segments, copy_ratio_parameters, copy_ratio_parameters_begin, het_allelic_counts, modeled_segments, modeled_segments_begin, normal_het_allelic_counts ]

  gatk_callcopyratiosegments:
    run: ../tools/gatk_callcopyratiosegments.cwl
    in:
      copy_ratio_segments: gatk_modelsegments/copy_ratio_only_segments
      output_prefix: output_basename
    out: [called_legacy_segments, called_segments]

  coyote_omega_awk:
    run: ../tools/coyote_omega_awk.cwl
    in:
      input_denoised_cr: gatk_denoisereadcounts/denoised_copy_ratios 
      input_model_final: gatk_modelsegments/modeled_segments 
      input_centromere: centromere_regions
      output_basename: output_basename 
      male:
        source: expr_sex_guess/output
        valueFrom: $(self == "Male")
    out: [ modelfinal_corr, denoisedcr_corr ]
      
  coyote_seg_extend:
    run: ../tools/coyote_seg_extend.cwl
    in:
      input_centromere_bed: centromere_regions
      input_seg: coyote_omega_awk/modelfinal_corr  
    out: [output]

  coyote_plotCNVplus:
    run: ../tools/coyote_plotCNVplus.cwl
    in:
      sample_name: tumor_sample_name
      output_basename: output_basename
      denoised_tsv: coyote_omega_awk/denoisedcr_corr 
      allelic_tsv: gatk_modelsegments/het_allelic_counts
      modeled_seg: coyote_seg_extend/output
      hetDPfilter:
        valueFrom: $(1)
      hetAFlow:
        valueFrom: $(0.45)
      hetAFhigh:
        valueFrom: $(0.55)
      hetMAFposteriorOffset:
        valueFrom: $(0.01)
      lowerCNvalidatePeakOffset:
        valueFrom: $(0.125)
      UpperCNvalidatePeakOffset:
        valueFrom: $(0.125)
      lowerCNcenteringPeakOffset:
        valueFrom: $(0.125)
      UpperCNcenteringPeakOffset:
        valueFrom: $(0.125)
      re_center_CNA:
        valueFrom: "TRUE"
      contig_names_string:
        valueFrom: "1CONTIG_DELIMITER2CONTIG_DELIMITER3CONTIG_DELIMITER4CONTIG_DELIMITER5CONTIG_DELIMITER6CONTIG_DELIMITER7CONTIG_DELIMITER8CONTIG_DELIMITER9CONTIG_DELIMITER10CONTIG_DELIMITER11CONTIG_DELIMITER12CONTIG_DELIMITER13CONTIG_DELIMITER14CONTIG_DELIMITER15CONTIG_DELIMITER16CONTIG_DELIMITER17CONTIG_DELIMITER18CONTIG_DELIMITER19CONTIG_DELIMITER20CONTIG_DELIMITER21CONTIG_DELIMITER22CONTIG_DELIMITER23CONTIG_DELIMITER24CONTIG_DELIMITER25CONTIG_DELIMITER26CONTIG_DELIMITER27CONTIG_DELIMITER28CONTIG_DELIMITER29CONTIG_DELIMITER30CONTIG_DELIMITER31CONTIG_DELIMITER32CONTIG_DELIMITER33CONTIG_DELIMITER34CONTIG_DELIMITER35CONTIG_DELIMITER36CONTIG_DELIMITER37CONTIG_DELIMITER38CONTIG_DELIMITERX"
      contig_lengths_string:
        valueFrom: "122678785CONTIG_DELIMITER85426708CONTIG_DELIMITER91889043CONTIG_DELIMITER88276631CONTIG_DELIMITER88915250CONTIG_DELIMITER77573801CONTIG_DELIMITER80974532CONTIG_DELIMITER74330416CONTIG_DELIMITER61074082CONTIG_DELIMITER69331447CONTIG_DELIMITER74389097CONTIG_DELIMITER72498081CONTIG_DELIMITER63241923CONTIG_DELIMITER60966679CONTIG_DELIMITER64190966CONTIG_DELIMITER59632846CONTIG_DELIMITER64289059CONTIG_DELIMITER55844845CONTIG_DELIMITER53741614CONTIG_DELIMITER58134056CONTIG_DELIMITER50858623CONTIG_DELIMITER61439934CONTIG_DELIMITER52294480CONTIG_DELIMITER47698779CONTIG_DELIMITER51628933CONTIG_DELIMITER38964690CONTIG_DELIMITER45876710CONTIG_DELIMITER41182112CONTIG_DELIMITER41845238CONTIG_DELIMITER40214260CONTIG_DELIMITER39895921CONTIG_DELIMITER38810281CONTIG_DELIMITER31377067CONTIG_DELIMITER42124431CONTIG_DELIMITER26524999CONTIG_DELIMITER30810995CONTIG_DELIMITER30902991CONTIG_DELIMITER23914537CONTIG_DELIMITER123869142"
    out: [plots, recentered_seg]

  coyote_annot_seg:
    run: ../tools/coyote_annot_seg.cwl
    in:
      input_annotation_gtf: annotation_gtf
      input_file: coyote_plotCNVplus/recentered_seg
      amp_threshold:
        valueFrom: $(0.58)
      del_threshold:
        valueFrom: $(-0.99)
    out: [output]

  sed_centromere:
    run: ../tools/sed.cwl
    in:
      infile: centromere_regions 
      outfile:
        valueFrom: "genomic_regions.bed"
      expression:
        valueFrom: |
          s/$/\tcentromere/
    out: [output]

  thred:
    run: ../tools/thred.cwl
    in:
      seg: coyote_plotCNVplus/recentered_seg 
      genomic_regions: sed_centromere/output
      outfile: output_basename
      th_log2r:
        valueFrom: $(-0.1613)
      minsize:
        valueFrom: $(1000000)
      th_pct_overlapping:
        valueFrom: $(0.90)
      sample: output_basename
      exclude_contigs:
        valueFrom: "X"
      plots:
        valueFrom: $(1 == 1)
    out: [ hrd_scores, hrd_flt_segments, hrd_ori_segments, excluded90_hrd_excluded_segments, hrd_captured_genome_territory, original_segments_karyoplot_1, original_segments_karyoplot_2, segments_filtered_karyoplot_1, segments_filtered_karyoplot_2, segments_excluded_karyoplot_1, segments_excluded_karyoplot_2 ]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
