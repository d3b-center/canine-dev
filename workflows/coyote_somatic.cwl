cwlVersion: v1.2
class: Workflow
id: coyote_somatic
doc: "Port of Coyote Somatic"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: SubworkflowFeatureRequirement

inputs:
  # Killswitches
  disable_mutect2: { type: 'boolean?', doc: "Set to true to disable Mutect2." }
  disable_strelka2: { type: 'boolean?', doc: "Set to true to disable Strelka2." }
  disable_lancet: { type: 'boolean?', doc: "Set to true to disable Lancet." }
  disable_vardict: { type: 'boolean?', doc: "Set to true to disable Vardict." }
  disable_octopus: { type: 'boolean?', doc: "Set to true to disable Octopus." }
  disable_vcfmerger2: { type: 'boolean?', doc: "Set to true to disable vcfmerger2." }
  disable_bcftools: { type: 'boolean?', doc: "Set to true to disable bcftools GCA annotation." }
  disable_tumor_only_var_filt: { type: 'boolean?', default: true, doc: "Set to true to disable tumor only variant filtering." }
  disable_snpeff: { type: 'boolean?', doc: "Set to true to disable SnpEff annotation." }
  disable_vep: { type: 'boolean?', doc: "Set to true to disable VEP annotation." }
  disable_mutation_burden: { type: 'boolean?', doc: "Set to true to disable Mutation Burden metrics collection." }
  disable_tucon: { type: 'boolean?', doc: "Set to true to disable Tucon metics collection." }
  disable_msisensor: { type: 'boolean?', doc: "Set to true to disable Msisensor metrics collection." }
  disable_sigprofiler: { type: 'boolean?', doc: "Set to true to disable Sigprofiler metrics collection." }
  disable_manta: { type: 'boolean?', doc: "Set to true to disable Manta." }
  disable_sequenza: { type: 'boolean?', doc: "Set to true to disable Sequenza." }

  # Mutect2
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }], doc: "Reference fasta with FAI and DICT indicies" }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }], doc: "BAM/SAM/CRAM file containing reads from the normal sample" }
  calling_intervals: { type: 'File?', doc: "YAML file contianing the intervals in which to perform variant calling." }
  af_vcf: { type: 'File?', secondaryFiles: [{ pattern: ".tbi", required: false }], doc: "A VCF file containing variants and allele frequencies" }
  targets_file: { type: 'File?', doc: "For exome variant calling, this file contains the targets regions used in library preparation." }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Manta
  manta_call_regions: { type: 'File?', secondaryFiles: [{ pattern: ".tbi", required: true}], doc: "Calling regions BED file that has been bgzipped and tabix indexed" }
  manta_config: { type: 'File?', doc: "Custom config.ini file for Manta. Used to override defaults set in the global config file" }
  exome: { type: 'boolean', doc: "Set to true if this sample is exome. Set to false if this sample is genome." }
  tgen_insertsize_metrics: { type: 'File?', doc: "File containing samtools stats insert size summary information." }
  annotation_bed: { type: 'File?', doc: "BED file containing annotations for called variants" }

  # Strelka2
  strelka2_call_regions: { type: 'File?', secondaryFiles: [{ pattern: ".tbi", required: true}], doc: "Calling regions BED file that has been bgzipped and tabix indexed" }
  strelka2_config: { type: 'File?', doc: "Custom config.ini file for Manta. Used to override defaults set in the global config file" }

  # Lancet

  # Vardict

  # Octopus
  primary_contig_calling_intervals: { type: 'File?', doc: "YAML file contianing the intervals in which to perform variant calling." }
  octopus_cache: { type: 'File?', doc: "Tarball of cache made by Octopus. Octopus will make this in the first run and it can be saved and reused to speed up future runs." }

  # VCFMerger2
  tool_precidence: { type: 'string[]?', doc: "The order in which the VCFs will be ranked on precedence. Every tool from this list must be run. If a caller is disabled, it must be removed from the list!" }
  star_bam_final: { type: 'File?', doc: "STAR BAM final from a matched RNA sample." }
  rna_samplename: { type: 'string?', doc: "Name of RNA sample associated with tumor pair" }
  input_gca_annotations_vcf: { type: 'File?', secondaryFiles: [ { pattern: '.tbi', required: true } ], doc: "VCF containing EVA GCA annotations: GCA_000002285.2_current_ids_renamed.vcf.gz" }
  snpeff_config: { type: 'File?', doc: "SnpEff config file" }
  snpeff_database: { type: 'string?', default: "canfam3.1.98", doc: "Name of SnpEff database information" }
  snpeff_tar: { type: 'File?', doc: "TAR containing SnpEff config file and cache information" }
  snpeff_cachename: { type: 'string?', default: "data", doc: "Name of snpeff cache directory contained in snpeff_tar" }
  vep_tar: { type: 'File?', doc: "TAR containing VEP cache information" }
  vep_cachename: { type: 'string?', default: "canis_familiaris", doc: "Name of vep cache directory contained in vep_tar" }
  tumor_library_name: { type: 'string?', doc: "Library name as denoted in the tumor BAM read group header." }
  ns_effects: { type: 'string[]?', default: [ "'splice_acceptor_variant'", "'splice_donor_variant'", "'start_lost'", "'exon_loss_variant'", "'frameshift_variant'", "'stop_gained'", "'stop_lost'", "'start_lost'", "'rare_amino_acid_variant'", "'missense_variant'", "'inframe_insertion'", "'disruptive_inframe_insertion'", "'inframe_deletion'", "'disruptive_inframe_deletion'" ], doc: "List of NS effects" }
  canonical_cds_bed_snpeff: { type: 'File?', doc: "BED file contatining Canine canonical CDS intervals for SnpEff." }
  canonical_cds_bed_vep: { type: 'File?', doc: "BED file contatining Canine canonical CDS intervals for VEP." }
  msisensor_reference: { type: 'File?', doc: "MSIsensor Pro reference file for detecting homopolymers and microsatellites" }
  exome_capture_kit_bed: { type: 'File?', doc: "BED file contatining the capture kit intervals used to generate this sample." }

  # Sequenza
  primary_calling_contigs: { type: 'File?', doc: "YAML file continaing primary calling contigs." }
  gc_content_wiggle: { type: 'File?', doc: "The GC-content wiggle file. Can be gzipped" }

  # Resource Control
  bam2seqz_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza bam2seqz." }
  bam2seqz_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza bam2seqz." }
  seqz_binning_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza seqz binning." }
  seqz_binning_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza seqz binning." }
  sequenza_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza R." }
  sequenza_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza R." }
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
  msisensor_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to msisensor." }
  msisensor_cpu: { type: 'int?', doc: "Number of CPUs to allocate to msisensor." }
  sigprofiler_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sigprofiler." }
  sigprofiler_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sigprofiler." }
  octopus_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Octopus." }
  octopus_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Octopus." }
  vardict_ram: { type: 'int?', doc: "GB of RAM to allocate to Vardict." }
  vardict_cpu: { type: 'int?', doc: "CPUs to allocate to Vardict." }
  lancet_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Lancet." }
  lancet_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Lancet." }
  strelka2_ram: { type: 'int?', doc: "GB of RAM to allocate to Strelka2." }
  strelka2_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Strelka2." }
  manta_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Manta." }
  manta_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Manta." }
  mutect2_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to Mutect2." }
  mutect2_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Mutect2." }
  getpileupsummaries_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to getpileupsummaries." }
  getpileupsummaries_cpu: { type: 'int?', doc: "Number of CPUs to allocate to getpileupsummaries." }
  mergemutectstats_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to mergemutectstats." }
  mergemutectstats_cpu: { type: 'int?', doc: "Number of CPUs to allocate to mergemutectstats." }
  learnreadorientationmodel_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to learnreadorientationmodel." }
  learnreadorientationmodel_cpu: { type: 'int?', doc: "Number of CPUs to allocate to learnreadorientationmodel." }
  gatherpileupsummaries_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to gatherpileupsummaries." }
  gatherpileupsummaries_cpu: { type: 'int?', doc: "Number of CPUs to allocate to gatherpileupsummaries." }
  calculatecontamination_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to calculatecontamination." }
  calculatecontamination_cpu: { type: 'int?', doc: "Number of CPUs to allocate to calculatecontamination." }
  filtermutectcalls_max_memory: { type: 'int?', doc: "Maximum GB of RAM to allocate to filtermutectcalls." }
  filtermutectcalls_cpu: { type: 'int?', doc: "Number of CPUs to allocate to filtermutectcalls." }

