cwlVersion: v1.0
class: Workflow
id: kfdrc_lancet_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  indexed_reference_fasta: {type: File, secondaryFiles: [.fai, ^.dict]}
  vep_cache: {type: 'File', doc: "tar gzipped cache from ensembl/local converted cache"}
  vep_assembly: {type: string, doc: "Type of reference  assembly used. Ex: CanFam3.1 for canine"}
  vep_cache_version: {type: string, doc: "Version of ensembl cache file, Ex: 99, 98"}
  reference_gzipped: {type: 'File',  secondaryFiles: [.fai,.gzi], doc: "Fasta genome assembly with indexes"}
  reference_dict: File
  input_tumor_aligned:
    type: File
    secondaryFiles: |
      ${
        var dpath = self.location.replace(self.basename, "")
        if(self.nameext == '.bam'){
          return {"location": dpath+self.nameroot+".bai", "class": "File"}
        }
        else{
          return {"location": dpath+self.basename+".crai", "class": "File"}
        }
      }
    doc: "tumor BAM or CRAM"

  input_normal_aligned:
    type: File
    secondaryFiles: |
      ${
        var dpath = self.location.replace(self.basename, "")
        if(self.nameext == '.bam'){
          return {"location": dpath+self.nameroot+".bai", "class": "File"}
        }
        else{
          return {"location": dpath+self.basename+".crai", "class": "File"}
        }
      }
    doc: "normal BAM or CRAM"

  strelka2_vcf: File
  mutect2_vcf: File
  select_vars_mode: {type: ['null', {type: enum, name: select_vars_mode, symbols: ["gatk", "grep"]}], doc: "Choose 'gatk' for SelectVariants tool, or 'grep' for grep expression", default: "gatk"}
  lancet_calling_interval_bed: {type: File, doc: "For WGS, highly recommended to use CDS bed, and supplement with region calls from strelka2 & mutect2.  Can still give calling list as bed if true WGS calling desired instead of exome+."}
  lancet_ram: {type: ['null', int], default: 12, doc: "Adjust in rare circumstances in which 12 GB is not enough"}
  lancet_window: {type: ['null', int], doc: "window size for lancet.  default is 600, recommend 500 for WGS, 600 for exome+", default: 600}
  lancet_padding: {type: ['null', int], doc: "Recommend 0 if interval file padded already, half window size if not", default: 300}
  output_basename: string
  

outputs:
  lancet_prepass_vcf: {type: File, outputSource: run_lancet/lancet_prepass_vcf}
  lancet_pass_vcf: {type: File, outputSource: run_lancet/lancet_pass_vcf}
  lancet_vep_vcf: {type: File, outputSource: run_lancet/lancet_vep_vcf}

steps:
  bedops_gen_lancet_intervals:
    run: ../tools/preprocess_lancet_intervals.cwl
    in:
      strelka2_vcf: strelka2_vcf
      mutect2_vcf: mutect2_vcf
      ref_bed: lancet_calling_interval_bed
      output_basename: output_basename
    out: [run_bed]

  gatk_intervallisttools_exome_plus:
    run: ../tools/gatk_intervallisttool.cwl
    in:
      interval_list: bedops_gen_lancet_intervals/run_bed
      reference_dict: reference_dict
      exome_flag:
        valueFrom: ${return "Y";}
      scatter_ct:
        valueFrom: ${return 50}
      bands:
        valueFrom: ${return 80000000}
    out: [output]

  run_lancet:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../sub_workflows/kfdrc_lancet_sub_wf.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_tumor_aligned: input_tumor_aligned
      input_normal_aligned: input_normal_aligned
      output_basename: output_basename
      select_vars_mode: select_vars_mode
      reference_dict: reference_dict
      bed_invtl_split: gatk_intervallisttools_exome_plus/output
      ram: lancet_ram
      window: lancet_window
      padding: lancet_padding
      vep_cache: vep_cache
      vep_assembly: vep_assembly
      vep_cache_version: vep_cache_version
      reference_gzipped: reference_gzipped
    out:
      [lancet_prepass_vcf, lancet_pass_vcf, lancet_vep_vcf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
  - class: 'sbg:AWSInstanceType'
    value: c5.9xlarge