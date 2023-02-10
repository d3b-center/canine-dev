cwlVersion: v1.2
class: Workflow
id: canine_msisensor_ro_module
doc: "Port of Canine MSISensor Pro Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_tumor_bam: { type: 'File', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from tumor sample." }
  input_normal_bam: { type: 'File', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from normal sample." }
  msisensor_reference: { type: 'File', doc: "MSIsensor Pro reference file for detecting homopolymers and microsatellites" }
  exome: { type: 'boolean?', doc: "Set to true if sample is from an exome." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  # Resource Control
  samtools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to SAMtools." }
  samtools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to SAMtools." }
  msisensor_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to msisensor." }
  msisensor_cpu: { type: 'int?', doc: "Number of CPUs to allocate to msisensor." }

outputs:
  msisensor_metrics_txt: { type: 'File', outputSource: msisensor_pro_msi/output }

steps:
  samtools_view_normal:
    run: ../tools/samtools_view.cwl
    in:
      input_reads: input_normal_bam
      include_header:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: $(1 == 1)
      output_bam:
        valueFrom: $(1 == 1)
      exclude_flags:
        valueFrom: "0x400"
      output_filename:
        valueFrom: "tmp.normal.bam##idx##tmp.normal.bam.bai"
      write_index:
        valueFrom: $(1 == 1)
      cpu: samtools_cpu
      ram: samtools_ram
    out: [output]

  samtools_view_tumor:
    run: ../tools/samtools_view.cwl
    in:
      input_reads: input_tumor_bam
      include_header:
        valueFrom: $(1 == 1)
      output_bam:
        valueFrom: $(1 == 1)
      exclude_flags:
        valueFrom: "0x400"
      output_filename:
        valueFrom: "tmp.tumor.bam##idx##tmp.tumor.bam.bai"
      write_index:
        valueFrom: $(1 == 1)
      cpu: samtools_cpu
      ram: samtools_ram
    out: [output]

  msisensor_pro_msi:
    run: ../tools/msisensor_pro_msi.cwl
    in:
      hp_ms_file: msisensor_reference
      normal_bam_file: samtools_view_normal/output
      tumor_bam_file: samtools_view_tumor/output
      output_filename:
        source: output_basename
        valueFrom: $(self)_msisensor_pro_results.txt
      coverage:
        source: exome
        valueFrom: |
          $(self == true ? 20 : 15)
      cpu: msisensor_cpu
      ram: msisensor_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