outputs:
  mutect2_all_vcf: { type: 'File?', outputSource: canine_mutect2_module/mutect2_all_vcf }
  mutect2_pass_vcf: { type: 'File?', outputSource: canine_mutect2_module/mutect2_pass_vcf }
  mutect2_all_vcf_stats: { type: 'File?', outputSource: canine_mutect2_module/mutect2_all_vcf_stats }
  mutect2_pass_vcf_stats: { type: 'File?', outputSource: canine_mutect2_module/mutect2_pass_vcf_stats }
  manta_somatic_pass_svs: { type: 'File?', outputSource: canine_manta_module/manta_somatic_pass_svs }
  manta_small_indels: { type: 'File?', outputSource: canine_manta_module/manta_small_indels }
  manta_candidate_svs: { type: 'File?', outputSource: canine_manta_module/manta_candidate_svs }
  manta_diploid_svs: { type: 'File?', outputSource: canine_manta_module/manta_diploid_svs }
  manta_somatic_svs: { type: 'File?', outputSource: canine_manta_module/manta_somatic_svs }
  strelka2_all_vcf: { type: 'File?', outputSource: canine_strelka2_module/strelka2_all_vcf }
  strelka2_pass_vcf: { type: 'File?', outputSource: canine_strelka2_module/strelka2_pass_vcf }
  strelka2_realigned_normal_cram: { type: 'File?', outputSource: canine_strelka2_module/strelka2_realigned_normal_cram }
  strelka2_realigned_tumor_cram: { type: 'File?', outputSource: canine_strelka2_module/strelka2_realigned_tumor_cram }
  strelka2_all_vcf_stats: { type: 'File?', outputSource: canine_strelka2_module/strelka2_all_vcf_stats }
  strelka2_pass_vcf_stats: { type: 'File?', outputSource: canine_strelka2_module/strelka2_pass_vcf_stats }
  octopus_all_vcf: { type: 'File?', outputSource: canine_octopus_module/octopus_all_vcf }
  octopus_pass_vcf: { type: 'File?', outputSource: canine_octopus_module/octopus_pass_vcf }
  octopus_all_vcf_stats: { type: 'File?', outputSource: canine_octopus_module/octopus_all_vcf_stats }
  octopus_pass_vcf_stats: { type: 'File?', outputSource: canine_octopus_module/octopus_pass_vcf_stats }
  lancet_all_vcf: { type: 'File?', outputSource: canine_lancet_module/lancet_all_vcf }
  lancet_pass_vcf: { type: 'File?', outputSource: canine_lancet_module/lancet_pass_vcf }
  lancet_all_vcf_stats: { type: 'File?', outputSource: canine_lancet_module/lancet_all_vcf_stats }
  lancet_pass_vcf_stats: { type: 'File?', outputSource: canine_lancet_module/lancet_pass_vcf_stats }
  vardict_all_vcf: { type: 'File?', outputSource: canine_vardict_module/vardict_all_vcf }
  vardict_pass_vcf: { type: 'File?', outputSource: canine_vardict_module/vardict_pass_vcf }
  varidct_all_vcf_stats: { type: 'File?', outputSource: canine_vardict_module/varidct_all_vcf_stats }
  vardict_pass_vcf_stats: { type: 'File?', outputSource: canine_vardict_module/vardict_pass_vcf_stats }
  vcfmerger_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/vcfmerger_vcf }
  vcfmerger_vcf_stats: { type: 'File?', outputSource: canine_vcfmerger2_module/vcfmerger_vcf_stats }
  vcfmerger_venns: { type: 'Directory[]?', outputSource: canine_vcfmerger2_module/vcfmerger_venns }
  bcftools_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/bcftools_vcf }
  tumor_only_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/tumor_only_vcf }
  snpeff_all_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/snpeff_all_vcf }
  snpeff_canon_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/snpeff_canon_vcf }
  vep_all_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/vep_all_vcf }
  vep_con_vcf: { type: 'File?', outputSource: canine_vcfmerger2_module/vep_con_vcf }
  snpeff_mutation_burdern_txt: { type: 'File?', outputSource: canine_vcfmerger2_module/snpeff_mutation_burdern_txt }
  snpeff_mutation_burdern_json: { type: 'File?', outputSource: canine_vcfmerger2_module/snpeff_mutation_burdern_json }
  snpeff_tucon: { type: 'File?', outputSource: canine_vcfmerger2_module/snpeff_tucon }
  vep_mutation_burdern_txt: { type: 'File?', outputSource: canine_vcfmerger2_module/vep_mutation_burdern_txt }
  vep_mutation_burdern_json: { type: 'File?', outputSource: canine_vcfmerger2_module/vep_mutation_burdern_json }
  vep_tucon: { type: 'File?', outputSource: canine_vcfmerger2_module/vep_tucon }
  msisensor_metrics: { type: 'File?', outputSource: canine_vcfmerger2_module/msisensor_metrics }
  sigprofiler_sbs_activity: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_sbs_activity }
  sigprofiler_sbs_activity_plot: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_sbs_activity_plot }
  sigprofiler_sbs_tmb_plot: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_sbs_tmb_plot }
  sigprofiler_sbs_dnm_prob: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_sbs_dnm_prob }
  sigprofiler_sbs_dn_sigs: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_sbs_dn_sigs }
  sigprofiler_id_activity: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_id_activity }
  sigprofiler_id_activity_plot: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_id_activity_plot }
  sigprofiler_id_tmb_plot: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_id_tmb_plot }
  sigprofiler_id_dnm_prob: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_id_dnm_prob }
  sigprofiler_id_dn_sigs: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_id_dn_sigs }
  sigprofiler_dbs_activity: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_dbs_activity }
  sigprofiler_dbs_activity_plot: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_dbs_activity_plot }
  sigprofiler_dbs_tmb_plot: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_dbs_tmb_plot }
  sigprofiler_dbs_dnm_prob: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_dbs_dnm_prob }
  sigprofiler_dbs_dn_sigs: { type: 'File?', outputSource: canine_vcfmerger2_module/sigprofiler_dbs_dn_sigs }
  seqz: { type: 'File?', outputSource: canine_sequenza_module/seqz }
  small_seqz: { type: 'File?', outputSource: canine_sequenza_module/small_seqz }
  sequenza_dir: { type: 'Directory?', outputSource: canine_sequenza_module/sequenza_dir }

