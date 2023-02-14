cwlVersion: v1.2
class: Workflow
id: canine_collect_somatic_metrics_module
doc: "Port of Canine Collect Somatic Metrics Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: SubworkflowFeatureRequirement

inputs:
  input_merged_vcf: { type: 'File', doc: "The unannotated merged VCF." }
  input_snpeff_can_vcf: { type: 'File?', doc: "Canonical VCF file, annotated by SnpEff, from which to collect metrics." }
  input_snpeff_full_vcf: { type: 'File?', doc: "Full VCF file, annotated by SnpEff, from which to collect metrics." }
  input_vep_pick_vcf: { type: 'File?', doc: "Pick VCF file, annotated by VEP, from which to collect metrics." }
  input_vep_full_vcf: { type: 'File?', doc: "Full VCF file, annotated by VEP, from which to collect metrics." }

  input_tumor_bam: { type: 'File?', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from tumor sample." }
  input_normal_bam: { type: 'File?', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from normal sample." }
  exome_capture_kit_bed: { type: 'File?', doc: "BED file contatining the capture kit intervals used to generate this sample." }
  sample_name: { type: 'string?', doc: "Sample name as denoted in the tumor BAM read group header." }
  library_name: { type: 'string?', doc: "Library name as denoted in the tumor BAM read group header." }
  output_basename: { type: 'string?', doc: "String to use as base for output filenames." }

  total_callers: { type: 'int?', doc: "Total callers run to generate this VCF." }
  ns_effects: { type: 'string[]?', doc: "List of NS effects" }
  canonical_cds_bed_snpeff: { type: 'File?', doc: "BED file contatining Canine canonical CDS intervals for SnpEff." }
  canonical_cds_bed_vep: { type: 'File?', doc: "BED file contatining Canine canonical CDS intervals for VEP." }

  msisensor_reference: { type: 'File?', doc: "MSIsensor Pro reference file for detecting homopolymers and microsatellites" }
  exome: { type: 'boolean?', doc: "Set to true if sample is from an exome." }

  # Killswitches
  disable_mutation_burden: { type: 'boolean?', doc: "Set to true to disable Mutation Burden metrics collection." }
  disable_tucon: { type: 'boolean?', doc: "Set to true to disable Tucon metics collection." }
  disable_msisensor: { type: 'boolean?', doc: "Set to true to disable Msisensor metrics collection." }
  disable_sigprofiler: { type: 'boolean?', doc: "Set to true to disable Sigprofiler metrics collection." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
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
  snpeff_mutation_burdern_txt: { type: 'File?', outputSource: canine_mutation_burden_module_snpeff/tmb_metrics_txt }
  snpeff_mutation_burdern_json: { type: 'File?', outputSource: canine_mutation_burden_module_snpeff/tmb_metrics_json }
  snpeff_tucon: { type: 'File?', outputSource: canine_tucon_module_snpeff/tucon_tsv }
  vep_mutation_burdern_txt: { type: 'File?', outputSource: canine_mutation_burden_module_vep/tmb_metrics_txt }
  vep_mutation_burdern_json: { type: 'File?', outputSource: canine_mutation_burden_module_vep/tmb_metrics_json }
  vep_tucon: { type: 'File?', outputSource: canine_tucon_module_vep/tucon_tsv }
  msisensor_metrics: { type: 'File?', outputSource: canine_msisensor_pro_module/msisensor_metrics_txt }
  sigprofiler_sbs_activity: { type: 'File?', outputSource: canine_sigprofiler_module/sbs_activity }
  sigprofiler_sbs_activity_plot: { type: 'File?', outputSource: canine_sigprofiler_module/sbs_activity_plot }
  sigprofiler_sbs_tmb_plot: { type: 'File?', outputSource: canine_sigprofiler_module/sbs_tmb_plot }
  sigprofiler_sbs_dnm_prob: { type: 'File?', outputSource: canine_sigprofiler_module/sbs_dnm_prob }
  sigprofiler_sbs_dn_sigs: { type: 'File?', outputSource: canine_sigprofiler_module/sbs_dn_sigs }
  sigprofiler_id_activity: { type: 'File?', outputSource: canine_sigprofiler_module/id_activity }
  sigprofiler_id_activity_plot: { type: 'File?', outputSource: canine_sigprofiler_module/id_activity_plot }
  sigprofiler_id_tmb_plot: { type: 'File?', outputSource: canine_sigprofiler_module/id_tmb_plot }
  sigprofiler_id_dnm_prob: { type: 'File?', outputSource: canine_sigprofiler_module/id_dnm_prob }
  sigprofiler_id_dn_sigs: { type: 'File?', outputSource: canine_sigprofiler_module/id_dn_sigs }
  sigprofiler_dbs_activity: { type: 'File?', outputSource: canine_sigprofiler_module/dbs_activity }
  sigprofiler_dbs_activity_plot: { type: 'File?', outputSource: canine_sigprofiler_module/dbs_activity_plot }
  sigprofiler_dbs_tmb_plot: { type: 'File?', outputSource: canine_sigprofiler_module/dbs_tmb_plot }
  sigprofiler_dbs_dnm_prob: { type: 'File?', outputSource: canine_sigprofiler_module/dbs_dnm_prob }
  sigprofiler_dbs_dn_sigs: { type: 'File?', outputSource: canine_sigprofiler_module/dbs_dn_sigs }

steps:
  canine_mutation_burden_module_snpeff:
    run: ../sub_workflows/canine_mutation_burden_module.cwl
    when: $(inputs.disable_workflow != true && inputs.input_vcf != null)
    in:
      input_vcf: input_snpeff_can_vcf
      input_tumor_bam: input_tumor_bam
      input_normal_bam: input_normal_bam
      exome_capture_kit_bed: exome_capture_kit_bed
      sample_name: sample_name
      library_name: library_name
      output_basename: 
        source: output_basename
        valueFrom: $(self).snpeff
      disable_workflow: disable_mutation_burden
      total_callers: total_callers
      annotate_flag:
        valueFrom: "snpeff"
      ns_effects: ns_effects
      canonical_cds_bed: canonical_cds_bed_snpeff
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      bedtools_ram: bedtools_ram
      bedtools_cpu: bedtools_cpu
      tmb_ram: tmb_ram
      tmb_cpu: tmb_cpu
    out: [tmb_metrics_txt, tmb_metrics_json]

  canine_tucon_module_snpeff:
    run: ../sub_workflows/canine_tucon_module.cwl
    when: $(inputs.disable_workflow != true && inputs.input_vcf != null)
    in:
      input_vcf: input_snpeff_full_vcf
      output_basename: 
        source: output_basename
        valueFrom: $(self).snpeff
      disable_workflow: disable_tucon
      total_callers: total_callers
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
    out: [tucon_tsv]

  canine_mutation_burden_module_vep:
    run: ../sub_workflows/canine_mutation_burden_module.cwl
    when: $(inputs.disable_workflow != true && inputs.input_vcf != null)
    in:
      input_vcf: input_vep_pick_vcf
      input_tumor_bam: input_tumor_bam
      input_normal_bam: input_normal_bam
      exome_capture_kit_bed: exome_capture_kit_bed
      sample_name: sample_name
      library_name: library_name
      output_basename: 
        source: output_basename
        valueFrom: $(self).vep
      disable_workflow: disable_mutation_burden
      total_callers: total_callers
      annotate_flag:
        valueFrom: "vep"
      ns_effects: ns_effects
      canonical_cds_bed: canonical_cds_bed_vep
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      bedtools_ram: bedtools_ram
      bedtools_cpu: bedtools_cpu
      tmb_ram: tmb_ram
      tmb_cpu: tmb_cpu
    out: [tmb_metrics_txt, tmb_metrics_json]

  canine_tucon_module_vep:
    run: ../sub_workflows/canine_tucon_module.cwl
    when: $(inputs.disable_workflow != true && inputs.input_vcf != null)
    in:
      input_vcf: input_vep_full_vcf
      output_basename: 
        source: output_basename
        valueFrom: $(self).vep
      disable_workflow: disable_tucon
      total_callers: total_callers
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
    out: [tucon_tsv]

  canine_msisensor_pro_module:
    run: ../sub_workflows/canine_msisensor_pro_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_tumor_bam: input_tumor_bam
      input_normal_bam: input_normal_bam
      msisensor_reference: msisensor_reference
      exome: exome
      output_basename: output_basename
      disable_workflow: disable_msisensor
      samtools_ram: samtools_ram
      samtools_cpu: samtools_cpu
      msisensor_ram: msisensor_ram
      msisensor_cpu: msisensor_cpu
    out: [msisensor_metrics_txt]

  canine_sigprofiler_module:
    run: ../sub_workflows/canine_sigprofiler_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      input_vcf: input_merged_vcf
      output_basename: output_basename
      disable_workflow: disable_sigprofiler
      total_callers: total_callers
      bcftools_ram: bcftools_ram
      bcftools_cpu: bcftools_cpu
      sigprofiler_ram: sigprofiler_ram
      sigprofiler_cpu: sigprofiler_cpu
    out: [sbs_activity, sbs_activity_plot, sbs_tmb_plot, sbs_dnm_prob, sbs_dn_sigs, id_activity, id_activity_plot, id_tmb_plot, id_dnm_prob, id_dn_sigs, dbs_activity, dbs_activity_plot, dbs_tmb_plot, dbs_dnm_prob, dbs_dn_sigs]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
