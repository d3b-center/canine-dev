cwlVersion: v1.2
class: Workflow
id: canine_vcfmerger2_module
doc: "Port of Canine vcfmerger2 Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: SubworkflowFeatureRequirement

inputs:
  # Killswitches
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }
  disable_bcftools: { type: 'boolean?', doc: "Set to true to disable bcftools GCA annotation." }
  disable_tumor_only_var_filt: { type: 'boolean?', doc: "Set to true to disable tumor only variant filtering." }
  disable_snpeff: { type: 'boolean?', doc: "Set to true to disable SnpEff annotation." }
  disable_vep: { type: 'boolean?', doc: "Set to true to disable VEP annotation." }
  disable_mutation_burden: { type: 'boolean?', doc: "Set to true to disable Mutation Burden metrics collection." }
  disable_tucon: { type: 'boolean?', doc: "Set to true to disable Tucon metics collection." }
  disable_msisensor: { type: 'boolean?', doc: "Set to true to disable Msisensor metrics collection." }
  disable_sigprofiler: { type: 'boolean?', doc: "Set to true to disable Sigprofiler metrics collection." }

  # VCFMerger
  input_vcfs: { type: 'File[]', doc: "VCF files to merge." }
  input_toolnames: { type: 'string[]', doc: "Corresponding toolnames for each VCF." }
  tool_precidence: { type: 'string[]?', doc: "The order in which the VCFs will be ranked on precedence. Every tool from this list must be found in the input_toolnames." }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [ { pattern: '.fai', required: true }, { pattern: '^.dict', required: true } ], doc: "Reference genome fasta file with associated FAI and DICT indexes" }
  input_tumor_bam: { type: 'File', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from tumor sample." }
  tumor_sample_name: { type: 'string', doc: "Name of the tumor sample as presented in the read group SM field." }
  normal_sample_name: { type: 'string', doc: "Name of the normal sample as presented in the read group SM field." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }

  # Matched RNA
  star_bam_final: { type: 'File?', doc: "STAR BAM final" }
  rna_samplename: { type: 'string?', doc: "Name of RNA sample associated with tumor pair" }

  # Annotation
  input_gca_annotations_vcf: { type: 'File?', secondaryFiles: [ { pattern: '.tbi', required: true } ], doc: "VCF containing EVA GCA annotations: GCA_000002285.2_current_ids_renamed.vcf.gz" }
  snpeff_config: { type: 'File?', doc: "SnpEff config file" }
  snpeff_database: { type: 'string?', doc: "Name of SnpEff database information" }
  snpeff_tar: { type: 'File?', doc: "TAR containing SnpEff config file and cache information" }
  snpeff_cachename: { type: 'string?', doc: "Name of snpeff cache directory contained in snpeff_tar" }
  vep_tar: { type: 'File?', doc: "TAR containing VEP cache information" }

  # Collect Somatic Metrics
  input_normal_bam: { type: 'File?', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from normal sample." }
  tumor_library_name: { type: 'string?', doc: "Library name as denoted in the tumor BAM read group header." }
  total_callers: { type: 'int?', doc: "Total callers run to generate this VCF." }
  ns_effects: { type: 'string[]?', doc: "List of NS effects" }
  canonical_cds_bed_snpeff: { type: 'File?', doc: "BED file contatining Canine canonical CDS intervals for SnpEff." }
  canonical_cds_bed_vep: { type: 'File?', doc: "BED file contatining Canine canonical CDS intervals for VEP." }
  msisensor_reference: { type: 'File?', doc: "MSIsensor Pro reference file for detecting homopolymers and microsatellites" }
  exome: { type: 'boolean?', doc: "Set to true if sample is from an exome." }
  exome_capture_kit_bed: { type: 'File?', doc: "BED file contatining the capture kit intervals used to generate this sample." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  vcfmerger_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to vcfmerger2." }
  vcfmerger_cpu: { type: 'int?', doc: "Number of CPUs to allocate to vcfmerger2." }
  prep_vcf_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to prep_vcf_somatic.sh." }
  prep_vcf_cpu: { type: 'int?', doc: "Number of CPUs to allocate to prep_vcf_somatic.sh." }
  freebayes_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Freebayes." }
  freebayes_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Freebayes." }
  snpeff_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SNPeff." }
  snpeff_cpu: { type: 'int?', doc: "Number of CPUs to allocate to SNPeff." }
  vep_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to VEP." }
  vep_cpu: { type: 'int?', doc: "Number of CPUs to allocate to VEP." }
  bedtools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BEDtools." }
  bedtools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BEDtools." }
  tmb_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Coyote Tumor Mutation Burden script." }
  tmb_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Coyote Tumor Mutation Burden script." }
  samtools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SAMtools." }
  samtools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to SAMtools." }
  msisensor_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to msisensor." }
  msisensor_cpu: { type: 'int?', doc: "Number of CPUs to allocate to msisensor." }
  sigprofiler_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sigprofiler." }
  sigprofiler_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sigprofiler." }

outputs:
  vcfmerger_vcf: { type: 'File', outputSource: expr_pickvalue_workaround/output }
  vcfmerger_vcf_stats: { type: 'File', outputSource: bcftools_stats/stats }
  vcfmerger_venns: { type: 'Directory[]?', outputSource: vcfmerger2/venns }
  bcftools_vcf: { type: 'File?', outputSource: canine_annotation_module/bcftools_vcf }
  tumor_only_vcf: { type: 'File?', outputSource: canine_annotation_module/tumor_only_vcf }
  snpeff_all_vcf: { type: 'File?', outputSource: canine_annotation_module/snpeff_all_vcf }
  snpeff_canon_vcf: { type: 'File?', outputSource: canine_annotation_module/snpeff_canon_vcf }
  vep_all_vcf: { type: 'File?', outputSource: canine_annotation_module/vep_all_vcf }
  vep_all_warnings: { type: 'File?', outputSource: canine_annotation_module/vep_all_warnings }
  vep_con_vcf: { type: 'File?', outputSource: canine_annotation_module/vep_con_vcf }
  vep_con_warnings: { type: 'File?', outputSource: canine_annotation_module/vep_con_warnings }
  msisensor_metrics: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/msisensor_metrics }
  mutation_burdern_json_snpeff: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/mutation_burdern_json_snpeff }
  mutation_burdern_txt_snpeff: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/mutation_burdern_txt_snpeff }
  mutation_burdern_json_vep: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/mutation_burdern_json_vep }
  mutation_burdern_txt_vep: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/mutation_burdern_txt_vep }
  tucon_snpeff: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/tucon_snpeff }
  tucon_vep: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/tucon_vep }
  sigprofiler_dbs_activities: { type: 'Directory?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_dbs_activities }
  sigprofiler_dbs_signatures: { type: 'Directory?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_dbs_signatures }
  sigprofiler_id_activities: { type: 'Directory?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_id_activities }
  sigprofiler_id_signatures: { type: 'Directory?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_id_signatures }
  sigprofiler_sbs_activities: { type: 'Directory?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_sbs_activities }
  sigprofiler_sbs_signatures: { type: 'Directory?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_sbs_signatures }
  sigprofiler_extraneous_results: { type: 'File?', outputSource: canine_collect_somatic_metrics_module/sigprofiler_extraneous_results }

steps:
  prep_vcf_somatic:
    run: ../tools/vcfmerger2_prep_vcf_somatic.cwl
    scatter: [vcf, toolname]
    scatterMethod: dotproduct
    in:
      vcf: input_vcfs
      toolname: input_toolnames
      ref_genome: indexed_reference_fasta
      prepped_vcf_outfilename:
        source: disable_workflow # Sinking this someplace it will do nothing to circumvent graph not connected cavatica error
        valueFrom: $(inputs.toolname).prepz.vcf
      normal_sname: normal_sample_name
      tumor_sname: tumor_sample_name
      bam: input_tumor_bam
      cpu: prep_vcf_cpu
      ram: prep_vcf_ram
    out: [output]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    scatter: [input_vcf]
    in:
      input_vcf: prep_vcf_somatic/output
      output_filename:
        valueFrom: $(inputs.input_vcf.basename.split('.')[0]).filt.vcf
      exclude:
        valueFrom: |
          FMT/DP<10 | FMT/AR[0]>=0.02 | FMT/AR[1]<0.05
      tool_name:
        valueFrom: "vcfmerger2"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  vcfmerger2:
    run: ../tools/vcfmerger2.cwl
    in:
      vcfs: bcftools_filter_index/output
      toolnames: input_toolnames
      precedence: tool_precidence
      refgenome: indexed_reference_fasta
      dict:
        valueFrom: |
          $(inputs.refgenome.secondaryFiles.filter(function(e) { return e.nameext == '.dict' })[0])
      merged_vcf_outfilename:
        source: output_basename
        valueFrom: $(self).merged.vcf
      normal_sname: normal_sample_name
      tumor_sname: tumor_sample_name
      do_venn:
        valueFrom: $(1 == 1)
      skip_prep_vcfs:
        valueFrom: $(1 == 1)
      cpu: vcfmerger_cpu
      ram: vcfmerger_ram
    out: [vcf, vcfgz, venns]

  canine_add_matched_rna:
    run: ../subworkflows/canine_add_matched_rna.cwl
    when: $(inputs.star_bam_final != null && inputs.rna_samplename != null)
    in:
      reference_dict:
        valueFrom: |
          $(inputs.refgenome.secondaryFiles.filter(function(e) { return e.nameext == '.dict' })[0])
      reference_fasta: indexed_reference_fasta
      input_vcf: vcfmerger2/vcf
      star_bam_final: star_bam_final
      output_filename:
        source: output_basename
        valueFrom: $(self).merged.vcf.gz
      rna_samplename: rna_samplename
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      freebayes_ram: freebayes_ram
      freebayes_cpu: freebayes_cpu
    out: [matched_rna_vcf]

  canine_add_rna_header_to_vcf_module:
    run: ../subworkflows/canine_add_rna_header_to_vcf_module.cwl
    in:
      input_vcf: vcfmerger2/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).merged.vcf.gz
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
    out: [rna_headered_vcf]

  expr_pickvalue_workaround:
    run: ../tools/expr_pickvalue_workaround.cwl
    in:
      input_file:
        source: [canine_add_matched_rna/matched_rna_vcf, canine_add_rna_header_to_vcf_module/rna_headered_vcf]
        pickValue: first_non_null
    out: [output]

  bcftools_stats:
    run: ../tools/bcftools_stats.cwl
    in:
      input_vcf: expr_pickvalue_workaround/output
      output_filename:
        source: output_basename
        valueFrom: $(self).merged.stats.txt
    out: [stats]

  canine_annotation_module:
    run: ../subworkflows/canine_annotation_module.cwl
    in:
      input_vcf: expr_pickvalue_workaround/output
      input_gca_annotations_vcf: input_gca_annotations_vcf
      output_basename:
        source: output_basename
        valueFrom: $(self).merged
      snpeff_config: snpeff_config
      snpeff_database: snpeff_database
      snpeff_tar: snpeff_tar
      snpeff_cachename: snpeff_cachename
      vep_tar: vep_tar
      reference_fasta: indexed_reference_fasta
      disable_bcftools: disable_bcftools
      disable_tumor_only_var_filt: disable_tumor_only_var_filt
      disable_snpeff: disable_snpeff
      disable_vep: disable_vep
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      snpeff_ram: snpeff_ram
      snpeff_cpu: snpeff_cpu
      vep_ram: vep_ram
      vep_cpu: vep_cpu
    out: [bcftools_vcf, tumor_only_vcf, snpeff_all_vcf, snpeff_canon_vcf, vep_all_vcf, vep_all_warnings, vep_con_vcf, vep_con_warnings]

  canine_collect_somatic_metrics_module:
    run: ../subworkflows/canine_collect_somatic_metrics_module.cwl
    in:
      input_merged_vcf: expr_pickvalue_workaround/output
      input_snpeff_can_vcf: canine_annotation_module/snpeff_canon_vcf
      input_snpeff_full_vcf: canine_annotation_module/snpeff_all_vcf
      input_vep_pick_vcf: canine_annotation_module/vep_con_vcf
      input_vep_full_vcf: canine_annotation_module/vep_all_vcf
      input_tumor_bam: input_tumor_bam
      input_normal_bam: input_normal_bam
      exome: exome
      exome_capture_kit_bed: exome_capture_kit_bed
      sample_name: tumor_sample_name
      library_name: tumor_library_name
      output_basename: output_basename
      total_callers: total_callers
      ns_effects: ns_effects
      canonical_cds_bed_snpeff: canonical_cds_bed_snpeff
      canonical_cds_bed_vep: canonical_cds_bed_vep
      msisensor_reference: msisensor_reference
      disable_mutation_burden: disable_mutation_burden
      disable_tucon: disable_tucon
      disable_msisensor: disable_msisensor
      disable_sigprofiler: disable_sigprofiler
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      bedtools_ram: bedtools_ram
      bedtools_cpu: bedtools_cpu
      tmb_ram: tmb_ram
      tmb_cpu: tmb_cpu
      samtools_ram: samtools_ram
      samtools_cpu: samtools_cpu
      msisensor_ram: msisensor_ram
      msisensor_cpu: msisensor_cpu
      sigprofiler_ram: sigprofiler_ram
      sigprofiler_cpu: sigprofiler_cpu
    out: [mutation_burdern_txt_snpeff, mutation_burdern_json_snpeff, tucon_snpeff, mutation_burdern_txt_vep, mutation_burdern_json_vep, tucon_vep, msisensor_metrics, sigprofiler_dbs_activities, sigprofiler_dbs_signatures, sigprofiler_id_activities, sigprofiler_id_signatures, sigprofiler_sbs_activities, sigprofiler_sbs_signatures, sigprofiler_extraneous_results]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
