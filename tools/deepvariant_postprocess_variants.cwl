cwlVersion: v1.2
class: CommandLineTool
id: deepvariant_postprocess_variants
doc: "Deepvariant Postprocess Variants"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'google/deepvariant:0.10.0-gpu'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.nonvariant_site_tfrecords)]
baseCommand: [/opt/deepvariant/bin/postprocess_variants]
inputs:
  cnn_homref_call_min_gq: { type: 'float?', inputBinding: { position: 2, prefix: "--cnn_homref_call_min_gq"}, doc: "All CNN RefCalls whose GQ is less than this value will have ./. genotype instead of 0/0." }
  group_variants: { type: 'boolean?', inputBinding: { position: 2, prefix: "--group_variants"}, doc: "If using vcf_candidate_importer and multi-allelic sites are split across multiple lines in VCF, set to False so that variants are not grouped when transforming CallVariantsOutput to Variants." }
  gvcf_outfile: { type: 'string?', inputBinding: { position: 2, prefix: "--gvcf_outfile"}, doc: "Optional. Destination path where we will write the Genomic VCF output." }
  infile: { type: 'File[]', inputBinding: { position: 2, prefix: "--infile"}, doc: "Required. Path(s) to CallVariantOutput protos in TFRecord format to postprocess. These should be the complete set of outputs for call_variants.py." }
  multi_allelic_qual_filter: { type: 'float?', inputBinding: { position: 2, prefix: "--multi_allelic_qual_filter"}, doc: "The qual value below which to filter multi-allelic variants." }
  nonvariant_site_tfrecord: { type: 'File[]?', doc: "Optional. Path(s) to the non-variant sites protos in TFRecord format to convert to gVCF file. This should be the complete set of outputs from the --gvcf flag of make_examples.py." }
  nonvariant_site_tfrecord_path: { type: 'string?', inputBinding: { position: 2, prefix: "--nonvariant_site_tfrecord_path", shellQuote: false }, doc: "Smart path through which all nonvariant_site_tfrecords files can be found." } 
  outfile: { type: 'string?', inputBinding: { position: 2, prefix: "--outfile"}, doc: "Required. Destination path where we will write output variant calls in VCF format." }
  qual_filter: { type: 'float?', inputBinding: { position: 2, prefix: "--qual_filter"}, doc: "Any variant with QUAL < qual_filter will be filtered in the VCF file." }
  ref: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true}], inputBinding: { position: 2, prefix: "--ref"}, doc: "Required. Genome reference in FAI-indexed FASTA format. Used to determine the sort order for the emitted variants and the VCF header." }
  vcf_stats_report: { type: 'boolean?', inputBinding: { position: 2, prefix: "--vcf_stats_report"}, doc: "Optional. Output a visual report (HTML) of statistics about the output VCF at the same base path given by --outfile." }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 16
    doc: "Maximum GB of RAM to allocate for this tool."
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.outfile)
  gvcf:
    type: File
    outputBinding:
      glob: $(inputs.gvcf_outfile)
