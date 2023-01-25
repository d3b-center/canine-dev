cwlVersion: v1.2
class: Workflow
id: canine_vcfmerger2_module
doc: "Port of Canine vcfmerger2 Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcfs: { type: 'File[]', doc: "VCF files to merge." }
  input_toolnames: { type: 'string[]', doc: "Corresponding toolnames for each VCF." }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [ { pattern: '.fai', required: true } ], doc: "Reference genome fasta file with associated FAI index" }
  reference_dict: { type: 'File', doc: "Reference genome dict" }
  input_tumor_bam: { type: 'File', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from tumor sample." }
  input_tumor_name: { type: 'string', doc: "Name of the tumor sample as presented in the read group SM field." }
  input_normal_name: { type: 'string', doc: "Name of the normal sample as presented in the read group SM field." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  vcfmerger_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to vcfmerger2." }
  vcfmerger_cpu: { type: 'int?', doc: "Number of CPUs to allocate to vcfmerger2." }
  prep_vcf_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to prep_vcf_somatic.sh." }
  prep_vcf_cpu: { type: 'int?', doc: "Number of CPUs to allocate to prep_vcf_somatic.sh." }

outputs:
  vcfmerger_vcf: { type: 'File', outputSource: vcfmerger2/vcf }
  vcfmerger_venns: { type: 'Directory[]?', outputSource: vcfmerger2/venns }

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
        valueFrom: $(inputs.toolname).prepz.vcf
      normal_sname: input_normal_name
      tumor_sname: input_tumor_name
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
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  vcfmerger2:
    run: ../tools/vcfmerger2.cwl
    in:
      vcfs: bcftools_filter_index/output
      toolnames: input_toolnames
      precedence: input_toolnames
      refgenome: indexed_reference_fasta
      dict: reference_dict
      merged_vcf_outfilename:
        source: output_basename
        valueFrom: $(self).merged.vcf
      normal_sname: input_normal_name
      tumor_sname: input_tumor_name
      do_venn:
        valueFrom: $(1 == 1)
      skip_prep_vcfs:
        valueFrom: $(1 == 1)
      cpu: vcfmerger_cpu
      ram: vcfmerger_ram
    out: [vcf, venns]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
