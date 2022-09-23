cwlVersion: v1.2
class: Workflow
id: canine_sequenza_module
doc: "Port of Canine Sequenza Somatic Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  calling_contigs: { type: 'string[]', doc: "Contigs over which to perform variant calling." }
  indexed_reference_fasta: { type: 'File', secondaryFiles: [{ pattern: ".fai", required: true }], doc: "Reference fasta with FAI index" }
  input_tumor_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "BAM file containing mapped reads from the tumor sample" }
  input_normal_reads: { type: 'File', secondaryFiles: [{ pattern: ".bai", required: false },{ pattern: "^.bai", required: false }], doc: "BAM file containing mapped reads from the normal sample" }
  gc_content_wiggle: { type: 'File', doc: "The GC-content wiggle file. Can be gzipped" }
  tumor_sample_name: { type: 'string', doc: "BAM sample name of tumor" }
  output_basename: { type: 'string', doc: "String to use as basename for outputs." }

  # Resource Control
  bam2seqz_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza bam2seqz." }
  bam2seqz_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza bam2seqz." }
  seqz_binning_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza seqz binning." }
  seqz_binning_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza seqz binning." }
  sequenza_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sequenza R." }
  sequenza_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sequenza R." }

outputs:
  sequenza_dir: { type: 'Directory', outputSource: sequenza_coyote/output }

steps:
  sequenza_bam2seqz:
    run: ../tools/sequenza_bam2seqz.cwl
    scatter: [chromosome]
    in:
      input_normal: input_normal_reads
      input_tumor: input_tumor_reads
      indexed_reference: indexed_reference_fasta
      input_wiggle: gc_content_wiggle
      chromosome: calling_contigs
      output_filename:
        valueFrom: $(inputs.chromosome).seqz
      cpu: bam2seqz_cpu
      ram: bam2seqz_ram
    out: [seqz]

  sequenza_combine_seqz:
    run: ../tools/sequenza_combine_seqz.cwl
    in:
      input_seqzs: sequenza_bam2seqz/seqz
      output_filename:
        source: output_basename
        valueFrom: $(self).sequenza.seqz.gz
    out: [output]

  sequenza_seqz_binning:
    run: ../tools/sequenza_seqz_binning.cwl
    in:
      input_seqz: sequenza_combine_seqz/output
      window:
        valueFrom: $(50)
      output_filename:
        source: output_basename
        valueFrom: $(self).sequenza.small.seqz.gz
      cpu: seqz_binning_cpu
      ram: seqz_binning_ram
    out: [seqz]

  sequenza_coyote:
    run: ../tools/sequenza_coyote.cwl
    in:
      input_seqz: sequenza_seqz_binning/seqz
      sample_name: tumor_sample_name 
      cpu: sequenza_cpu
      ram: sequenza_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