steps:
  samtools_view_tumor_bam:
    run: ../tools/samtools_view.cwl
    when: $(inputs.input_reads.nameext == '.cram')
    in:
      input_reads: input_tumor_reads
      reference_fasta: indexed_reference_fasta
      output_bam:
        valueFrom: $(1 == 1)
      write_index:
        valueFrom: $(1 == 1)
      output_filename:
        valueFrom: |
          $(inputs.input_reads.nameroot).bam##idx##$(inputs.input_reads.nameroot).bam.bai
      cpu:
        valueFrom: $(8)
      ram:
        valueFrom: $(16)
    out: [output]

  samtools_view_normal_bam:
    run: ../tools/samtools_view.cwl
    when: $(inputs.input_reads.nameext == '.cram')
    in:
      input_reads: input_normal_reads
      reference_fasta: indexed_reference_fasta
      output_bam:
        valueFrom: $(1 == 1)
      write_index:
        valueFrom: $(1 == 1)
      output_filename:
        valueFrom: |
          $(inputs.input_reads.nameroot).bam##idx##$(inputs.input_reads.nameroot).bam.bai
      cpu:
        valueFrom: $(8)
      ram:
        valueFrom: $(16)
    out: [output]

  canine_mutect2_module:
    run: ../sub_workflows/canine_mutect2_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_mutect2
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_reads: input_tumor_reads
      input_normal_reads: input_normal_reads
      calling_intervals: calling_intervals
      af_vcf: af_vcf
      targets_file: targets_file
      normal_sample_name: normal_sample_name
      tumor_sample_name: tumor_sample_name
      output_basename: output_basename
      mutect2_max_memory: mutect2_max_memory
      mutect2_cpu: mutect2_cpu
      getpileupsummaries_max_memory: getpileupsummaries_max_memory
      getpileupsummaries_cpu: getpileupsummaries_cpu
      mergemutectstats_max_memory: mergemutectstats_max_memory
      mergemutectstats_cpu: mergemutectstats_cpu
      learnreadorientationmodel_max_memory: learnreadorientationmodel_max_memory
      learnreadorientationmodel_cpu: learnreadorientationmodel_cpu
      gatherpileupsummaries_max_memory: gatherpileupsummaries_max_memory
      gatherpileupsummaries_cpu: gatherpileupsummaries_cpu
      calculatecontamination_max_memory: calculatecontamination_max_memory
      calculatecontamination_cpu: calculatecontamination_cpu
      filtermutectcalls_max_memory: filtermutectcalls_max_memory
      filtermutectcalls_cpu: filtermutectcalls_cpu
    out: [mutect2_all_vcf, mutect2_pass_vcf, mutect2_all_vcf_stats, mutect2_pass_vcf_stats]

  canine_manta_module:
    run: ../sub_workflows/canine_manta_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_manta
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_reads: input_tumor_reads
      input_normal_reads: input_normal_reads
      tumor_sample_name: tumor_sample_name
      call_regions: manta_call_regions
      config: manta_config
      exome: exome
      samtools_stats: tgen_insertsize_metrics
      annotation_bed: annotation_bed
      output_basename: output_basename
      manta_ram: manta_ram
      manta_cpu: manta_cpu
    out: [manta_somatic_pass_svs, manta_small_indels, manta_candidate_svs, manta_diploid_svs, manta_somatic_svs]

  canine_strelka2_module:
    run: ../sub_workflows/canine_strelka2_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_strelka2
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_reads: input_tumor_reads
      input_normal_reads: input_normal_reads
      call_regions: strelka2_call_regions
      config: strelka2_config
      indel_candidates:
        source: canine_manta_module/manta_small_indels
        valueFrom: $([self])
      exome: exome
      targets_file: targets_file
      normal_sample_name: normal_sample_name
      tumor_sample_name: tumor_sample_name
      output_basename: output_basename
      strelka2_ram: strelka2_ram
      strelka2_cpu: strelka2_cpu
    out: [strelka2_all_vcf, strelka2_pass_vcf, strelka2_realigned_normal_cram, strelka2_realigned_tumor_cram, strelka2_all_vcf_stats, strelka2_pass_vcf_stats]

  canine_lancet_module:
    run: ../sub_workflows/canine_lancet_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_lancet
      calling_intervals: calling_intervals
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_reads:
        source: [samtools_view_tumor_bam/output, input_tumor_reads]
        pickValue: first_non_null
      input_normal_reads:
        source: [samtools_view_normal_bam/output, input_normal_reads]
        pickValue: first_non_null
      output_basename: output_basename
      targets_file: targets_file
      lancet_ram: lancet_ram
      lancet_cpu: lancet_cpu
    out: [lancet_all_vcf, lancet_pass_vcf, lancet_all_vcf_stats, lancet_pass_vcf_stats]

  canine_vardict_module:
    run: ../sub_workflows/canine_vardict_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_vardict
      calling_intervals: calling_intervals
      input_tumor_reads:
        source: [samtools_view_tumor_bam/output, input_tumor_reads]
        pickValue: first_non_null
      input_normal_reads:
        source: [samtools_view_normal_bam/output, input_normal_reads]
        pickValue: first_non_null
      tumor_sample_name: tumor_sample_name
      normal_sample_name: normal_sample_name
      indexed_reference_fasta: indexed_reference_fasta
      targets_file: targets_file
      output_basename: output_basename
      vardict_ram: vardict_ram
      vardict_cpu: vardict_cpu
    out: [vardict_all_vcf, vardict_pass_vcf, varidct_all_vcf_stats, vardict_pass_vcf_stats]

  canine_octopus_module:
    run: ../sub_workflows/canine_octopus_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_octopus
      calling_intervals: primary_contig_calling_intervals
      indexed_reference_fasta: indexed_reference_fasta
      input_reads:
        source: [input_normal_reads, input_tumor_reads]
      normal_sample_name: normal_sample_name
      output_basename: output_basename
      targets_file: targets_file
      cache_tar: octopus_cache
      octopus_ram: octopus_ram
      octopus_cpu: octopus_cpu
    out: [octopus_all_vcf, octopus_pass_vcf, octopus_all_vcf_stats, octopus_pass_vcf_stats]

  canine_vcfmerger2_module:
    run: ../sub_workflows/canine_vcfmerger2_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_vcfmerger2
      disable_bcftools: disable_bcftools
      disable_tumor_only_var_filt: disable_tumor_only_var_filt
      disable_snpeff: disable_snpeff
      disable_vep: disable_vep
      disable_mutation_burden: disable_mutation_burden
      disable_tucon: disable_tucon
      disable_msisensor: disable_msisensor
      disable_sigprofiler: disable_sigprofiler
      input_vcfs:
        source: [canine_mutect2_module/mutect2_pass_vcf, canine_lancet_module/lancet_pass_vcf, canine_octopus_module/octopus_pass_vcf, canine_strelka2_module/strelka2_pass_vcf, canine_vardict_module/vardict_pass_vcf]
        pickValue: all_non_null
      input_toolnames:
        valueFrom: |
          $(inputs.input_vcfs.map(function(e) { return e.metadata.toolname }))
      tool_precidence: tool_precidence
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_bam:
        source: [samtools_view_tumor_bam/output, input_tumor_reads]
        pickValue: first_non_null
      input_normal_bam:
        source: [samtools_view_normal_bam/output, input_normal_reads]
        pickValue: first_non_null
      tumor_sample_name: tumor_sample_name
      normal_sample_name: normal_sample_name
      output_basename: output_basename
      star_bam_final: star_bam_final
      rna_samplename: rna_samplename
      input_gca_annotations_vcf: input_gca_annotations_vcf
      snpeff_config: snpeff_config
      snpeff_database: snpeff_database
      snpeff_tar: snpeff_tar
      snpeff_cachename: snpeff_cachename
      vep_tar: vep_tar
      vep_cachename: vep_cachename
      tumor_library_name: tumor_library_name
      total_callers:
        valueFrom: $(inputs.input_vcfs.length)
      ns_effects: ns_effects
      canonical_cds_bed_snpeff: canonical_cds_bed_snpeff
      canonical_cds_bed_vep: canonical_cds_bed_vep
      msisensor_reference: msisensor_reference
      exome: exome
      exome_capture_kit_bed: exome_capture_kit_bed
      vcfmerger_ram: vcfmerger_ram
      vcfmerger_cpu: vcfmerger_cpu
      prep_vcf_ram: prep_vcf_ram
      prep_vcf_cpu: prep_vcf_cpu
      freebayes_ram: freebayes_ram
      freebayes_cpu: freebayes_cpu
      snpeff_ram: snpeff_ram
      snpeff_cpu: snpeff_cpu
      vep_ram: vep_ram
      vep_cpu: vep_cpu
      bedtools_ram: bedtools_ram
      bedtools_cpu: bedtools_cpu
      tmb_ram: tmb_ram
      tmb_cpu: tmb_cpu
      msisensor_ram: msisensor_ram
      msisensor_cpu: msisensor_cpu
      sigprofiler_ram: sigprofiler_ram
      sigprofiler_cpu: sigprofiler_cpu
    out: [ vcfmerger_vcf, vcfmerger_vcf_stats, vcfmerger_venns, bcftools_vcf, tumor_only_vcf, snpeff_all_vcf, snpeff_canon_vcf, vep_all_vcf, vep_con_vcf, snpeff_mutation_burdern_txt, snpeff_mutation_burdern_json, snpeff_tucon, vep_mutation_burdern_txt, vep_mutation_burdern_json, vep_tucon, msisensor_metrics, sigprofiler_sbs_activity, sigprofiler_sbs_activity_plot, sigprofiler_sbs_tmb_plot, sigprofiler_sbs_dnm_prob, sigprofiler_sbs_dn_sigs, sigprofiler_id_activity, sigprofiler_id_activity_plot, sigprofiler_id_tmb_plot, sigprofiler_id_dnm_prob, sigprofiler_id_dn_sigs, sigprofiler_dbs_activity, sigprofiler_dbs_activity_plot, sigprofiler_dbs_tmb_plot, sigprofiler_dbs_dnm_prob, sigprofiler_dbs_dn_sigs ]

  canine_sequenza_module:
    run: ../sub_workflows/canine_sequenza_module.cwl
    when: $(inputs.disable_workflow != true)
    in:
      disable_workflow: disable_sequenza
      calling_contigs: primary_calling_contigs
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_reads:
        source: [samtools_view_tumor_bam/output, input_tumor_reads]
        pickValue: first_non_null
      input_normal_reads:
        source: [samtools_view_normal_bam/output, input_normal_reads]
        pickValue: first_non_null
      gc_content_wiggle: gc_content_wiggle
      tumor_sample_name: tumor_sample_name
      output_basename: output_basename
      bam2seqz_ram: bam2seqz_ram
      bam2seqz_cpu: bam2seqz_cpu
      seqz_binning_ram: seqz_binning_ram
      seqz_binning_cpu: seqz_binning_cpu
      sequenza_ram: sequenza_ram
      sequenza_cpu: sequenza_cpu
    out: [seqz, small_seqz, sequenza_dir]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 4
