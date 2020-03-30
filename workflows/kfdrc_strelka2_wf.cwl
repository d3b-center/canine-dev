cwlVersion: v1.0
class: Workflow
id: kfdrc_strelka2_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  indexed_reference_fasta: {type: File, secondaryFiles: [.fai, ^.dict]}
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

  input_tumor_name: string
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

  input_normal_name: string
  exome_flag: {type: string?, default: "N", doc: "Whether to run in exome mode for callers. Should be N or leave blank as default is N. Only make Y if you are certain"}
  select_vars_mode: {type: ['null', {type: enum, name: select_vars_mode, symbols: ["gatk", "grep"]}], doc: "Choose 'gatk' for SelectVariants tool, or 'grep' for grep expression", default: "gatk"}
  strelka2_bed: {type: File, secondaryFiles: ['.tbi'], doc: "Bgzipped interval bed file. Recommend canonical chromosomes"}
  output_basename: string

outputs:
  strelka2_prepass_vcf: {type: File, outputSource: run_strelka2/strelka2_prepass_vcf}
  strelka2_pass_vcf: {type: File, outputSource: run_strelka2/strelka2_pass_vcf}

steps:

  run_strelka2:
    run: ../sub_workflows/kfdrc_strelka2_sub_wf.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      reference_dict: reference_dict
      strelka2_bed: strelka2_bed
      input_tumor_aligned: input_tumor_aligned
      input_tumor_name: input_tumor_name
      input_normal_aligned: input_normal_aligned
      input_normal_name: input_normal_name
      exome_flag: exome_flag
      output_basename: output_basename
      select_vars_mode: select_vars_mode
    out:
      [strelka2_prepass_vcf, strelka2_pass_vcf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
  - class: 'sbg:AWSInstanceType'
    value: c5.9xlarge