cwlVersion: v1.0
class: CommandLineTool
id: kfdrc-manta-sv
label: Manta sv caller
doc: 'Calls structural variants.  Tool designed to pick correct run mode based on if tumor, normal, or both crams are given'
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: $(inputs.cores)
  - class: DockerRequirement
    dockerPull: 'kfdrc/manta:1.4.0'

baseCommand: [/manta-1.4.0.centos6_x86_64/bin/configManta.py]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      ${
        var std = " --ref " + inputs.reference.path + " --callRegions " + inputs.strelka2_bed.path + " --runDir=./ && ./runWorkflow.py -m local -j " + inputs.cores + " --quiet ";
        var mv = " && mv results/variants/";
        if (typeof inputs.input_tumor_bam === 'undefined' || inputs.input_tumor_bam === null){
          var mv_cmd = mv + "diploidSV.vcf.gz " +  inputs.output_basename + ".manta.diploidSV.vcf.gz" + mv + "diploidSV.vcf.gz.tbi " + inputs.output_basename + ".manta.diploidSV.vcf.gz.tbi";
          return "--bam ".concat(inputs.input_normal_bam.path, std, mv_cmd);
        }
        else if (typeof inputs.input_normal_bam === 'undefined' || inputs.input_normal_bam === null){
          var mv_cmd = mv + "tumorSV.vcf.gz " + inputs.output_basename + ".manta.tumorSV.vcf.gz" + mv + "tumorSV.vcf.gz.tbi " + inputs.output_basename + ".manta.tumorSV.vcf.gz.tbi";
          return "--tumorBam " + inputs.input_tumor_bam.path + std + mv_cmd;
        }
        else{
          var mv_cmd = mv + "somaticSV.vcf.gz " + inputs.output_basename + ".manta.somaticSV.vcf.gz" + mv + "somaticSV.vcf.gz.tbi " + inputs.output_basename + ".manta.somaticSV.vcf.gz.tbi";
          return "--tumorBam " + inputs.input_tumor_bam.path + " --normalBam " + inputs.input_normal_bam.path + std + mv_cmd;
        }
      }

inputs:
    reference: {type: File, secondaryFiles: [^.dict, .fai]}
    strelka2_bed: {type: File, secondaryFiles: [.tbi]}
    input_tumor_bam: {type: ["null", File], secondaryFiles: [.bai]}
    input_normal_bam: {type: ["null", File], secondaryFiles: [.bai]}
    cores: {type: ['null', int], default: 18}
    output_basename: string
outputs:
  - id: output_sv
    type: File
    outputBinding:
      glob: '*SV.vcf.gz'
    secondaryFiles: [.tbi]
