cwlVersion: v1.2
class: CommandLineTool
id: gatk_mutect2
doc: "Call somatic SNVs and indels via local assembly of haplotypes."
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.1.8.0'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: |
          ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_interval_list ? inputs.input_interval_list.nameroot : 'output'; var ext = 'f1r2.tar.gz'; return pre+'.'+ext}
        entry: ""
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      gatk
  - position: 1
    shellQuote: false
    prefix: "--java-options"
    valueFrom: >-
      $("\"-Xmx"+Math.floor(inputs.max_memory*1000/1.074 - 1)+"M\"")
  - position: 2
    shellQuote: false
    valueFrom: >-
      Mutect2
  - position: 3
    shellQuote: false
    prefix: "--output"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_interval_list ? inputs.input_interval_list.nameroot : 'output'; var ext = 'mutect2.vcf.gz'; return pre+'.'+ext}
  - position: 3
    shellQuote: false
    prefix: "--f1r2-tar-gz"
    valueFrom: >-
      ${var pre = inputs.output_prefix ? inputs.output_prefix : inputs.input_interval_list ? inputs.input_interval_list.nameroot : 'output'; var ext = 'f1r2.tar.gz'; return pre+'.'+ext}
inputs:
  indexed_reference:
    type: 'File'
    doc: "Reference fasta"
    secondaryFiles: [{ pattern: ".fai", required: true }, { pattern: "^.dict", required: true }]
    inputBinding:
      position: 3
      prefix: "--reference"
  input_tumor_reads:
    type: 'File'
    secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }]
    doc: "BAM/SAM/CRAM file containing reads from the tumor sample"
    inputBinding:
      position: 3
      prefix: "--input"
  input_normal_reads:
    type: 'File?'
    secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false },{ pattern: ".crai", required: false },{ pattern: "^.crai", required: false }]
    doc: "BAM/SAM/CRAM file containing reads from the normal sample"
    inputBinding:
      position: 3
      prefix: "--input"
  normal_sample_name:
    type: 'string?'
    doc: "BAM sample name of normal(s), if any. May be URL-encoded as output by GetSampleName with -encode argument."
    inputBinding:
      position: 3
      prefix: "--normal-sample"
  tumor_sample_name:
    type: 'string'
    doc: "BAM sample name of tumor(s), if any. May be URL-encoded as output by GetSampleName with -encode argument."
    inputBinding:
      position: 3
      prefix: "--tumor-sample"
  input_interval_list:
    type: 'File?'
    secondaryFiles: [{ pattern: ".tbi", required: false }]
    doc: "One or more genomic intervals over which to operate. Use this input when providing interval list files or other file based inputs."
    inputBinding:
      position: 3
      prefix: "-L"
  independent_mates:
    type: 'boolean?'
    doc: "Allow paired reads to independently support different haplotypes. Useful for validations with ill-designed synthetic data."
    inputBinding:
      position: 3
      prefix: "--independent-mates"
  extra_args:
    type: 'string?'
    doc: "Any valid, extra arguments for this tool."
    inputBinding:
      position: 4
      shellQuote: false
  output_prefix:
    type: 'string?'
    doc: "String to use as the prefix for the outputs."
  max_memory:
    type: 'int?'
    default: 32
    doc: "Maximum GB of RAM to allocate for this tool."
  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
outputs:
  vcf: { type: 'File', outputBinding: { glob: "*.mutect2.vcf.gz" } }
  stats: { type: 'File', outputBinding: { glob: "*.mutect2.vcf.gz.stats" } }
  f1r2: { type: 'File', outputBinding: { glob: "*.f1r2.tar.gz" } }

