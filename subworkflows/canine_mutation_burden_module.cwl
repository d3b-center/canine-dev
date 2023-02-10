cwlVersion: v1.2
class: Workflow
id: canine_mutation_burden_module
doc: "Port of Canine Mutatuion Burden Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF file on which to generate mutation burden metrics." }
  input_tumor_bam: { type: 'File', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from tumor sample." }
  input_normal_bam: { type: 'File', secondaryFiles: [ { pattern: '.bai', required: false }, { pattern: '^.bai', required: false } ], doc: "BAM containing reads from normal sample." }
  exome_capture_kit_bed: { type: 'File?', doc: "BED file contatining the capture kit intervals used to generate this sample." }
  sample_name: { type: 'string', doc: "Sample name as denoted in the tumor BAM read group header." }
  library_name: { type: 'string', doc: "Library name as denoted in the tumor BAM read group header." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }

  total_callers: { type: 'int', doc: "Total callers run to generate this VCF." } 
  annotate_flag: { type: 'string', doc: "Name of the annotator run to generate the input_vcf" }
  ns_effects: { type: 'string[]', doc: "List of NS effects" }
  canonical_cds_bed: { type: 'File', doc: "BED file contatining Canine canonical CDS intervals for this software." }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  bedtools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BEDtools." }
  bedtools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BEDtools." }
  tmb_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Coyote Tumor Mutation Burden script." }
  tmb_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Coyote Tumor Mutation Burden script." }

outputs:
  tmb_metrics_txt: { type: 'File', outputSource: tumor_mutation_burden/output }
  tmb_metrics_json: { type: 'File', outputSource: stats2json/output }

steps:
  expr_include_string:
    run:  ../tools/expr_include_string.cwl
    in:
      snpeff:
        source: annotate_flag
        valueFrom: $(self == 'snpeff')
      ns_effects: ns_effects 
      total_callers: total_callers 
    out: [output]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: "tmp.vcf.gz"
      include: expr_include_string/output
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bedtools_intersect:
    run: ../tools/bedtools_intersect.cwl
    when: $(inputs.input_b != null)
    in:
      input_a: canonical_cds_bed
      input_b: exome_capture_kit_bed
      output_filename:
        valueFrom: "tmp_isec_cds_capture_kit.bed"
      cpu: bedtools_cpu
      ram: bedtools_ram
    out: [output]

  tumor_mutation_burden:
    run: ../tools/tumor_mutation_burden.cwl
    in:
      bed:
        source: [bedtools_intersect/output, canonical_cds_bed]
        pickValue: first_non_null
      vcf: bcftools_filter_index/output
      nbam: input_normal_bam
      tbam: input_tumor_bam
      output_filename:
        source: output_basename
        valueFrom: $(self).mutation_burden.txt
      sample: sample_name
      library: library_name
      pipeline:
        valueFrom: $(1 == 1)
      verbose:
        valueFrom: $(1 == 1)
      cpu: tmb_cpu
      ram: tmb_ram
    out: [output]

  stats2json:
    run: ../tools/stats2json.cwl
    in:
      statfile: tumor_mutation_burden/output
      output:
        source: output_basename
        valueFrom: $(self).mutation_burden.json
      filetype:
        valueFrom: "tgen_mutation_burden"
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
