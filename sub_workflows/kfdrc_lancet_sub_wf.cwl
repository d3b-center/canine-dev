cwlVersion: v1.0
class: Workflow
id: kfdrc_lancet_sub_wf
doc: "Lancet sub workflow, meant to be wrapped"
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  indexed_reference_fasta: {type: File, secondaryFiles: [.fai, ^.dict]}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache"}
  vep_assembly: {type: string, doc: "Type of reference  assembly used. Ex: CanFam3.1 for canine"}
  vep_cache_version: {type: string, doc: "Version of ensembl cache file, Ex: 99, 98"}
  reference_gzipped: {type: 'File',  secondaryFiles: [.fai,.gzi], doc: "Fasta genome assembly with indexes"}
  input_tumor_aligned: {type: File, secondaryFiles: [^.bai]}
  input_normal_aligned: {type: File, secondaryFiles: [^.bai]}
  output_basename: string
  reference_dict: File
  bed_invtl_split: {type: 'File[]', doc: "Bed file intervals passed on from and outside pre-processing step"}
  ram: {type: ['null', int], default: 12, doc: "Adjust in rare circumstances in which 12 GB is not enough."}
  select_vars_mode: {type: ['null', {type: enum, name: select_vars_mode, symbols: ["gatk", "grep"]}], doc: "Choose 'gatk' for SelectVariants tool, or 'grep' for grep expression", default: "gatk"}
  window: {type: int, doc: "window size for lancet.  default is 600, recommend 500 for WGS, 600 for exome+"}
  padding: {type: int, doc: "If WGS (less likely), default 25, if exome+, recommend half window size"}
  

outputs:
  lancet_prepass_vcf: {type: File, outputSource: sort_merge_lancet_vcf/merged_vcf}
  lancet_pass_vcf: {type: File, outputSource: gatk_selectvariants_lancet/pass_vcf}
  lancet_vep_vcf: {type: File, outputSource: vep_annot_lancet/output_vcf}
  

steps:
  lancet:
    run: ../tools/lancet.cwl
    in:
      input_tumor_bam: input_tumor_aligned
      input_normal_bam: input_normal_aligned
      reference: indexed_reference_fasta
      bed: bed_invtl_split
      output_basename: output_basename
      window: window
      padding: padding
      ram: ram
    scatter: [bed]
    out: [lancet_vcf]

  sort_merge_lancet_vcf:
    run: ../tools/gatk_sortvcf.cwl
    label: GATK Sort & Merge lancet
    in:
      input_vcfs: lancet/lancet_vcf
      output_basename: output_basename
      reference_dict: reference_dict
      tool_name:
        valueFrom: ${return "lancet"}
    out: [merged_vcf]

  gatk_selectvariants_lancet:
    run: ../tools/gatk_selectvariants.cwl
    label: GATK Select Lancet PASS
    in:
      input_vcf: sort_merge_lancet_vcf/merged_vcf
      output_basename: output_basename
      tool_name:
        valueFrom: ${return "lancet"}
      mode: select_vars_mode
    out: [pass_vcf]

  vep_annot_lancet:
    run: ../tools/vep_annotate.cwl
    in:
      reference_gzipped: reference_gzipped
      input_vcf: gatk_selectvariants_lancet/pass_vcf
      cache: vep_cache
      output_basename: output_basename
      tool_name:
        valueFrom: ${return "lancet"}
      assembly: vep_assembly
      species: 
        valueFrom: ${return "canis_familiaris"}
      cache_version: vep_cache_version
    out: [output_vcf]   


$namespaces:
  sbg: https://sevenbridges.com