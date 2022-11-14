cwlVersion: v1.2
class: CommandLineTool
id: vcfmerger2_prep_vcf_somatic.cwl 
doc: "Prepare VCFs for VCFmerger2" 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/vcfmerger2:0.9.3'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)

baseCommand: [/bin/bash, /opt/vcfMerger2-0.9.3/prep_vcfs_somatic/prep_vcf_somatic.sh]

inputs:
  # Required Always Arguments
  ref_genome: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], inputBinding: { position: 2, prefix: "--ref-genome"}, doc: "Reference fasta and associated fai" }
  toolname: { type: 'string', inputBinding: { position: 2, prefix: "--toolname"}, doc: "Provide the toolname associated to the input vcf; see valid toolnames in prep_vcf_defaults.ini file, or use --list-valid-toolnames in in-line command" }
  prepped_vcf_outfilename: { type: 'string', inputBinding: { position: 2, prefix: "--prepped-vcf-outfilename"}, doc: "Provide the name for the uptospecs vcf file that will be use as input for the vcfMerger2.0 tool" }
  tumor_sname: { type: 'string', inputBinding: { position: 2, prefix: "--tumor-sname"}, doc: "TUMOR SAMPLE NAME" }
  normal_sname: { type: 'string', inputBinding: { position: 2, prefix: "--normal-sname"}, doc: "NORMAL SAMPLE NAME" }

  # Required Sometimes Arguments
  bam: { type: 'File?', inputBinding: { position: 2, prefix: "--bam"}, doc: "BAM file to provide to generate intermediate contig file in case --contigs-file option is not provided but needed for current tool's vcf in process. Required for strelka inputs." }
  contigs_file: { type: 'File?', inputBinding: { position: 2, prefix: "--contigs-file"}, doc: "FILE_WITH_CONTIGS FORMATTED AS IT IS IN VCF HEADERS (Optional; depend on tool ; use the script 'convert_contig_list_from_bam_to_vcf_format.sh' located in utils directory to create the appropriate file ) [default is null ]" }
  vcf: { type: 'File?', inputBinding: { position: 2, prefix: "--vcf"}, doc: "vcf having all types of variants already (no need to concatenate). Required if separate indels and snvs vcfs not provided." }
  vcf_indels: { type: 'File?', inputBinding: { position: 2, prefix: "--vcf-indels"}, doc: "tool's VCF with indels (.vcf or .vcf.gz) ; note: toDate, concerns strelka2 only. Required along with vcf_snvs if input vcf not provided." }
  vcf_snvs: { type: 'File?', inputBinding: { position: 2, prefix: "--vcf-snvs"}, doc: "tool's VCF with snvs (.vcf or .vcf.gz) ; note: toDate, concerns strelka2 only. Required along with vcf_indels if input vcf is not provided." }

  # Optional Arguments
  make_bed_for_venn: { type: 'boolean?', inputBinding: { position: 2, prefix: "--make-bed-for-venn"}, doc: "enable making BED file for the Intervene python tool [default is disable]" }
  print_valid_toolnames: { type: 'boolean?', inputBinding: { position: 2, prefix: "--print-valid-toolnames"}, doc: "Print default valid toolnames accepted so far (case insensitive) and exit" }
  do_not_normalize: { type: 'boolean?', inputBinding: { position: 2, prefix: "--do-not-normalize"}, doc: "disable normalization [default is enable]" }
  threshold_ar: { type: 'float?', inputBinding: { position: 2, prefix: "--threshold-AR"}, doc: "AR value (float from 0.000001 to 1 ). Based on that value, the GT flag (genotype) will be assigned to 0/1 if below that threshold or 1/1 if equal or above that threshold [default value is 0.90 ]" }

  cpu:
    type: 'int?'
    default: 2
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."

outputs:
  output: 
    type: File
    outputBinding:
      glob: |
        $(inputs.prepped_vcf_outfilename) 
