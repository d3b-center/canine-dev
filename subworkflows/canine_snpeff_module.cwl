cwlVersion: v1.2
class: Workflow
id: canine_snpeff_module
doc: "Port of Canine SnpEff Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  # Killswitch
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  # Required
  input_vcf: { type: 'File', doc: "VCF file to annotate." }
  snpeff_database: { type: 'string', doc: "Name of SnpEff database information" }
  snpeff_config: { type: 'File', doc: "SnpEff config file" }
  snpeff_datadir: { type: 'Directory', loadListing: deep_listing, doc: "Directory containing SnpEff database information" }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }

  # Resource Control
  snpeff_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SnpEff." }
  snpeff_cpu: { type: 'int?', doc: "Number of CPUs to allocate to SnpEff." }

outputs:
  snpeff_all_vcf: { type: 'File', outputSource: snpeff_annotate_bcftools_view_index_all/output }
  snpeff_canon_vcf: { type: 'File', outputSource: snpeff_annotate_bcftools_view_index_canon/output }

steps:
  snpeff_annotate_bcftools_view_index_all:
    run: ../tools/snpeff_annotate_bcftools_view_index.cwl
    in:
      input_vcf: input_vcf
      snpeff_database: snpeff_database
      config: snpeff_config
      dataDir: snpeff_datadir
      threads:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: $(1 == 1)
      hgvs:
        valueFrom: $(1 == 1)
      lof:
        valueFrom: $(1 == 1)
      output_filename:
        source: output_basename
        valueFrom: $(self).snpeff.full.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      force:
        valueFrom: $(1 == 1)
      cpu: snpeff_cpu
      ram: snpeff_ram
    out: [output]

  snpeff_annotate_bcftools_view_index_canon:
    run: ../tools/snpeff_annotate_bcftools_view_index.cwl
    in:
      input_vcf: input_vcf
      snpeff_database: snpeff_database
      config: snpeff_config
      dataDir: snpeff_datadir
      threads:
        valueFrom: $(1 == 1)
      canon:
        valueFrom: $(1 == 1)
      hgvs:
        valueFrom: $(1 == 1)
      lof:
        valueFrom: $(1 == 1)
      output_filename:
        source: output_basename
        valueFrom: $(self).snpeff.can.vcf.gz
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      force:
        valueFrom: $(1 == 1)
      cpu: snpeff_cpu
      ram: snpeff_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
