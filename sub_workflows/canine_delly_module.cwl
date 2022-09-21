cwlVersion: v1.2
class: Workflow
id: canine_delly_module
doc: "Port of Canine Delly Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: false }], doc: "Reference fasta with associated fai index" }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "sorted, indexed and duplicate marked bam from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "sorted, indexed and duplicate marked bam from the normal sample" }
  sv_types:
    type:
      type: array
      items:
        type: enum
        name: sv_types
        symbols: ["DEL", "DUP", "INV", "TRA", "INS"]
    doc: |
      SV types for delly to call.
  exclude_bed: { type: 'File', doc: "BED file containing genomic regions to exclude from variant calling" }
  annotation_bed: { type: 'File', doc: "BED file containing annotations for called variants" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }
  normal_sample_name: { type: 'string', doc: "BAM sample name of normal" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }

  # Resource Control
  call_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Delly Call." }
  call_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Delly Call." }
  filter_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Delly Filter." }
  filter_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Delly Filter." }

outputs:
  delly_anno_vcf: { type: 'File', outputSource: bcftools_view_index_delly_anno/output }
  delly_pass_vcf: { type: 'File', outputSource: bcftools_view_index_delly_pass/output }
  delly_all_vcf: { type: 'File', outputSource: bcftools_view_index_delly_all/output }

steps:
  delly_create_sample_file:
    run: ../tools/delly_create_sample_file.cwl
    in:
      tumor_sample_name: tumor_sample_name
      normal_sample_name: normal_sample_name
    out: [output]

  delly_call:
    run: ../tools/delly_call.cwl
    scatter: [sv_type]
    in:
      input_tumor_bam: input_tumor_reads
      input_normal_bams:
        source: input_normal_reads
        valueFrom: $([self])
      sv_type: sv_types
      genome: indexed_reference_fasta
      exclude: exclude_bed
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.$(inputs.sv_type).bcf
      map_qual:
        valueFrom: $(1)
      mad_cutoff:
        valueFrom: $(9)
      cpu: call_cpu
      ram: call_ram
    out: [bcf]

  delly_filter:
    run: ../tools/delly_filter.cwl
    scatter: [input_bcf, sv_type]
    scatterMethod: dotproduct
    in:
      input_bcf: delly_call/bcf
      samples: delly_create_sample_file/output
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.$(inputs.sv_type).filt.bcf
      sv_type: sv_types
      filter_mode:
        valueFrom: somatic
      altaf:
        valueFrom: $(0.1)
      ratiogeno:
        valueFrom: $(0.75)
      coverage:
        valueFrom: $(5)
      controlcontamination:
        valueFrom: $(0)
      minsize:
        valueFrom: |
          ${
            var size = 500;
            if (inputs.sv_type == "DEL") {
              size = 2000;
            } else if (inputs.sv_type == "DUP" || inputs.sv_type == "INV") {
              size = 100;
            } else if (inputs.sv_type == "INS") {
              size = 5;
            }
            return size;
          }
      maxsize:
        valueFrom: |
          $(inputs.sv_type == "INS" ? 87 : 500000000)
      cpu: filter_cpu
      ram: filter_ram
    out: [bcf]

  bcftools_concat_sort_index:
    run: ../tools/bcftools_concat_sort_index.cwl
    in:
      input_vcfs: delly_filter/bcf
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.all.vcf
      allow_overlaps:
        valueFrom: $(1 == 1)
      output_type:
        valueFrom: "v"
    out: [vcf]

  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: bcftools_concat_sort_index/vcf
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.pass.vcf
      output_type:
        valueFrom: "v"
      apply_filters:
        valueFrom: "PASS"
    out: [output]

  coyote_addRC_to_delly_vcf:
    run: ../tools/coyote_addRC_to_delly_vcf.cwl
    in:
      input_vcf: bcftools_view_index/output
      input_tumor_bam: input_tumor_reads
      input_normal_bam: input_normal_reads
      slop:
        valueFrom: $(1000)
    out: [output]

  bcftools_filter_index:
    run: ../tools/bcftools_filter_index.cwl
    in:
      input_vcf: coyote_addRC_to_delly_vcf/output
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.pass.mod_addDist.flt.vcf
      output_type:
        valueFrom: "v"
      exclude:
        valueFrom: |
          "FMT/RCALT[0] < 5 | FMT/RCALT[1] > 1 | FMT/RDISTDISC1[0] < 100 | FMT/RDISTDISC2[0] < 100"
    out: [output]

  coyote_delly_sv_annotation:
    run: ../tools/coyote_delly_sv_annotation.cwl
    in:
      input_vcf: bcftools_filter_index/output
      input_annotation_bed: annotation_bed
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.pass.anno.vcf
    out: [output]

  bcftools_view_index_delly_anno:
    run: ../tools/bcftools_view_index_delly.cwl
    in:
      input_vcf: coyote_delly_sv_annotation/output
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.pass.anno.vcf.gz
      output_type:
        valueFrom: "z"
    out: [output]

  bcftools_view_index_delly_all:
    run: ../tools/bcftools_view_index_delly.cwl
    in:
      input_vcf: bcftools_concat_sort_index/vcf 
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.all.vcf.gz
      output_type:
        valueFrom: "z"
    out: [output]

  bcftools_view_index_delly_pass:
    run: ../tools/bcftools_view_index_delly.cwl
    in:
      input_vcf: bcftools_view_index/output
      output_filename:
        source: output_basename
        valueFrom: $(self).delly.pass.vcf.gz
      output_type:
        valueFrom: "z"
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
